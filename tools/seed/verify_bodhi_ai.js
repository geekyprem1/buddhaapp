'use strict';

/**
 * Prints the field names and key values of `config/bodhi_ai` for a project, so
 * a seed can be verified without hand-managing an OAuth token (the shared
 * helper refreshes an expired one).
 *
 * Usage: node verify_bodhi_ai.js --project=dhamma-path-prod
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
const path =
  `/v1/projects/${projectId}/databases/(default)/documents/config/bodhi_ai`;

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
        const fields = JSON.parse(data).fields ?? {};
        console.log('--- fields present ---');
        console.log(Object.keys(fields).sort().join('\n'));
        const read = (k) =>
          fields[k]?.booleanValue ??
          fields[k]?.integerValue ??
          fields[k]?.doubleValue ??
          fields[k]?.stringValue;
        console.log('\n--- values ---');
        for (const k of [
          'enabled',
          'model',
          'freeDailyMessages',
          'paidDailyMessages',
          'maxTokens',
          'temperature',
        ]) {
          console.log(`  ${k} = ${read(k)}`);
        }
        const stale = ['freeDailySeconds', 'paidDailySeconds'].filter(
          (k) => k in fields,
        );
        console.log(
          stale.length
            ? `\nSTALE FIELDS STILL PRESENT: ${stale.join(', ')}`
            : '\nNo stale seconds fields. Clean.',
        );
      });
    },
  )
  .on('error', (e) => {
    console.error(e.message);
    process.exit(1);
  });
