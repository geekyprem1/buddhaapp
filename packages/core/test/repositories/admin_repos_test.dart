import 'package:core/core.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore firestore;

  setUp(() {
    firestore = FakeFirebaseFirestore();
  });

  group('CategoryRepository', () {
    test('create then watchByModule returns the row in sort order', () async {
      final repo = CategoryRepository(firestore: firestore);
      await repo.create(
        const Category(
          id: '',
          module: 'wallpaper',
          name: LocalisedText(en: 'Calm'),
          sortOrder: 2,
        ),
      );
      await repo.create(
        const Category(
          id: '',
          module: 'wallpaper',
          name: LocalisedText(en: 'Festival'),
          sortOrder: 1,
        ),
      );
      await repo.create(
        const Category(
          id: '',
          module: 'song',
          name: LocalisedText(en: 'Bhajan'),
        ),
      );

      final wallpapers = await repo.getByModule('wallpaper');
      expect(wallpapers, hasLength(2));
      expect(wallpapers.first.name.en, 'Festival');
      expect(wallpapers.last.name.en, 'Calm');
    });

    test('inactive categories are hidden unless activeOnly is false', () async {
      final repo = CategoryRepository(firestore: firestore);
      await repo.create(
        const Category(
          id: '',
          module: 'meditation',
          name: LocalisedText(en: 'Archived'),
          isActive: false,
        ),
      );

      expect(await repo.getByModule('meditation'), isEmpty);
      expect(
        await repo.getByModule('meditation', activeOnly: false),
        hasLength(1),
      );
    });
  });

  group('ConfigRepository', () {
    test('missing doc yields defaults; save then get round-trips flags', () async {
      final repo = ConfigRepository(firestore: firestore);
      final initial = await repo.getAppConfig();
      expect(initial.forceUpdate, isFalse);
      expect(initial.adsEnabled, isFalse);

      await repo.saveAppConfig(
        const AppConfig(forceUpdate: true, minSupportedVersion: '1.2.0'),
      );
      final saved = await repo.getAppConfig();
      expect(saved.forceUpdate, isTrue);
      expect(saved.minSupportedVersion, '1.2.0');
    });

    test('missing home layout yields defaults; save round-trips order', () async {
      final repo = ConfigRepository(firestore: firestore);
      final initial = await repo.getHomeLayout();
      expect(initial.modules.map((m) => m.id), HomeModuleIds.all);

      await repo.saveHomeLayout(
        const HomeLayout(
          modules: [
            HomeModule(id: HomeModuleIds.prarthana),
            HomeModule(id: HomeModuleIds.wallpaper, visible: false),
          ],
        ),
      );
      final saved = await repo.getHomeLayout();
      expect(saved.modules.first.id, HomeModuleIds.prarthana);
      expect(
        saved.modules.firstWhere((m) => m.id == HomeModuleIds.wallpaper).visible,
        isFalse,
      );
      expect(saved.modules.map((m) => m.id), containsAll(HomeModuleIds.all));
    });
  });

  group('StaticPageRepository', () {
    test('upsert then get returns the authored body', () async {
      final repo = StaticPageRepository(firestore: firestore);
      await repo.upsert(
        const StaticPage(
          slug: 'privacy',
          title: LocalisedText(en: 'Privacy'),
          body: LocalisedText(en: 'We do not sell your data.'),
        ),
      );

      final page = await repo.get('privacy');
      expect(page, isNotNull);
      expect(page!.title.en, 'Privacy');
      expect(page.body.en, contains('do not sell'));
    });
  });

  group('AdminUserRepository', () {
    test('upsert then get returns the role', () async {
      final repo = AdminUserRepository(firestore: firestore);
      await repo.upsert(
        const AdminUser(
          uid: 'adm1',
          email: 'anita@dhammapath.app',
          name: 'Anita',
          role: AdminRole.contentManager,
        ),
      );
      final user = await repo.get('adm1');
      expect(user?.role, AdminRole.contentManager);
      expect(user?.email, 'anita@dhammapath.app');
    });
  });

  group('AuditRepository', () {
    test('fetchPage returns newest first', () async {
      await firestore.collection(FirestoreCollections.auditLogs).add({
        'actorUid': 'a1',
        'action': 'create',
        'entityType': 'teachers',
        'entityId': 'buddha',
        'createdAt': DateTime(2026, 1, 1),
      });
      await firestore.collection(FirestoreCollections.auditLogs).add({
        'actorUid': 'a1',
        'action': 'update',
        'entityType': 'teachers',
        'entityId': 'buddha',
        'createdAt': DateTime(2026, 2, 1),
      });

      final repo = AuditRepository(firestore: firestore);
      final page = await repo.fetchPage(entityType: 'teachers');
      expect(page, hasLength(2));
      expect(page.first.action, 'update');
    });
  });

  group('NotificationRepository', () {
    test('saveDraft then watchAll returns the campaign', () async {
      final repo = NotificationRepository(firestore: firestore);
      final id = await repo.saveDraft(
        title: 'Namo Buddhay',
        body: 'A new meditation is live.',
        audience: NotificationAudience.all,
        createdBy: 'admin1',
      );
      final rows = await repo.watchAll().first;
      expect(rows, hasLength(1));
      expect(rows.first.id, id);
      expect(rows.first.title, 'Namo Buddhay');
      expect(rows.first.status, NotificationCampaignStatus.draft);
    });

    test('cancelSchedule flips a queued campaign back to draft', () async {
      await firestore.collection(FirestoreCollections.notifications).doc('n1').set({
        'title': 'Queued',
        'body': 'Later',
        'audience': 'all',
        'status': NotificationCampaignStatus.scheduled,
        'scheduledAt': DateTime(2026, 8, 19, 6),
        'createdAt': DateTime(2026, 8, 18),
        'deliveredCount': 0,
        'openedCount': 0,
      });
      final repo = NotificationRepository(firestore: firestore);
      await repo.cancelSchedule('n1');
      final campaign = await repo.getById('n1');
      expect(campaign?.status, NotificationCampaignStatus.draft);
      expect(campaign?.scheduledAt, isNull);
    });
  });

  group('StoragePaths', () {
    test('content paths follow Architecture §6.4', () {
      expect(
        StoragePaths.contentOriginal('wallpapers', 'wp_1', 'png'),
        'wallpapers/wp_1/original.png',
      );
      expect(StoragePaths.teacherPortrait('buddha'), 'teachers/buddha/portrait.webp');
      expect(StoragePaths.userAvatar('u1'), 'users/u1/avatar.webp');
      expect(
        StoragePaths.notificationImage('n1', 'png'),
        'notifications/n1/image.png',
      );
    });

    test('fromDownloadUrl recovers the object path', () {
      const url =
          'https://firebasestorage.googleapis.com/v0/b/dhamma-path-prod.firebasestorage.app/o/wallpapers%2Fabc%2Foriginal.jpeg?alt=media&token=dead';
      expect(
        StoragePaths.fromDownloadUrl(url),
        'wallpapers/abc/original.jpeg',
      );
      expect(StoragePaths.coercePath(url), 'wallpapers/abc/original.jpeg');
      expect(
        StoragePaths.coercePath('wallpapers/abc/full.webp'),
        'wallpapers/abc/full.webp',
      );
      expect(StoragePaths.coercePath(null), isNull);
    });
  });

  group('ContentRepository', () {
    test('update can leave media fields untouched', () async {
      await firestore.collection('wallpapers').doc('wp_1').set({
        'type': 'wallpaper',
        'title': {'en': 'Lotus'},
        'status': 'published',
        'mediaUrl': 'https://example.com/full.webp',
        'thumbUrl': 'https://example.com/thumb.webp',
        'storagePath': 'wallpapers/wp_1/full.webp',
        'sortOrder': 0,
      });
      final repo = ContentRepository(
        collectionName: 'wallpapers',
        firestore: firestore,
      );
      await repo.update(
        const ContentItem(
          id: 'wp_1',
          type: ContentType.wallpaper,
          title: LocalisedText(en: 'Lotus bloom'),
          mediaUrl: null,
          thumbUrl: 'https://stale.example/original.jpeg',
          storagePath: 'https://stale.example/original.jpeg',
        ),
        unchangedKeys: ['mediaUrl', 'thumbUrl', 'storagePath'],
      );
      final saved = await repo.getById('wp_1');
      expect(saved?.title.en, 'Lotus bloom');
      expect(saved?.mediaUrl, 'https://example.com/full.webp');
      expect(saved?.thumbUrl, 'https://example.com/thumb.webp');
      expect(saved?.storagePath, 'wallpapers/wp_1/full.webp');
    });

    test('watchAdminPage emits after a later media patch', () async {
      final repo = ContentRepository(
        collectionName: 'wallpapers',
        firestore: firestore,
      );
      await firestore.collection('wallpapers').doc('wp_1').set({
        'type': 'wallpaper',
        'title': {'en': '9'},
        'status': 'published',
        'sortOrder': 1,
      });
      final stream = repo.watchAdminPage();
      final first = await stream.first;
      expect(first.single.thumbUrl, isNull);

      await firestore.collection('wallpapers').doc('wp_1').update({
        'thumbUrl': 'https://example.com/thumb.webp',
        'mediaUrl': 'https://example.com/full.webp',
      });
      final next = await stream.firstWhere(
        (rows) => rows.single.thumbUrl != null,
      );
      expect(next.single.thumbUrl, 'https://example.com/thumb.webp');
    });

    // Regression: a freshly uploaded wallpaper "disappeared" from the desk.
    // The admin query used orderBy('sortOrder').limit(100): Firestore drops
    // docs with no sortOrder, and a new item (sortOrder 0) ranked below the
    // 100 already-ordered rows, so it fell outside the page.
    test('fetchAdminPage lists items past the old 100 cap', () async {
      for (var i = 1; i <= 120; i++) {
        await firestore.collection('wallpapers').doc('wp_$i').set({
          'type': 'wallpaper',
          'title': {'en': 'Old $i'},
          'status': 'published',
          'sortOrder': i,
        });
      }
      // The newly uploaded item, left at the default sortOrder.
      await firestore.collection('wallpapers').doc('fresh').set({
        'type': 'wallpaper',
        'title': {'en': 'Fresh upload'},
        'status': 'draft',
        'sortOrder': 0,
      });
      final repo = ContentRepository(
        collectionName: 'wallpapers',
        firestore: firestore,
      );
      final rows = await repo.fetchAdminPage();
      expect(rows, hasLength(121));
      expect(rows.map((r) => r.id), contains('fresh'));
    });

    test('fetchAdminPage keeps docs that have no sortOrder field', () async {
      await firestore.collection('wallpapers').doc('no_sort').set({
        'type': 'wallpaper',
        'title': {'en': 'No sortOrder'},
        'status': 'published',
      });
      final repo = ContentRepository(
        collectionName: 'wallpapers',
        firestore: firestore,
      );
      final rows = await repo.fetchAdminPage();
      expect(rows.map((r) => r.id), ['no_sort']);
    });

    test('fetchAdminPage skips an undecodable half-written doc', () async {
      // What `onMediaUpload` leaves behind when its patch lands on a doc that
      // no longer has the admin-written fields: no `type`, no `title`.
      await firestore.collection('wallpapers').doc('ghost').set({
        'mediaUrl': 'https://example.com/full.webp',
        'thumbUrl': 'https://example.com/thumb.webp',
      });
      await firestore.collection('wallpapers').doc('good').set({
        'type': 'wallpaper',
        'title': {'en': 'Good'},
        'status': 'published',
        'sortOrder': 3,
      });
      final repo = ContentRepository(
        collectionName: 'wallpapers',
        firestore: firestore,
      );
      final rows = await repo.fetchAdminPage();
      expect(rows.map((r) => r.id), ['good']);
    });

    test('nextSortOrder puts a new item above everything stored', () async {
      await firestore.collection('wallpapers').doc('wp_1').set({
        'type': 'wallpaper',
        'title': {'en': 'Top'},
        'status': 'published',
        'sortOrder': 100,
      });
      final repo = ContentRepository(
        collectionName: 'wallpapers',
        firestore: firestore,
      );
      expect(await repo.nextSortOrder(), 101);
    });

    test('nextSortOrder starts at 1 for an empty collection', () async {
      final repo = ContentRepository(
        collectionName: 'wallpapers',
        firestore: firestore,
      );
      expect(await repo.nextSortOrder(), 1);
    });

    // Regression: the admin form never edits createdAt / createdBy /
    // publishAt / teacherIds, so a form-built item carries nulls. Writing
    // those nulls wiped the stored values (140 of 146 production wallpapers
    // had lost createdAt).
    test('update does not wipe fields the form never edits', () async {
      final created = DateTime.utc(2026, 1, 2, 3, 4);
      await firestore.collection('wallpapers').doc('wp_1').set({
        'type': 'wallpaper',
        'title': {'en': 'Lotus'},
        'status': 'published',
        'sortOrder': 5,
        'createdAt': created,
        'createdBy': 'admin_uid',
        'publishAt': created,
        'teacherIds': ['t_1'],
      });
      final repo = ContentRepository(
        collectionName: 'wallpapers',
        firestore: firestore,
      );
      await repo.update(
        const ContentItem(
          id: 'wp_1',
          type: ContentType.wallpaper,
          title: LocalisedText(en: 'Lotus bloom'),
          status: ContentStatus.published,
          sortOrder: 5,
        ),
      );
      final saved = await repo.getById('wp_1');
      expect(saved?.title.en, 'Lotus bloom');
      expect(saved?.createdAt?.toUtc(), created);
      expect(saved?.createdBy, 'admin_uid');
      expect(saved?.publishAt?.toUtc(), created);
      expect(saved?.teacherIds, ['t_1']);
    });
  });

  group('AnalyticsService', () {
    test('typed helpers emit the PRD §11 event names', () async {
      final seen = <String>[];
      final analytics = AnalyticsService(
        sink: (name, params) async => seen.add(name),
      );
      await analytics.loginAttempt(method: 'email');
      await analytics.loginFail(method: 'email', reason: 'not_admin');
      await analytics.loginSuccess(method: 'email');
      expect(seen, ['login_attempt', 'login_fail', 'login_success']);
    });
  });
}
