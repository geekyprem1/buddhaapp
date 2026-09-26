'use strict';

/**
 * READ-ONLY audit of content list visibility.
 *
 * Two things can make a stored item unreachable in the UI:
 *   1. No `sortOrder` field — Firestore silently DROPS such documents from the
 *      app's `orderBy('sortOrder')` page query.
 *   2. No `type` / `title` — the `ContentItem` model cannot decode it. These
 *      are leftovers from an upload whose draft doc no longer carries the
 *      admin-written fields; they hold only `mediaUrl`/`thumbUrl`/`storagePath`.
 *
 * It also reports how many items sit at the default `sortOrder: 0`, because
 * those sort BELOW everything numbered and therefore land at the very end of
 * both the admin desk and the app list.
 *
 * Usage:
 *   node audit_content_visibility.js --project=dhamma-path-prod
 *   node audit_content_visibility.js --project=dhamma-path-prod --collection=wallpapers
 */

const https = require('node:https');
const { getAccessToken } = require('./firestore_rest');

const COLLECTIONS = [
  'wallpapers',
  'ringtones',
  'songs',
  'vandanas',
  'meditations',
  'chantings',
  'statuses',
  'prarthanas',
];

const arg = (name, fallback = null) => {
  const hit = process.argv.slice(2).find((a) => a.startsWith(`--${name}=`));
  return hit ? hit.split('=').slice(1).join('=') : fallback;
};

const projectId = arg('project');
const only = arg('collection');
if (!projectId) {
  console.error('Missing --project=<id>');
  process.exit(1);
}

const token = getAccessToken();

function get(path) {
  return new Promise((resolve, reject) => {
    https
      .get(
        {
          hostname: 'firestore.googleapis.com',
          path,
          headers: { Authorization: `Bearer ${token}` },
        },
        (res) => {
          let d = '';
          res.on('data', (c) => (d += c));
          res.on('end', () => {
            if (res.statusCode !== 200) {
              reject(new Error(`HTTP ${res.statusCode}: ${d}`));
              return;
            }
            resolve(JSON.parse(d));
          });
        },
      )
      .on('error', reject);
  });
}

async function listAll(collection) {
  const base = `/v1/projects/${projectId}/databases/(default)/documents/${collection}`;
  const mask = ['sortOrder', 'status', 'type', 'title', 'createdAt', 'updatedAt']
    .map((f) => `mask.fieldPaths=${f}`)
    .join('&');
  const out = [];
  let pageToken = null;
  do {
    const qs = `?pageSize=300&${mask}${pageToken ? `&pageToken=${encodeURIComponent(pageToken)}` : ''}`;
    const page = await get(`${base}${qs}`);
    for (const d of page.documents ?? []) out.push(d);
    pageToken = page.nextPageToken ?? null;
  } while (pageToken);
  return out;
}

(async () => {
  for (const collection of only ? [only] : COLLECTIONS) {
    const docs = await listAll(collection);
    const f = (d) => d.fields ?? {};
    const noSort = docs.filter((d) => !('sortOrder' in f(d)));
    const undecodable = docs.filter((d) => !f(d).type || !f(d).title);
    const zeroSort = docs.filter(
      (d) => Number(f(d).sortOrder?.integerValue ?? -1) === 0,
    );
    const noCreated = docs.filter((d) => !f(d).createdAt?.timestampValue);

    console.log(
      [
        `${collection}: ${docs.length} docs`,
        `${noSort.length} missing sortOrder (hidden from the app query)`,
        `${undecodable.length} undecodable (no type/title)`,
        `${zeroSort.length} at sortOrder 0 (sort last)`,
        `${noCreated.length} missing createdAt`,
      ].join('\n  '),
    );
    for (const d of undecodable) {
      console.log(`    junk doc: ${d.name.split('/').pop()}`);
    }
  }
})().catch((e) => {
  console.error(e.message);
  process.exit(1);
});
