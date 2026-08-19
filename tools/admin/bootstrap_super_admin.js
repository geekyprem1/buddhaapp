'use strict';

/**
 * First Super Admin bootstrap (TASKS T1.3).
 *
 * `setAdminRole` is Super-Admin-only, so the very first account has to be
 * minted outside the callable. This script reuses the developer's
 * `firebase login` token — no service-account JSON file.
 *
 * Usage:
 *   node tools/admin/bootstrap_super_admin.js --email=you@dhammapath.app --password=... --name="Anita"
 *   node tools/admin/bootstrap_super_admin.js --emulator --email=dev@local.test --password=password123 --name="Dev"
 *
 * Refuses dhamma-path-prod unless --allow-prod is passed.
 */

const https = require('node:https');
const http = require('node:http');
const { getAccessToken, FirestoreRestClient } = require('../seed/firestore_rest');

const WEB_API_KEYS = {
  'dhamma-path-dev': 'AIzaSyBq3r2jkTyfsZz80kgI8xRnjOk-CFPKJbo',
  'dhamma-path-prod': 'AIzaSyDRWGavJW2t1GZl_jtaavmim1UqubJwUSU',
};

function parseArgs(argv) {
  const out = {
    email: null,
    password: null,
    name: '',
    project: 'dhamma-path-dev',
    emulator: false,
    allowProd: false,
  };
  for (const raw of argv) {
    if (raw === '--emulator') out.emulator = true;
    else if (raw === '--allow-prod') out.allowProd = true;
    else if (raw.startsWith('--email=')) out.email = raw.slice('--email='.length);
    else if (raw.startsWith('--password=')) out.password = raw.slice('--password='.length);
    else if (raw.startsWith('--name=')) out.name = raw.slice('--name='.length);
    else if (raw.startsWith('--project=')) out.project = raw.slice('--project='.length);
  }
  return out;
}

function jsonRequest({ protocol, hostname, port, path, method, headers, body }) {
  const payload = body ? JSON.stringify(body) : undefined;
  const lib = protocol === 'http:' ? http : https;
  return new Promise((resolve, reject) => {
    const req = lib.request(
      {
        hostname,
        port,
        path,
        method,
        headers: {
          'Content-Type': 'application/json',
          ...(payload ? { 'Content-Length': Buffer.byteLength(payload) } : {}),
          ...headers,
        },
      },
      (res) => {
        let data = '';
        res.on('data', (chunk) => (data += chunk));
        res.on('end', () => {
          let parsed = {};
          try {
            parsed = data ? JSON.parse(data) : {};
          } catch {
            parsed = { raw: data };
          }
          if (res.statusCode >= 200 && res.statusCode < 300) {
            resolve(parsed);
          } else {
            reject(
              new Error(
                `${method} ${path} failed: ${res.statusCode} ${data}`,
              ),
            );
          }
        });
      },
    );
    req.on('error', reject);
    if (payload) req.write(payload);
    req.end();
  });
}

async function lookupUser({ projectId, email, token, emulator }) {
  if (emulator) {
    return null;
  }
  try {
    const result = await jsonRequest({
      protocol: 'https:',
      hostname: 'identitytoolkit.googleapis.com',
      path: `/v1/projects/${projectId}/accounts:lookup`,
      method: 'POST',
      headers: { Authorization: `Bearer ${token}` },
      body: { email: [email] },
    });
    return result.users?.[0] ?? null;
  } catch (err) {
    if (String(err.message).includes('404') || String(err.message).includes('USER_NOT_FOUND')) {
      return null;
    }
    throw err;
  }
}

async function createUser({ projectId, email, password, name, apiKey, emulator }) {
  const path = `/identitytoolkit.googleapis.com/v1/accounts:signUp?key=${apiKey}`;
  const result = await jsonRequest({
    protocol: emulator ? 'http:' : 'https:',
    hostname: emulator ? '127.0.0.1' : 'identitytoolkit.googleapis.com',
    port: emulator ? 9099 : undefined,
    path: emulator ? path : `/v1/accounts:signUp?key=${apiKey}`,
    method: 'POST',
    body: {
      email,
      password,
      displayName: name || undefined,
      returnSecureToken: true,
    },
  });
  return result.localId;
}

async function setSuperAdminClaim({ projectId, uid, token, emulator, apiKey }) {
  if (emulator) {
    return jsonRequest({
      protocol: 'http:',
      hostname: '127.0.0.1',
      port: 9099,
      path: `/identitytoolkit.googleapis.com/v1/accounts:update?key=${apiKey}`,
      method: 'POST',
      body: {
        localId: uid,
        customAttributes: JSON.stringify({ role: 'super_admin' }),
      },
    });
  }
  return jsonRequest({
    protocol: 'https:',
    hostname: 'identitytoolkit.googleapis.com',
    path: `/v1/projects/${projectId}/accounts:update`,
    method: 'POST',
    headers: { Authorization: `Bearer ${token}` },
    body: {
      localId: uid,
      customAttributes: JSON.stringify({ role: 'super_admin' }),
      displayName: undefined,
    },
  });
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (!args.email || !args.password) {
    console.error(
      'Usage: node tools/admin/bootstrap_super_admin.js --email=... --password=... [--name=...] [--project=dhamma-path-dev] [--emulator]',
    );
    process.exit(1);
  }
  if (args.project === 'dhamma-path-prod' && !args.allowProd) {
    console.error(
      'Refusing to bootstrap dhamma-path-prod without --allow-prod.',
    );
    process.exit(1);
  }
  if (args.password.length < 8) {
    console.error('Password must be at least 8 characters.');
    process.exit(1);
  }

  const apiKey = WEB_API_KEYS[args.project];
  if (!apiKey && !args.emulator) {
    console.error(`No web API key configured for project ${args.project}.`);
    process.exit(1);
  }

  const token = args.emulator ? 'owner' : getAccessToken();
  let uid;

  const existing = await lookupUser({
    projectId: args.project,
    email: args.email,
    token,
    emulator: args.emulator,
  });

  if (existing?.localId) {
    uid = existing.localId;
    console.log(`Reusing existing Auth user ${uid}`);
  } else {
    try {
      uid = await createUser({
        projectId: args.project,
        email: args.email,
        password: args.password,
        name: args.name,
        apiKey: apiKey || 'fake-api-key',
        emulator: args.emulator,
      });
      console.log(`Created Auth user ${uid}`);
    } catch (err) {
      if (!String(err.message).includes('EMAIL_EXISTS')) throw err;
      console.error(
        'Email already exists but lookup failed. Sign in once in the Firebase console and re-run, or pass a new email.',
      );
      process.exit(1);
    }
  }

  await setSuperAdminClaim({
    projectId: args.project,
    uid,
    token,
    emulator: args.emulator,
    apiKey: apiKey || 'fake-api-key',
  });
  console.log('Set custom claim role=super_admin');

  const firestore = args.emulator
    ? null
    : new FirestoreRestClient(args.project, token);

  if (args.emulator) {
    await jsonRequest({
      protocol: 'http:',
      hostname: '127.0.0.1',
      port: 8080,
      path: `/v1/projects/${args.project}/databases/(default)/documents/adminUsers/${uid}`,
      method: 'PATCH',
      headers: { Authorization: 'Bearer owner' },
      body: {
        fields: {
          email: { stringValue: args.email },
          name: { stringValue: args.name || '' },
          role: { stringValue: 'super_admin' },
          isActive: { booleanValue: true },
          createdBy: { stringValue: 'bootstrap' },
        },
      },
    });
  } else {
    await firestore.setDocument('adminUsers', uid, {
      email: args.email,
      name: args.name || '',
      role: 'super_admin',
      isActive: true,
      createdBy: 'bootstrap',
      createdAt: new Date(),
    });
  }

  console.log(`Wrote adminUsers/${uid}`);
  console.log('Done. Sign in to the admin panel with that email and password.');
  console.log('If you were already signed in, sign out and back in so the claim refreshes.');
}

main().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});
