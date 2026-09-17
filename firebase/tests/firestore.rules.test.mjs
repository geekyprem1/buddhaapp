import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc, updateDoc, deleteDoc, collection, addDoc, Timestamp } from 'firebase/firestore';

const here = dirname(fileURLToPath(import.meta.url));
const RULES = readFileSync(resolve(here, '../firestore.rules'), 'utf8');

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'dhamma-path-rules',
    firestore: { rules: RULES },
  });
});

after(async () => {
  await env?.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
});

function anon() {
  return env.unauthenticatedContext().firestore();
}

function user(uid = 'user1') {
  return env.authenticatedContext(uid).firestore();
}

function role(uid, roleName) {
  return env.authenticatedContext(uid, { role: roleName }).firestore();
}

async function seedPublishedWallpaper() {
  await env.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), 'wallpapers/w1'), {
      status: 'published',
      title: { en: 'Lotus' },
      counters: { views: 0, downloads: 0, shares: 0, plays: 0 },
    });
    await setDoc(doc(ctx.firestore(), 'wallpapers/draft1'), {
      status: 'draft',
      title: { en: 'Hidden' },
      counters: { views: 0, downloads: 0, shares: 0, plays: 0 },
    });
  });
}

describe('Firestore rules', () => {
  it('denies anonymous reads of published content', async () => {
    await seedPublishedWallpaper();
    await assertFails(getDoc(doc(anon(), 'wallpapers/w1')));
  });

  it('lets a signed-in user read published content only', async () => {
    await seedPublishedWallpaper();
    await assertSucceeds(getDoc(doc(user(), 'wallpapers/w1')));
    await assertFails(getDoc(doc(user(), 'wallpapers/draft1')));
  });

  it('blocks a regular user from creating content', async () => {
    await assertFails(
      setDoc(doc(user(), 'wallpapers/hack'), {
        status: 'published',
        title: { en: 'Nope' },
      }),
    );
  });

  it('lets a content_manager create content', async () => {
    await assertSucceeds(
      setDoc(doc(role('ed1', 'content_manager'), 'wallpapers/new1'), {
        status: 'draft',
        title: { en: 'Draft' },
      }),
    );
  });

  it('applies the same published-read rules to vandanas', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'vandanas/v1'), {
        status: 'published',
        title: { en: 'Namo Tassa' },
        counters: { views: 0, downloads: 0, shares: 0, plays: 0 },
      });
      await setDoc(doc(ctx.firestore(), 'vandanas/draft1'), {
        status: 'draft',
        title: { en: 'Hidden' },
        counters: { views: 0, downloads: 0, shares: 0, plays: 0 },
      });
    });
    await assertFails(getDoc(doc(anon(), 'vandanas/v1')));
    await assertSucceeds(getDoc(doc(user(), 'vandanas/v1')));
    await assertFails(getDoc(doc(user(), 'vandanas/draft1')));
    await assertSucceeds(
      setDoc(doc(role('ed1', 'content_manager'), 'vandanas/new1'), {
        status: 'draft',
        title: { en: 'Draft' },
      }),
    );
  });

  it('blocks client writes to counters', async () => {
    await seedPublishedWallpaper();
    await assertFails(
      updateDoc(doc(role('ed1', 'content_manager'), 'wallpapers/w1'), {
        counters: { views: 99 },
      }),
    );
  });

  it('lets the owner read their user doc and not someone else', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'users/user1'), { name: 'A' });
      await setDoc(doc(ctx.firestore(), 'users/user2'), { name: 'B' });
    });
    await assertSucceeds(getDoc(doc(user('user1'), 'users/user1')));
    await assertFails(getDoc(doc(user('user1'), 'users/user2')));
  });

  it('blocks the owner from flipping isBlocked', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'users/user1'), {
        name: 'A',
        isBlocked: false,
      });
    });
    await assertFails(
      updateDoc(doc(user('user1'), 'users/user1'), { isBlocked: true }),
    );
    await assertSucceeds(
      updateDoc(doc(role('sa', 'super_admin'), 'users/user1'), {
        isBlocked: true,
      }),
    );
  });

  it('lets the owner create a user doc without entitlement fields', async () => {
    await assertSucceeds(
      setDoc(doc(user('user1'), 'users/user1'), {
        name: 'A',
        isBlocked: false,
      }),
    );
  });

  it('blocks the owner from seeding premium on create (B1)', async () => {
    await assertFails(
      setDoc(doc(user('user1'), 'users/user1'), {
        name: 'A',
        premiumUntil: Timestamp.fromMillis(Date.now() + 86_400_000),
      }),
    );
    await assertFails(
      setDoc(doc(user('user1'), 'users/user1'), {
        name: 'A',
        premiumToken: 'tok_1',
      }),
    );
  });

  it('blocks the owner from writing entitlement fields on update (B1)', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'users/user1'), { name: 'A' });
    });
    await assertFails(
      updateDoc(doc(user('user1'), 'users/user1'), {
        premiumUntil: Timestamp.fromMillis(Date.now() + 86_400_000),
      }),
    );
  });

  it('lets signed-in users create valid events but never read them', async () => {
    const ref = await assertSucceeds(
      addDoc(collection(user(), 'events'), {
        collection: 'songs',
        itemId: 's1',
        type: 'play',
        createdAt: Timestamp.now(),
      }),
    );
    await assertFails(getDoc(doc(user(), `events/${ref.id}`)));
  });

  it('denies malformed events (B15)', async () => {
    const events = collection(user(), 'events');
    await assertFails(
      addDoc(events, {
        collection: 'songs',
        itemId: 's1',
        type: 'play',
      }),
    );
    await assertFails(
      addDoc(events, {
        collection: 'songs',
        itemId: 'x/y',
        type: 'play',
        createdAt: Timestamp.now(),
      }),
    );
    await assertFails(
      addDoc(events, {
        collection: 'songs',
        itemId: 's1',
        type: 'not-a-type',
        createdAt: Timestamp.now(),
      }),
    );
  });

  it('blocks stealing or deleting someone else\'s id card (B4)', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'idCards/c1'), { uid: 'user1' });
    });
    await assertFails(
      setDoc(doc(user('user2'), 'idCards/c1'), { uid: 'user2' }),
    );
    await assertFails(deleteDoc(doc(user('user2'), 'idCards/c1')));
    await assertSucceeds(deleteDoc(doc(user('user1'), 'idCards/c1')));
  });

  it('denies all client access to purchaseTokens', async () => {
    await assertFails(getDoc(doc(user(), 'purchaseTokens/abc')));
    await assertFails(
      setDoc(doc(user(), 'purchaseTokens/abc'), { uid: 'user1' }),
    );
  });

  it('denies all client access to otpGuards', async () => {
    await assertFails(getDoc(doc(user(), 'otpGuards/91xxxxxxxxxx')));
    await assertFails(
      setDoc(doc(user(), 'otpGuards/91xxxxxxxxxx'), { count: 0 }),
    );
    await assertFails(
      getDoc(doc(role('sa', 'super_admin'), 'otpGuards/91xxxxxxxxxx')),
    );
  });

  it('denies all client access to aiUsage', async () => {
    // The daily AI quota counter is Function-only; a user must not be able to
    // read or reset their own allowance.
    await assertFails(getDoc(doc(user(), 'aiUsage/user1_2026-09-16')));
    await assertFails(
      setDoc(doc(user(), 'aiUsage/user1_2026-09-16'), { usedSeconds: 0 }),
    );
    await assertFails(
      updateDoc(doc(user(), 'aiUsage/user1_2026-09-16'), { usedSeconds: 0 }),
    );
    await assertFails(
      getDoc(doc(role('sa', 'super_admin'), 'aiUsage/user1_2026-09-16')),
    );
  });

  it('lets a user create their own contact message, not read the inbox', async () => {
    await assertSucceeds(
      addDoc(collection(user('user1'), 'contactMessages'), {
        uid: 'user1',
        subject: 'Hi',
        message: 'Help',
      }),
    );
    await assertFails(getDoc(doc(user('user1'), 'contactMessages/anything')));
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'contactMessages/m1'), {
        uid: 'user1',
        subject: 'Hi',
        message: 'Help',
      });
    });
    await assertSucceeds(
      getDoc(doc(role('sa', 'super_admin'), 'contactMessages/m1')),
    );
  });

  it('restricts config writes to super_admin', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'config/app_config'), {
        forceUpdate: false,
      });
    });
    await assertSucceeds(getDoc(doc(user(), 'config/app_config')));
    await assertFails(
      setDoc(doc(role('ed1', 'content_manager'), 'config/app_config'), {
        forceUpdate: true,
      }),
    );
    await assertSucceeds(
      setDoc(doc(role('sa', 'super_admin'), 'config/app_config'), {
        forceUpdate: true,
      }),
    );
  });

  it('blocks client writes to auditLogs', async () => {
    await assertFails(
      setDoc(doc(role('sa', 'super_admin'), 'auditLogs/x'), {
        action: 'create',
      }),
    );
  });

  it('lets the owner create a deletion request', async () => {
    await assertSucceeds(
      setDoc(doc(user('user1'), 'deletionRequests/user1'), {
        uid: 'user1',
        status: 'pending',
      }),
    );
    await assertFails(
      setDoc(doc(user('user1'), 'deletionRequests/user2'), {
        uid: 'user2',
        status: 'pending',
      }),
    );
  });

  it('hides inactive teachers from regular users', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'teachers/t1'), {
        isActive: true,
        sortOrder: 1,
      });
      await setDoc(doc(ctx.firestore(), 'teachers/t2'), {
        isActive: false,
        sortOrder: 2,
      });
    });
    await assertSucceeds(getDoc(doc(user(), 'teachers/t1')));
    await assertFails(getDoc(doc(user(), 'teachers/t2')));
    await assertSucceeds(
      getDoc(doc(role('ed1', 'content_manager'), 'teachers/t2')),
    );
  });

  it('restricts hard delete of content to super_admin', async () => {
    await seedPublishedWallpaper();
    await assertFails(deleteDoc(doc(role('ed1', 'content_manager'), 'wallpapers/w1')));
    await assertSucceeds(
      deleteDoc(doc(role('sa', 'super_admin'), 'wallpapers/w1')),
    );
  });
});
