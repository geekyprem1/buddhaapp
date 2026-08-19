import 'package:core/core.dart';
import 'package:dhamma_path_admin/app/admin_access.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveAdminRedirect', () {
    test('holds on splash while auth is loading', () {
      expect(
        resolveAdminRedirect(
          authLoading: true,
          roleLoading: false,
          signedIn: false,
          role: null,
          location: AdminRoutes.splash,
        ),
        isNull,
      );
      expect(
        resolveAdminRedirect(
          authLoading: true,
          roleLoading: false,
          signedIn: false,
          role: null,
          location: AdminRoutes.dashboard,
        ),
        AdminRoutes.splash,
      );
    });

    test('signed-out users are sent to login', () {
      expect(
        resolveAdminRedirect(
          authLoading: false,
          roleLoading: false,
          signedIn: false,
          role: null,
          location: AdminRoutes.users,
        ),
        AdminRoutes.login,
      );
    });

    test('signed-in without an admin claim is treated as signed-out', () {
      expect(
        resolveAdminRedirect(
          authLoading: false,
          roleLoading: false,
          signedIn: true,
          role: null,
          location: AdminRoutes.dashboard,
        ),
        AdminRoutes.login,
      );
    });

    test('admin on login is sent to the dashboard', () {
      expect(
        resolveAdminRedirect(
          authLoading: false,
          roleLoading: false,
          signedIn: true,
          role: AdminRole.contentManager,
          location: AdminRoutes.login,
        ),
        AdminRoutes.dashboard,
      );
    });

    test('content manager cannot open the users table', () {
      expect(
        resolveAdminRedirect(
          authLoading: false,
          roleLoading: false,
          signedIn: true,
          role: AdminRole.contentManager,
          location: AdminRoutes.users,
        ),
        AdminRoutes.dashboard,
      );
    });

    test('super admin can open the users table', () {
      expect(
        resolveAdminRedirect(
          authLoading: false,
          roleLoading: false,
          signedIn: true,
          role: AdminRole.superAdmin,
          location: AdminRoutes.users,
        ),
        isNull,
      );
    });
  });

  group('visibleFor', () {
    test('hides user management from content managers', () {
      final paths = visibleFor(AdminRole.contentManager).map((d) => d.path);
      expect(paths, isNot(contains(AdminRoutes.users)));
      expect(paths, contains(AdminRoutes.teachers));
      expect(paths, isNot(contains(AdminRoutes.config)));
    });

    test('moderators see content lists but not teacher CRUD', () {
      final paths = visibleFor(AdminRole.moderator).map((d) => d.path);
      expect(paths, contains(AdminRoutes.wallpapers));
      expect(paths, isNot(contains(AdminRoutes.teachers)));
      expect(paths, contains(AdminRoutes.dashboard));
    });
  });
}
