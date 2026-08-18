'use strict';

const { execFileSync } = require('node:child_process');
const https = require('node:https');

/**
 * Minimal Firestore REST client used only by the dev seed script
 * (Architecture §0 unlock task T0.9). Deliberately dependency-free — no
 * `firebase-admin`, no service account key. It reuses the same OAuth
 * access token the Firebase CLI already holds for the developer running
 * `firebase login`, exactly like the PowerShell snippets used earlier to
 * provision these Firebase projects.
 */

function getAccessToken() {
  // `shell: true` is required on Windows to resolve `firebase` (a .ps1/.cmd
  // shim), but its args are then concatenated rather than escaped — safe
  // here because the argument list is a fixed, hardcoded literal below,
  // never user input.
  const isWindows = process.platform === 'win32';
  const raw = execFileSync('firebase', ['login:list', '--json'], {
    encoding: 'utf8',
    shell: isWindows,
  });
  const parsed = JSON.parse(raw);
  const token = parsed?.result?.[0]?.tokens?.access_token;
  if (!token) {
    throw new Error(
      'Could not obtain a Firebase CLI access token. Run `firebase login` first.',
    );
  }
  return token;
}

/** Converts a plain JS value into a Firestore REST API "Value" object. */
function toFirestoreValue(value) {
  if (value === null || value === undefined) {
    return { nullValue: null };
  }
  if (typeof value === 'string') {
    return { stringValue: value };
  }
  if (typeof value === 'boolean') {
    return { booleanValue: value };
  }
  if (typeof value === 'number') {
    return Number.isInteger(value)
      ? { integerValue: String(value) }
      : { doubleValue: value };
  }
  if (value instanceof Date) {
    return { timestampValue: value.toISOString() };
  }
  if (Array.isArray(value)) {
    return { arrayValue: { values: value.map(toFirestoreValue) } };
  }
  if (typeof value === 'object') {
    return { mapValue: { fields: toFirestoreFields(value) } };
  }
  throw new Error(`Unsupported value type for Firestore seed: ${typeof value}`);
}

/** Converts a plain JS object into a Firestore REST API "fields" map. */
function toFirestoreFields(obj) {
  const fields = {};
  for (const [key, value] of Object.entries(obj)) {
    fields[key] = toFirestoreValue(value);
  }
  return fields;
}

class FirestoreRestClient {
  constructor(projectId, accessToken) {
    this.projectId = projectId;
    this.accessToken = accessToken;
    this.baseUrl = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents`;
  }

  _request(method, path, body) {
    return new Promise((resolve, reject) => {
      const url = new URL(`${this.baseUrl}${path}`);
      const payload = body ? JSON.stringify(body) : undefined;
      const req = https.request(
        {
          method,
          hostname: url.hostname,
          path: `${url.pathname}${url.search}`,
          headers: {
            Authorization: `Bearer ${this.accessToken}`,
            'Content-Type': 'application/json',
            ...(payload ? { 'Content-Length': Buffer.byteLength(payload) } : {}),
          },
        },
        (res) => {
          let data = '';
          res.on('data', (chunk) => (data += chunk));
          res.on('end', () => {
            if (res.statusCode >= 200 && res.statusCode < 300) {
              resolve(data ? JSON.parse(data) : {});
            } else {
              reject(
                new Error(
                  `Firestore REST ${method} ${path} failed: ${res.statusCode} ${data}`,
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

  /** Creates or overwrites a document at collection/{documentId}. */
  async setDocument(collection, documentId, fields) {
    const body = { fields: toFirestoreFields(fields) };
    return this._request(
      'PATCH',
      `/${collection}/${documentId}`,
      body,
    );
  }
}

module.exports = { FirestoreRestClient, getAccessToken, toFirestoreValue };
