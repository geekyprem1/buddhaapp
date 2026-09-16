'use strict';

/**
 * Dumps today's `aiUsage` docs for a project, to see what the quota layer
 * actually recorded. Read-only.
 *
 * Usage: node verify_ai_usage.js --project=dhamma-path-prod
 */

const https = require('node:https');
const { getAccessToken } = require('./firestore_rest');

const projectArg = process.argv.slice(2).find((a) => a.startsWith('--project='));
const projectId = projectArg ? projectArg.split('=')[1] : null;
if (!projectId) {
  console.error('Missing --project=<id>');
  process.exit(1);
}

const token = getAccessToken();
const path = `/v1/projects/${projectId}/databases/(default)/documents/aiUsage`;

https
  .get(
    {
      hostname: 'firestore.googleapis.com',
      path,
      headers: { Authorization: `Bearer ${token}` },
    },
    (res) => {
      let data = '';
      res.on('data', (c) => (data += c));
      res.on('end', () => {
        if (res.statusCode !== 200) {
          console.error(`HTTP ${res.statusCode}: ${data}`);
          process.exit(1);
        }
        const docs = JSON.parse(data).documents ?? [];
        if (docs.length === 0) {
          console.log('No aiUsage docs at all — reserveMessage never ran.');
          return;
        }
        for (const d of docs) {
          const f = d.fields ?? {};
          const v = (k) =>
            f[k]?.integerValue ??
            f[k]?.stringValue ??
            f[k]?.booleanValue ??
            f[k]?.timestampValue ??
            '(unset)';
          console.log(`\ndoc: ${d.name.split('/').pop()}`);
          for (const k of [
            'messages',
            'offTopicStrikes',
            'tier',
            'promptTokens',
            'completionTokens',
            'lastAnswerAt',
            'usedSeconds',
          ]) {
            console.log(`  ${k} = ${v(k)}`);
          }
        }
      });
    },
  )
  .on('error', (e) => {
    console.error(e.message);
    process.exit(1);
  });
