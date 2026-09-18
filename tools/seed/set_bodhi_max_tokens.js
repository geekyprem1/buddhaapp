'use strict';

/**
 * Updates only `config/bodhi_ai.maxTokens`, preserving every other live
 * setting. Production writes require an explicit `--yes`.
 *
 * Usage:
 *   node set_bodhi_max_tokens.js --project=dhamma-path-prod --value=300 --yes
 */

const { FirestoreRestClient, getAccessToken } = require('./firestore_rest');

const args = process.argv.slice(2);
const readArg = (name) => {
  const value = args.find((arg) => arg.startsWith(`--${name}=`));
  return value ? value.slice(name.length + 3) : null;
};
const projectId = readArg('project');
const value = Number(readArg('value'));
const confirmed = args.includes('--yes');

if (!projectId) {
  console.error('Missing --project=<id>.');
  process.exit(1);
}
if (!Number.isInteger(value) || value < 50 || value > 2000) {
  console.error('--value must be an integer from 50 through 2000.');
  process.exit(1);
}
if (!confirmed) {
  console.log(`Dry run: would set ${projectId} config/bodhi_ai.maxTokens=${value}`);
  process.exit(0);
}

async function main() {
  const db = new FirestoreRestClient(projectId, getAccessToken());
  await db._request(
    'PATCH',
    '/config/bodhi_ai?updateMask.fieldPaths=maxTokens&updateMask.fieldPaths=updatedAt',
    {
      fields: {
        maxTokens: { integerValue: String(value) },
        updatedAt: { timestampValue: new Date().toISOString() },
      },
    },
  );
  console.log(`Set ${projectId} config/bodhi_ai.maxTokens=${value}`);
}

main().catch((error) => {
  console.error('Update failed:', error.message);
  process.exit(1);
});
