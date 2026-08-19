'use strict';

/**
 * Dhamma Path dev seed script (Architecture §0 / TASKS.md T0.9 — the "unlock"
 * task). Writes 4 teachers, a handful of items per content type, categories
 * and app config into a Firestore project so the mobile app can be built
 * and demoed end-to-end WITHOUT waiting for the admin panel (M1) or real
 * licensed content (M3).
 *
 * Usage:
 *   node seed.js                     # seeds dhamma-path-dev (default)
 *   node seed.js --project=<id>       # seeds a specific project
 *
 * Requires: `firebase login` already done (reuses that OAuth token — see
 * firestore_rest.js). Never point this at dhamma-path-prod.
 */

const { FirestoreRestClient, getAccessToken } = require('./firestore_rest');

const args = process.argv.slice(2);
const projectArg = args.find((a) => a.startsWith('--project='));
const projectId = projectArg ? projectArg.split('=')[1] : 'dhamma-path-dev';

if (projectId === 'dhamma-path-prod') {
  console.error(
    'Refusing to seed dhamma-path-prod. Seed data must never reach production (PRD D6 / M3).',
  );
  process.exit(1);
}

// Placeholder image/audio URLs — public-domain-style picsum/sample assets,
// purely so list screens and cards have something to render. Replaced by
// real licensed content during M3 content ingestion.
const PLACEHOLDER_IMG = (seed, w = 800, h = 1200) =>
  `https://picsum.photos/seed/${seed}/${w}/${h}`;
const PLACEHOLDER_STATUS =
  'https://placehold.co/1080x1350/8B1A1A/FDF3E0/png?text=Namo+Buddhay';
const PLACEHOLDER_AUDIO =
  'https://dl.espressif.com/dl/audio/gs-16b-2c-44100hz.mp3';

const now = () => new Date();

const teachers = [
  {
    id: 'buddha',
    name: { en: 'Gautam Buddha', hi: 'गौतम बुद्ध', mr: 'गौतम बुद्ध' },
    portraitUrl: PLACEHOLDER_IMG('buddha-portrait'),
    thumbUrl: PLACEHOLDER_IMG('buddha-thumb', 200, 200),
    bio: { en: 'Founder of Buddhism.', hi: '', mr: '' },
    signatureUrl: null,
    idCardPrefix: 'BUD',
    sortOrder: 1,
    isActive: true,
  },
  {
    id: 'ambedkar',
    name: {
      en: 'Dr. B. R. Ambedkar',
      hi: 'डॉ. बी. आर. अंबेडकर',
      mr: 'डॉ. बी. आर. आंबेडकर',
    },
    portraitUrl: PLACEHOLDER_IMG('ambedkar-portrait'),
    thumbUrl: PLACEHOLDER_IMG('ambedkar-thumb', 200, 200),
    bio: { en: 'Architect of the Indian Constitution.', hi: '', mr: '' },
    signatureUrl: null,
    idCardPrefix: 'BRA',
    sortOrder: 2,
    isActive: true,
  },
  {
    id: 'dalai_lama',
    name: { en: 'Dalai Lama', hi: 'दलाई लामा', mr: 'दलाई लामा' },
    portraitUrl: PLACEHOLDER_IMG('dalailama-portrait'),
    thumbUrl: PLACEHOLDER_IMG('dalailama-thumb', 200, 200),
    bio: { en: 'Spiritual leader of Tibetan Buddhism.', hi: '', mr: '' },
    signatureUrl: null,
    idCardPrefix: 'DLM',
    sortOrder: 3,
    isActive: true,
  },
  {
    id: 'thich_nhat_hanh',
    name: {
      en: 'Thich Nhat Hanh',
      hi: 'थिक न्हाट हान',
      mr: 'थिक न्हाट हान',
    },
    portraitUrl: PLACEHOLDER_IMG('tnh-portrait'),
    thumbUrl: PLACEHOLDER_IMG('tnh-thumb', 200, 200),
    bio: { en: 'Vietnamese Zen Buddhist monk.', hi: '', mr: '' },
    signatureUrl: null,
    idCardPrefix: 'TNH',
    sortOrder: 4,
    isActive: true,
  },
];

const categories = [
  { id: 'cat_wp_calm', module: 'wallpaper', name: { en: 'Calm', hi: 'शांत', mr: 'शांत' }, sortOrder: 1, isActive: true },
  { id: 'cat_wp_quotes', module: 'wallpaper', name: { en: 'Quotes', hi: 'उद्धरण', mr: 'उद्धरण' }, sortOrder: 2, isActive: true },
  { id: 'cat_med_anapana', module: 'meditation', name: { en: 'Anapana', hi: 'आनापान', mr: 'आनापान' }, sortOrder: 1, isActive: true },
  { id: 'cat_med_sleep', module: 'meditation', name: { en: 'Sleep', hi: 'निद्रा', mr: 'झोप' }, sortOrder: 2, isActive: true },
  { id: 'cat_status_festival', module: 'status', name: { en: 'Festival', hi: 'त्योहार', mr: 'सण' }, sortOrder: 1, isActive: true },
];

/** Builds a common ContentItem-shaped record; `extra` merges type-specific fields. */
function contentItem({ id, type, teacherIds, categoryId, title, artist, mediaUrl, thumbUrl, extra }) {
  return {
    id,
    type,
    teacherIds,
    categoryId: categoryId ?? null,
    title,
    artist: artist ?? null,
    mediaUrl,
    thumbUrl,
    storagePath: null,
    language: type === 'wallpaper' || type === 'status' ? null : 'en',
    status: 'published',
    sortOrder: 10,
    isFeatured: false,
    isPremium: false,
    tags: [],
    counters: { views: 0, downloads: 0, shares: 0, plays: 0 },
    source: 'seed-placeholder',
    licence: 'placeholder-not-for-production',
    publishAt: now(),
    expireAt: null,
    createdBy: 'seed-script',
    createdAt: now(),
    updatedAt: now(),
    deletedAt: null,
    ...extra,
  };
}

const wallpapers = [
  contentItem({
    id: 'wp_001', type: 'wallpaper', teacherIds: ['buddha'], categoryId: 'cat_wp_calm',
    title: { en: 'Golden Buddha', hi: 'स्वर्ण बुद्ध', mr: 'सुवर्ण बुद्ध' },
    mediaUrl: PLACEHOLDER_IMG('wp1', 1080, 1920), thumbUrl: PLACEHOLDER_IMG('wp1', 400, 700),
    extra: { wallpaper: { kind: 'static', width: 1080, height: 1920, orientation: 'portrait' } },
  }),
  contentItem({
    id: 'wp_002', type: 'wallpaper', teacherIds: ['ambedkar'], categoryId: 'cat_wp_quotes',
    title: { en: 'Babasaheb Quote', hi: 'बाबासाहेब उद्धरण', mr: 'बाबासाहेब उद्धरण' },
    mediaUrl: PLACEHOLDER_IMG('wp2', 1080, 1920), thumbUrl: PLACEHOLDER_IMG('wp2', 400, 700),
    extra: { wallpaper: { kind: 'static', width: 1080, height: 1920, orientation: 'portrait' } },
  }),
  contentItem({
    id: 'wp_003', type: 'wallpaper', teacherIds: ['dalai_lama'], categoryId: 'cat_wp_calm',
    title: { en: 'Peaceful Mind', hi: 'शांत मन', mr: 'शांत मन' },
    mediaUrl: PLACEHOLDER_IMG('wp3', 1080, 1920), thumbUrl: PLACEHOLDER_IMG('wp3', 400, 700),
    extra: { wallpaper: { kind: 'static', width: 1080, height: 1920, orientation: 'portrait' } },
  }),
];

const ringtones = [
  contentItem({
    id: 'rt_001', type: 'ringtone', teacherIds: ['buddha'], categoryId: null,
    title: { en: 'Namo Tassa Ringtone', hi: 'नमो तस्स रिंगटोन', mr: 'नमो तस्स रिंगटोन' },
    artist: 'Anonymous', mediaUrl: PLACEHOLDER_AUDIO, thumbUrl: PLACEHOLDER_IMG('rt1', 200, 200),
    extra: { audio: { durationSec: 31 } },
  }),
  contentItem({
    id: 'rt_002', type: 'ringtone', teacherIds: ['buddha'], categoryId: null,
    title: { en: 'Buddham Sarnam Gacchami', hi: 'बुद्धं सरणं गच्छामि', mr: 'बुद्धं सरणं गच्छामि' },
    artist: 'Anonymous', mediaUrl: PLACEHOLDER_AUDIO, thumbUrl: PLACEHOLDER_IMG('rt2', 200, 200),
    extra: { audio: { durationSec: 29 } },
  }),
];

const songs = [
  contentItem({
    id: 'sg_001', type: 'song', teacherIds: ['buddha'], categoryId: null,
    title: { en: 'Jayamangal Sutta', hi: 'जयमंगल सुत्त', mr: 'जयमंगल सुत्त' },
    artist: 'Pawa', mediaUrl: PLACEHOLDER_AUDIO, thumbUrl: PLACEHOLDER_IMG('sg1', 200, 200),
    extra: { audio: { durationSec: 180 } },
  }),
  contentItem({
    id: 'sg_002', type: 'song', teacherIds: ['ambedkar'], categoryId: null,
    title: { en: 'Buddha Ki Dharti', hi: 'बुद्ध की धरती', mr: 'बुद्धाची भूमी' },
    artist: 'Anonymous', mediaUrl: PLACEHOLDER_AUDIO, thumbUrl: PLACEHOLDER_IMG('sg2', 200, 200),
    extra: { audio: { durationSec: 210 } },
  }),
];

const meditations = [
  contentItem({
    id: 'md_001', type: 'meditation', teacherIds: ['buddha'], categoryId: 'cat_med_anapana',
    title: { en: 'AnaPana Meditation - Part 1', hi: 'आनापान ध्यान - भाग 1', mr: 'आनापान ध्यान - भाग 1' },
    artist: 'S.N. Goenka', mediaUrl: PLACEHOLDER_AUDIO, thumbUrl: PLACEHOLDER_IMG('md1', 200, 200),
    extra: { audio: { durationSec: 600, seriesId: 'series_anapana', partNumber: 1, level: 'beginner' } },
  }),
  contentItem({
    id: 'md_002', type: 'meditation', teacherIds: ['buddha'], categoryId: 'cat_med_anapana',
    title: { en: 'AnaPana Meditation - Part 2', hi: 'आनापान ध्यान - भाग 2', mr: 'आनापान ध्यान - भाग 2' },
    artist: 'S.N. Goenka', mediaUrl: PLACEHOLDER_AUDIO, thumbUrl: PLACEHOLDER_IMG('md2', 200, 200),
    extra: { audio: { durationSec: 600, seriesId: 'series_anapana', partNumber: 2, level: 'beginner' } },
  }),
  contentItem({
    id: 'md_003', type: 'meditation', teacherIds: ['thich_nhat_hanh'], categoryId: 'cat_med_sleep',
    title: { en: '10 minutes Stress relief Meditation - Part 1', hi: '10 मिनट तनाव मुक्ति ध्यान - भाग 1', mr: '10 मिनिटे ताण मुक्ती ध्यान - भाग 1' },
    artist: 'Anonymous', mediaUrl: PLACEHOLDER_AUDIO, thumbUrl: PLACEHOLDER_IMG('md3', 200, 200),
    extra: { audio: { durationSec: 600, level: 'beginner' } },
  }),
];

const statuses = [
  contentItem({
    id: 'st_001', type: 'status', teacherIds: ['buddha'], categoryId: 'cat_status_festival',
    title: { en: 'Dhyan', hi: 'ध्यान', mr: 'ध्यान' },
    mediaUrl: PLACEHOLDER_STATUS, thumbUrl: PLACEHOLDER_STATUS,
    extra: {
      statusMeta: {
        photoFrame: { x: 0.62, y: 0.7, w: 0.22, h: 0.22 },
        nameText: { x: 0.06, y: 0.88, w: 0.55, align: 'left', font: 'Poppins', size: 0.045, color: '#FDF3E0', weight: 700 },
        watermark: true,
        festivalDate: null,
      },
    },
  }),
];

const prarthanas = [
  contentItem({
    id: 'pr_001', type: 'prarthana', teacherIds: ['buddha'], categoryId: null,
    title: { en: 'Morning Prarthana', hi: 'प्रातः प्रार्थना', mr: 'सकाळची प्रार्थना' },
    artist: 'Anonymous', mediaUrl: PLACEHOLDER_AUDIO, thumbUrl: PLACEHOLDER_IMG('pr1', 200, 200),
    extra: { audio: { durationSec: 300 } },
  }),
];

const appConfig = {
  minSupportedVersion: '1.0.0',
  latestVersion: '1.0.0',
  forceUpdate: false,
  maintenanceMode: false,
  maintenanceMessage: { en: '', hi: '', mr: '' },
  languages: [
    { code: 'en', name: 'English', native: 'English' },
    { code: 'hi', name: 'Hindi', native: 'हिन्दी' },
    { code: 'mr', name: 'Marathi', native: 'मराठी' },
  ],
  adsEnabled: false,
  idCardEnabled: false,
  liveWallpaperEnabled: false,
  updatedAt: now(),
};

async function main() {
  console.log(`Seeding Firestore project: ${projectId}`);
  const accessToken = getAccessToken();
  const db = new FirestoreRestClient(projectId, accessToken);

  for (const teacher of teachers) {
    const { id, ...fields } = teacher;
    await db.setDocument('teachers', id, fields);
    console.log(`  teachers/${id}`);
  }

  for (const category of categories) {
    const { id, ...fields } = category;
    await db.setDocument('categories', id, fields);
    console.log(`  categories/${id}`);
  }

  const contentByCollection = {
    wallpapers,
    ringtones,
    songs,
    meditations,
    statuses,
    prarthanas,
  };

  for (const [collection, items] of Object.entries(contentByCollection)) {
    for (const item of items) {
      const { id, ...fields } = item;
      await db.setDocument(collection, id, fields);
      console.log(`  ${collection}/${id}`);
    }
  }

  await db.setDocument('config', 'app_config', appConfig);
  console.log('  config/app_config');

  const homeLayout = {
    modules: [
      { id: 'wallpaper', visible: true },
      { id: 'meditation', visible: true },
      { id: 'ringtone', visible: true },
      { id: 'song', visible: true },
      { id: 'prarthana', visible: true },
      { id: 'status', visible: true },
    ],
    updatedAt: now(),
  };
  await db.setDocument('config', 'home_layout', homeLayout);
  console.log('  config/home_layout');

  const staticPages = [
    {
      id: 'about',
      title: { en: 'About Us', hi: 'हमारे बारे में', mr: 'आमच्याबद्दल' },
      body: {
        en: 'Dhamma Path brings Buddhist wallpapers, ringtones, songs, meditation and daily prarthana into one respectful app.',
        hi: 'धम्म पथ बौद्ध वॉलपेपर, रिंगटोन, गीत, ध्यान और दैनिक प्रार्थना को एक सम्मानजनक ऐप में लाता है।',
        mr: 'धम्म पथ बौद्ध वॉलपेपर, रिंगटोन, गाणी, ध्यान आणि दैनिक प्रार्थना एका सन्माननीय अॅपमध्ये आणतो.',
      },
      updatedAt: now(),
    },
    {
      id: 'privacy',
      title: { en: 'Privacy Policy', hi: 'गोपनीयता नीति', mr: 'गोपनीयता धोरण' },
      body: {
        en: 'We store only what is needed to run your account: name, phone or email, language, selected teachers and alarms.',
        hi: 'हम केवल खाता चलाने के लिए ज़रूरी जानकारी रखते हैं।',
        mr: 'आम्ही खाते चालवण्यासाठी लागणारी माहिती ठेवतो.',
      },
      updatedAt: now(),
    },
    {
      id: 'terms',
      title: { en: 'Terms & Conditions', hi: 'नियम और शर्तें', mr: 'नियम आणि अटी' },
      body: {
        en: 'Use Dhamma Path respectfully. Content is for personal devotion.',
        hi: 'धम्म पथ का सम्मान के साथ उपयोग करें।',
        mr: 'धम्म पथाचा आदराने वापर करा.',
      },
      updatedAt: now(),
    },
    {
      id: 'contact',
      title: { en: 'Contact', hi: 'संपर्क', mr: 'संपर्क' },
      body: {
        en: '<p>Use Contact Us in the app Profile to send us a message.</p>',
        hi: '<p>संदेश भेजने के लिए ऐप प्रोफ़ाइल में संपर्क करें का उपयोग करें।</p>',
        mr: '<p>संदेश पाठवण्यासाठी अॅप प्रोफाइलमधील संपर्क वापरा.</p>',
      },
      updatedAt: now(),
    },
    {
      id: 'help',
      title: { en: 'Help', hi: 'सहायता', mr: 'मदत' },
      body: {
        en: '<h2>Daily Prarthana</h2><p>Set a time in the app. Allow exact alarms if Android asks.</p><h2>Ringtones</h2><p>Android needs Write Settings permission to change the default tone.</p>',
        hi: '<h2>दैनिक प्रार्थना</h2><p>ऐप में समय सेट करें।</p>',
        mr: '<h2>दैनिक प्रार्थना</h2><p>अॅपमध्ये वेळ सेट करा.</p>',
      },
      updatedAt: now(),
    },
  ];
  for (const page of staticPages) {
    const { id, ...fields } = page;
    await db.setDocument('staticPages', id, fields);
    console.log(`  staticPages/${id}`);
  }

  console.log('\nSeed complete.');
  console.log(
    `Wrote ${teachers.length} teachers, ${categories.length} categories, ` +
      `${wallpapers.length + ringtones.length + songs.length + meditations.length + statuses.length + prarthanas.length} content items, 2 config docs.`,
  );
}

main().catch((err) => {
  console.error('Seed failed:', err.message);
  process.exit(1);
});
