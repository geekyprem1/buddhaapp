import 'package:core/core.dart';

/// Route paths and role gates (AR-1.2, AR-1.4). UI hiding is convenience;
/// Firestore rules are the real lock.
abstract class AdminRoutes {
  AdminRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const teachers = '/teachers';
  static const categories = '/categories';
  static const wallpapers = '/content/wallpapers';
  static const ringtones = '/content/ringtones';
  static const songs = '/content/songs';
  static const meditations = '/content/meditations';
  static const statuses = '/content/statuses';
  static const prarthanas = '/content/prarthanas';
  static const users = '/users';
  static const notifications = '/notifications';
  static const config = '/config';
  static const pages = '/pages';
  static const audit = '/audit';
  static const contact = '/contact';
}

class AdminDestination {
  const AdminDestination({
    required this.path,
    required this.label,
    required this.allowed,
  });

  final String path;
  final String label;
  final bool Function(String role) allowed;
}

/// Ordered left-nav. Filter with [visibleFor].
const adminDestinations = <AdminDestination>[
  AdminDestination(
    path: AdminRoutes.dashboard,
    label: 'Dashboard',
    allowed: AdminRole.isAdmin,
  ),
  AdminDestination(
    path: AdminRoutes.teachers,
    label: 'Teachers',
    allowed: AdminRole.canEditContent,
  ),
  AdminDestination(
    path: AdminRoutes.categories,
    label: 'Categories',
    allowed: AdminRole.canEditContent,
  ),
  AdminDestination(
    path: AdminRoutes.wallpapers,
    label: 'Wallpapers',
    allowed: AdminRole.canModerate,
  ),
  AdminDestination(
    path: AdminRoutes.ringtones,
    label: 'Ringtones',
    allowed: AdminRole.canModerate,
  ),
  AdminDestination(
    path: AdminRoutes.songs,
    label: 'Songs',
    allowed: AdminRole.canModerate,
  ),
  AdminDestination(
    path: AdminRoutes.meditations,
    label: 'Meditations',
    allowed: AdminRole.canModerate,
  ),
  AdminDestination(
    path: AdminRoutes.statuses,
    label: 'Statuses',
    allowed: AdminRole.canModerate,
  ),
  AdminDestination(
    path: AdminRoutes.prarthanas,
    label: 'Prarthanas',
    allowed: AdminRole.canModerate,
  ),
  AdminDestination(
    path: AdminRoutes.users,
    label: 'Users',
    allowed: AdminRole.canManageUsers,
  ),
  AdminDestination(
    path: AdminRoutes.notifications,
    label: 'Notifications',
    allowed: AdminRole.canSendNotifications,
  ),
  AdminDestination(
    path: AdminRoutes.config,
    label: 'App config',
    allowed: AdminRole.canEditConfig,
  ),
  AdminDestination(
    path: AdminRoutes.pages,
    label: 'Static pages',
    allowed: AdminRole.canEditConfig,
  ),
  AdminDestination(
    path: AdminRoutes.audit,
    label: 'Audit log',
    allowed: AdminRole.isAdmin,
  ),
  AdminDestination(
    path: AdminRoutes.contact,
    label: 'Contact inbox',
    allowed: AdminRole.isAdmin,
  ),
];

List<AdminDestination> visibleFor(String role) =>
    adminDestinations.where((d) => d.allowed(role)).toList();

bool canOpenPath(String location, String role) {
  AdminDestination? match;
  for (final dest in adminDestinations) {
    if (location == dest.path || location.startsWith('${dest.path}/')) {
      if (match == null || dest.path.length > match.path.length) {
        match = dest;
      }
    }
  }
  if (match == null) return AdminRole.isAdmin(role);
  return match.allowed(role);
}

/// Single-place admin gate. Screens never check auth themselves.
String? resolveAdminRedirect({
  required bool authLoading,
  required bool roleLoading,
  required bool signedIn,
  required String? role,
  required String location,
}) {
  if (authLoading || (signedIn && roleLoading)) {
    return location == AdminRoutes.splash ? null : AdminRoutes.splash;
  }

  final allowedIn = AdminRole.isAdmin(role);
  if (!signedIn || !allowedIn) {
    return location == AdminRoutes.login ? null : AdminRoutes.login;
  }

  if (location == AdminRoutes.login || location == AdminRoutes.splash) {
    return AdminRoutes.dashboard;
  }

  if (!canOpenPath(location, role!)) {
    return AdminRoutes.dashboard;
  }
  return null;
}
