'use strict';

/**
 * Sets a GET-only CORS policy on the dev Storage bucket so Flutter Web
 * (CanvasKit fetches image bytes cross-origin and requires CORS) can render
 * Storage-hosted thumbnails in the admin panel. Content is already public-read
 * (Architecture §6.4); Storage Security Rules — not CORS — protect private
 * paths, so allowing GET from any origin is safe.
 *
 *   node set_cors.js
 */

const https = require('node:https');
const { getAccessToken } = require('./firestore_rest');

const bucket = 'dhamma-path-dev.firebasestorage.app';
const cors = [
  {
    origin: ['*'],
    method: ['GET', 'HEAD'],
    responseHeader: ['Content-Type', 'Content-Length'],
    maxAgeSeconds: 3600,
  },
];

function patch(token) {
  const payload = JSON.stringify({ cors });
  return new Promise((resolve, reject) => {
    const req = https.request(
      {
        method: 'PATCH',
        hostname: 'storage.googleapis.com',
        path: `/storage/v1/b/${encodeURIComponent(bucket)}?fields=cors`,
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(payload),
        },
      },
      (res) => {
        let data = '';
        res.on('data', (c) => (data += c));
        res.on('end', () => {
          if (res.statusCode >= 200 && res.statusCode < 300) {
            resolve(data);
          } else {
            reject(new Error(`${res.statusCode} ${data}`));
          }
        });
      },
    );
    req.on('error', reject);
    req.write(payload);
    req.end();
  });
}

async function main() {
  const token = getAccessToken();
  const result = await patch(token);
  console.log('CORS set on', bucket);
  console.log(result);
}

main().catch((e) => {
  console.error('SET CORS FAILED:', e.message);
  process.exit(1);
});
