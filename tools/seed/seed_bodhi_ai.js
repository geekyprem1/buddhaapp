'use strict';

/**
 * Seeds `config/bodhi_ai` — the admin-controlled settings for the Bodhi AI
 * chat ("Ask Buddha"), see `.kiro/specs/bodhi-ai-chat/design.md`.
 *
 * The shape mirrors `BodhiAiConfig` in `packages/core` and the server-side
 * reader in `functions/src/ai/config.ts`. The Buddhism-only restriction is
 * NOT in `systemInstruction` — that rule is hardcoded in the Function and
 * prepended to whatever tone is stored here. This field is only tone/style.
 *
 * Unlike the main dev seed, this one CAN target production (that's where the
 * feature is being tested), so it refuses to write without an explicit
 * `--yes` flag.
 *
 * Usage:
 *   node seed_bodhi_ai.js --project=dhamma-path-prod            # dry run (prints, no write)
 *   node seed_bodhi_ai.js --project=dhamma-path-prod --yes      # actually writes
 *
 * Requires: `firebase login` already done (reuses that OAuth token).
 */

const { FirestoreRestClient, getAccessToken } = require('./firestore_rest');

const args = process.argv.slice(2);
const projectArg = args.find((a) => a.startsWith('--project='));
const projectId = projectArg ? projectArg.split('=')[1] : null;
const confirmed = args.includes('--yes');

if (!projectId) {
  console.error('Missing --project=<id>. Refusing to guess a target project.');
  process.exit(1);
}

// Tone/style only. The Buddhism-only scope rule is enforced in the Function.
const systemInstruction = {
  en:
    'You are a warm, humble teacher of Buddhism. Answer clearly and simply, ' +
    'grounded in the Buddha\'s teachings (the Dhamma). Be compassionate, ' +
    'respectful and encouraging. Prefer plain language over jargon, and keep ' +
    'replies concise. When helpful, gently point to relevant suttas, the ' +
    'Four Noble Truths, or the Eightfold Path. Do not claim to be the Buddha; ' +
    'you are a guide sharing his teachings.',
  hi:
    'आप बौद्ध धर्म के एक विनम्र और स्नेही शिक्षक हैं। बुद्ध की शिक्षाओं (धम्म) ' +
    'के आधार पर सरल और स्पष्ट उत्तर दें। करुणामय, सम्मानजनक और प्रोत्साहित करने ' +
    'वाले बनें। कठिन शब्दों के बजाय आसान भाषा का प्रयोग करें और उत्तर संक्षिप्त ' +
    'रखें। जहाँ उपयुक्त हो, चार आर्य सत्य, अष्टांगिक मार्ग या संबंधित सुत्तों की ' +
    'ओर कोमलता से संकेत करें। स्वयं को बुद्ध न कहें; आप उनकी शिक्षाएँ साझा करने ' +
    'वाले मार्गदर्शक हैं।',
  mr:
    'तुम्ही बौद्ध धर्माचे नम्र आणि स्नेहशील शिक्षक आहात. बुद्धांच्या शिकवणीच्या ' +
    '(धम्म) आधारे सोपी आणि स्पष्ट उत्तरे द्या. करुणामय, आदरयुक्त आणि प्रोत्साहन ' +
    'देणारे व्हा. कठीण शब्दांऐवजी सोपी भाषा वापरा आणि उत्तरे संक्षिप्त ठेवा. ' +
    'योग्य तेथे चार आर्यसत्ये, अष्टांगिक मार्ग किंवा संबंधित सुत्तांकडे हळुवारपणे ' +
    'निर्देश करा. स्वतःला बुद्ध म्हणू नका; तुम्ही त्यांची शिकवण सांगणारे मार्गदर्शक आहात.',
};

const config = {
  enabled: true,
  model: 'deepseek/deepseek-v4-flash-0731',
  systemInstruction,
  // The only meter. A wall-clock seconds budget used to sit alongside this;
  // it was removed because it drained while the user was reading or thinking.
  freeDailyMessages: 15,
  paidDailyMessages: 120,
  maxTokens: 300,
  temperature: 0.4,
  updatedAt: new Date(),
};

async function main() {
  console.log(`Target project : ${projectId}`);
  console.log('Document       : config/bodhi_ai');
  console.log('Payload        :');
  console.log(
    JSON.stringify(
      { ...config, updatedAt: config.updatedAt.toISOString() },
      null,
      2,
    ),
  );

  if (!confirmed) {
    console.log(
      '\nDRY RUN — nothing written. Re-run with --yes to write this document.',
    );
    return;
  }

  const accessToken = getAccessToken();
  const db = new FirestoreRestClient(projectId, accessToken);
  await db.setDocument('config', 'bodhi_ai', config);
  console.log('\nWrote config/bodhi_ai. Bodhi AI is now ENABLED.');
}

main().catch((err) => {
  console.error('Seed failed:', err.message);
  process.exit(1);
});
