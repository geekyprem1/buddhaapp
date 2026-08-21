/// Parses FCM `data` into an in-app route or an external URL (T2.71).
class PushTarget {
  const PushTarget({this.route, this.externalUrl});

  final String? route;
  final Uri? externalUrl;
}

const _moduleRoutes = <String, String>{
  'home': '/home',
  'wallpaper': '/wallpapers',
  'wallpapers': '/wallpapers',
  'ringtone': '/ringtones',
  'ringtones': '/ringtones',
  'song': '/songs',
  'songs': '/songs',
  'meditation': '/meditations',
  'meditations': '/meditations',
  'chanting': '/chanting',
  'chantings': '/chanting',
  'status': '/statuses',
  'statuses': '/statuses',
  'prarthana': '/prarthana',
  'profile': '/profile',
};

PushTarget parsePushData(Map<String, dynamic> data) {
  final rawUrl = data['url']?.toString();
  if (rawUrl != null && rawUrl.isNotEmpty) {
    final uri = Uri.tryParse(rawUrl);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return PushTarget(externalUrl: uri);
    }
  }
  final route = data['route']?.toString();
  if (route != null && route.startsWith('/')) {
    return PushTarget(route: route);
  }
  final module = data['module']?.toString().toLowerCase();
  return PushTarget(route: _moduleRoutes[module] ?? '/home');
}

abstract class FcmTopics {
  FcmTopics._();

  static const all = 'all';

  static String language(String code) => 'lang_${_safe(code)}';

  static String teacher(String id) => 'teacher_${_safe(id)}';

  static Set<String> forUser({
    required String language,
    required List<String> teacherIds,
    required bool pushEnabled,
  }) {
    if (!pushEnabled) return {};
    return {
      all,
      FcmTopics.language(language),
      for (final id in teacherIds) FcmTopics.teacher(id),
    };
  }

  static String _safe(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return cleaned.isEmpty ? 'unknown' : cleaned;
  }
}
