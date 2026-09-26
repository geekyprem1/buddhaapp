'use strict';

/**
 * Throwaway Chrome DevTools Protocol probe (no npm deps).
 * Loads a URL in headless Chrome, records every console message / thrown
 * exception, reports whether the Flutter engine painted a canvas, and saves a
 * screenshot.
 *
 * Usage: node cdp_probe.js <url> <outPng>
 */

const http = require('node:http');
const net = require('node:net');
const crypto = require('node:crypto');
const fs = require('node:fs');
const { spawn } = require('node:child_process');
const os = require('node:os');
const path = require('node:path');

const url = process.argv[2];
const outPng = process.argv[3] || path.join(os.tmpdir(), 'cdp_shot.png');
const PORT = 9333;
const CHROME = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';

const profile = fs.mkdtempSync(path.join(os.tmpdir(), 'cdp-'));
const chrome = spawn(CHROME, [
  '--headless=new',
  '--disable-gpu',
  '--no-sandbox',
  '--no-first-run',
  '--window-size=1400,900',
  `--user-data-dir=${profile}`,
  `--remote-debugging-port=${PORT}`,
  'about:blank',
]);

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

function httpJson(pathname) {
  return new Promise((resolve, reject) => {
    http
      .get({ host: '127.0.0.1', port: PORT, path: pathname }, (res) => {
        let d = '';
        res.on('data', (c) => (d += c));
        res.on('end', () => {
          try {
            resolve(JSON.parse(d));
          } catch (e) {
            reject(e);
          }
        });
      })
      .on('error', reject);
  });
}

/** Bare-minimum WebSocket client: handshake + text frames. */
class Ws {
  constructor(wsUrl) {
    const u = new URL(wsUrl);
    this.key = crypto.randomBytes(16).toString('base64');
    this.buf = Buffer.alloc(0);
    this.handlers = [];
    this.ready = new Promise((resolve, reject) => {
      this.sock = net.connect(Number(u.port), u.hostname, () => {
        this.sock.write(
          `GET ${u.pathname} HTTP/1.1\r\n` +
            `Host: ${u.host}\r\n` +
            'Upgrade: websocket\r\n' +
            'Connection: Upgrade\r\n' +
            `Sec-WebSocket-Key: ${this.key}\r\n` +
            'Sec-WebSocket-Version: 13\r\n\r\n',
        );
      });
      this.sock.on('error', reject);
      let handshakeDone = false;
      this.sock.on('data', (chunk) => {
        if (!handshakeDone) {
          const idx = chunk.indexOf('\r\n\r\n');
          if (idx === -1) return;
          handshakeDone = true;
          resolve();
          const rest = chunk.subarray(idx + 4);
          if (rest.length) this._feed(rest);
          return;
        }
        this._feed(chunk);
      });
    });
  }

  _feed(chunk) {
    this.buf = Buffer.concat([this.buf, chunk]);
    for (;;) {
      if (this.buf.length < 2) return;
      const len0 = this.buf[1] & 0x7f;
      let offset = 2;
      let len = len0;
      if (len0 === 126) {
        if (this.buf.length < 4) return;
        len = this.buf.readUInt16BE(2);
        offset = 4;
      } else if (len0 === 127) {
        if (this.buf.length < 10) return;
        len = Number(this.buf.readBigUInt64BE(2));
        offset = 10;
      }
      if (this.buf.length < offset + len) return;
      const payload = this.buf.subarray(offset, offset + len).toString('utf8');
      this.buf = this.buf.subarray(offset + len);
      try {
        const msg = JSON.parse(payload);
        this.handlers.forEach((h) => h(msg));
      } catch {
        /* ignore fragmented/non-JSON frames */
      }
    }
  }

  send(obj) {
    const data = Buffer.from(JSON.stringify(obj));
    const mask = crypto.randomBytes(4);
    let header;
    if (data.length < 126) {
      header = Buffer.from([0x81, 0x80 | data.length]);
    } else if (data.length < 65536) {
      header = Buffer.alloc(4);
      header[0] = 0x81;
      header[1] = 0x80 | 126;
      header.writeUInt16BE(data.length, 2);
    } else {
      header = Buffer.alloc(10);
      header[0] = 0x81;
      header[1] = 0x80 | 127;
      header.writeBigUInt64BE(BigInt(data.length), 2);
    }
    const masked = Buffer.alloc(data.length);
    for (let i = 0; i < data.length; i++) masked[i] = data[i] ^ mask[i % 4];
    this.sock.write(Buffer.concat([header, mask, masked]));
  }

  on(fn) {
    this.handlers.push(fn);
  }
}

(async () => {
  let targets = [];
  for (let i = 0; i < 40; i++) {
    try {
      targets = await httpJson('/json/list');
      if (targets.some((t) => t.webSocketDebuggerUrl)) break;
    } catch {
      /* not up yet */
    }
    await sleep(250);
  }
  const target = targets.find((t) => t.webSocketDebuggerUrl);
  if (!target) throw new Error('no debuggable target');

  const ws = new Ws(target.webSocketDebuggerUrl);
  await ws.ready;

  let id = 0;
  const pending = new Map();
  const logs = [];
  ws.on((msg) => {
    if (msg.id && pending.has(msg.id)) {
      pending.get(msg.id)(msg);
      pending.delete(msg.id);
      return;
    }
    if (msg.method === 'Runtime.consoleAPICalled') {
      const text = (msg.params.args ?? [])
        .map((a) => a.value ?? a.description ?? a.type)
        .join(' ');
      logs.push(`[console.${msg.params.type}] ${text}`);
    } else if (msg.method === 'Runtime.exceptionThrown') {
      const d = msg.params.exceptionDetails;
      logs.push(
        `[EXCEPTION] ${d.text} ${d.exception?.description ?? ''} @${d.url ?? ''}:${d.lineNumber ?? ''}`,
      );
    } else if (msg.method === 'Log.entryAdded') {
      logs.push(`[log.${msg.params.entry.level}] ${msg.params.entry.text}`);
    }
  });

  const cmd = (method, params) =>
    new Promise((resolve) => {
      const myId = ++id;
      pending.set(myId, resolve);
      ws.send({ id: myId, method, params: params ?? {} });
    });

  await cmd('Runtime.enable');
  await cmd('Log.enable');
  await cmd('Page.enable');
  await cmd('Page.navigate', { url });
  await sleep(18000);

  const probe = await cmd('Runtime.evaluate', {
    expression: `JSON.stringify({
      canvases: document.querySelectorAll('canvas').length,
      glassPane: !!document.querySelector('flt-glass-pane'),
      sceneHost: !!document.querySelector('flt-scene-host'),
      bodyChildren: document.body.children.length,
      href: location.href,
      title: document.title
    })`,
    returnByValue: true,
  });
  console.log('--- DOM probe ---');
  console.log(probe.result?.result?.value ?? JSON.stringify(probe));

  const shot = await cmd('Page.captureScreenshot', { format: 'png' });
  if (shot.result?.data) {
    fs.writeFileSync(outPng, Buffer.from(shot.result.data, 'base64'));
    console.log(`--- screenshot saved: ${outPng} ---`);
  } else {
    console.log('--- screenshot failed ---');
  }

  console.log('--- console / exceptions ---');
  for (const l of logs) console.log(l);

  chrome.kill();
  process.exit(0);
})().catch((e) => {
  console.error('probe failed:', e.message);
  chrome.kill();
  process.exit(1);
});
