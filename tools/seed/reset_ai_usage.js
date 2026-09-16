'use strict';

/**
 * Deletes every `aiUsage` doc for a project, resetting today's Bodhi AI
 * message counts and off-topic strikes. Intended for testing — the docs are
 * Function-only, so there is no in-app way to clear them.
 *
 * Usage: node reset_ai_usage.js --project=dhamma-path-prod --yes
 */

const https = require('node:https');
const { getAccessToken } = require('./firestore_rest');

const args = process.argv.slice(2);
const projectArg = args.find((a) => a.startsWith('--project='));
const projectId = projectArg ? projectArg.split('=')[1] : null;
const confirmed = args.includes('--yes');

if (!projectId) {
  console.error('Missing --project=<id>');
  process.exit(1);
}

const token = getAccessToken();
const base = `/v1/projects/${projectId}/databases/(default)/documents`;

function request(method, path) {
  return new Promise((resolve, reject) => {
    const req = https.request(
      {
        method,
        hostname: 'firestore.googleapis.com',
        path,
        headers: { Authorization: `Bearer ${token}` },
      },
      (res) => {
        let data = '';
        res.on('data', (c) => (data += c));
        res.on('end', () =>
          res.statusCode >= 200 && res.statusCode < 300
            ? resolve(data ? JSON.parse(data) : {})
            : reject(new Error(`${method} ${path} → ${res.statusCode} ${data}`)),
        );
      },
    );
    req.on('error', reject);
    req.end();
  });
}

(async () => {
  const list = await request('GET', `${base}/aiUsage`);
  const docs = list.documents ?? [];
  if (docs.length === 0) {
    console.log('No aiUsage docs — nothing to reset.');
    return;
  }
  console.log(`Found ${docs.length} doc(s):`);
  for (const d of docs) console.log(`  ${d.name.split('/').pop()}`);

  if (!confirmed) {
    console.log('\nDRY RUN — re-run with --yes to delete these.');
    return;
  }
  for (const d of docs) {
    const rel = d.name.slice(d.name.indexOf('/documents/') + '/documents'.length);
    await request('DELETE', `/v1/projects/${projectId}/databases/(default)/documents${rel}`);
    console.log(`  deleted ${d.name.split('/').pop()}`);
  }
  console.log('\nQuota and off-topic strikes reset.');
})().catch((err) => {
  console.error('Reset failed:', err.message);
  process.exit(1);
});
