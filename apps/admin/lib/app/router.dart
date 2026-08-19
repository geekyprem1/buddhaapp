import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/auth/application/admin_session.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/splash_page.dart';
import '../features/audit/presentation/audit_log_page.dart';
import '../features/categories/presentation/categories_list_page.dart';
import '../features/categories/presentation/category_form_page.dart';
import '../features/contact/presentation/contact_inbox_page.dart';
import '../features/content/application/content_type_config.dart';
import '../features/content/presentation/bulk_upload_page.dart';
import '../features/content/presentation/content_form_page.dart';
import '../features/content/presentation/content_list_page.dart';
import '../features/content/presentation/status_layout_editor_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/config/presentation/config_page.dart';
import '../features/notifications/presentation/notification_composer_page.dart';
import '../features/notifications/presentation/notifications_list_page.dart';
import '../features/pages/presentation/page_editor_page.dart';
import '../features/pages/presentation/pages_list_page.dart';
import '../features/users/presentation/users_list_page.dart';
import '../features/teachers/presentation/teacher_form_page.dart';
import '../features/teachers/presentation/teachers_list_page.dart';
import '../widgets/idle_timeout_listener.dart';
import 'admin_access.dart';
import 'admin_shell.dart';

part 'router.g.dart';

@riverpod
GoRouter adminRouter(Ref ref) {
  final refresh = _RouterRefreshNotifier();
  ref.listen(authStateProvider, (_, __) => refresh.ping());
  ref.listen(adminRoleProvider, (_, __) => refresh.ping());
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AdminRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      final roleAsync = ref.read(adminRoleProvider);
      return resolveAdminRedirect(
        authLoading: auth.isLoading,
        // Riverpod keeps the previous `null` role while refreshing after
        // sign-in (`skipLoadingOnRefresh`). Treat that as still loading or
        // a signed-in admin is bounced back to login.
        roleLoading: roleAsync.isLoading || roleAsync.isRefreshing,
        signedIn: auth.valueOrNull != null,
        role: roleAsync.valueOrNull,
        location: state.matchedLocation,
      );
    },
    routes: [
      GoRoute(
        path: AdminRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AdminRoutes.login,
        builder: (context, state) => LoginPage(
          idleExpired: state.uri.queryParameters['reason'] == 'idle',
        ),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return IdleTimeoutListener(
            timeout: const Duration(hours: 12),
            onTimeout: () async {
              ref.read(idleSignOutProvider.notifier).state = true;
              await ref.read(authServiceProvider).signOut();
            },
            child: AdminShell(child: child),
          );
        },
        routes: [
          GoRoute(
            path: AdminRoutes.dashboard,
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: AdminRoutes.teachers,
            builder: (context, state) => const TeachersListPage(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const TeacherFormPage(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => TeacherFormPage(
                  teacherId: state.pathParameters['id'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: AdminRoutes.categories,
            builder: (context, state) => const CategoriesListPage(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const CategoryFormPage(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => CategoryFormPage(
                  categoryId: state.pathParameters['id'],
                ),
              ),
            ],
          ),
          ..._contentRoutes(),
          GoRoute(
            path: AdminRoutes.users,
            builder: (context, state) => const UsersListPage(),
          ),
          GoRoute(
            path: AdminRoutes.notifications,
            builder: (context, state) => const NotificationsListPage(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const NotificationComposerPage(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => NotificationComposerPage(
                  campaignId: state.pathParameters['id'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: AdminRoutes.config,
            builder: (context, state) => const ConfigPage(),
          ),
          GoRoute(
            path: AdminRoutes.audit,
            builder: (context, state) => const AuditLogPage(),
          ),
          GoRoute(
            path: AdminRoutes.contact,
            builder: (context, state) => const ContactInboxPage(),
          ),
          GoRoute(
            path: AdminRoutes.pages,
            builder: (context, state) => const PagesListPage(),
            routes: [
              GoRoute(
                path: ':slug',
                builder: (context, state) => PageEditorPage(
                  slug: state.pathParameters['slug'] ?? '',
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

List<GoRoute> _contentRoutes() {
  return [
    for (final config in contentTypeConfigs)
      GoRoute(
        path: config.route,
        builder: (context, state) => ContentListPage(config: config),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => ContentFormPage(config: config),
          ),
          GoRoute(
            path: 'bulk',
            builder: (context, state) => BulkUploadPage(config: config),
          ),
          if (config.hasStatusMeta)
            GoRoute(
              path: ':id/layout',
              builder: (context, state) => StatusLayoutEditorPage(
                config: config,
                itemId: state.pathParameters['id']!,
              ),
            ),
          GoRoute(
            path: ':id',
            builder: (context, state) => ContentFormPage(
              config: config,
              itemId: state.pathParameters['id'],
            ),
          ),
        ],
      ),
  ];
}

class _RouterRefreshNotifier extends ChangeNotifier {
  void ping() => notifyListeners();
}
