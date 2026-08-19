/// Typed analytics wrapper for the PRD §11 event taxonomy (T0.14 / T2.72).
///
/// The default instance is a no-op so unit tests and the admin panel do
/// not need Firebase Analytics. Apps override [analyticsServiceProvider]
/// with a sink that forwards to `FirebaseAnalytics.logEvent`.
class AnalyticsService {
  AnalyticsService({AnalyticsSink? sink}) : _sink = sink ?? _noop;

  final AnalyticsSink _sink;

  Future<void> _log(String name, [Map<String, Object>? params]) {
    return _sink(name, params);
  }

  Future<void> appOpen() => _log('app_open');

  Future<void> onboardingStepView({required String step}) =>
      _log('onboarding_step_view', {'step': step});

  Future<void> onboardingComplete({
    required String language,
    required List<String> teachers,
  }) => _log('onboarding_complete', {
    'language': language,
    'teachers': teachers.join(','),
  });

  Future<void> loginAttempt({required String method}) =>
      _log('login_attempt', {'method': method});

  Future<void> loginSuccess({required String method}) =>
      _log('login_success', {'method': method});

  Future<void> loginFail({required String method, required String reason}) =>
      _log('login_fail', {'method': method, 'reason': reason});

  Future<void> moduleOpen({required String module}) =>
      _log('module_open', {'module': module});

  Future<void> teacherFilterChange({required String teacher}) =>
      _log('teacher_filter_change', {'teacher': teacher});

  Future<void> wallpaperView({required String id}) =>
      _log('wallpaper_view', {'id': id});

  Future<void> wallpaperSet({required String id, required String target}) =>
      _log('wallpaper_set', {'id': id, 'target': target});

  Future<void> wallpaperDownload({required String id}) =>
      _log('wallpaper_download', {'id': id});

  Future<void> ringtonePreview({required String id}) =>
      _log('ringtone_preview', {'id': id});

  Future<void> ringtoneSet({required String id, required String target}) =>
      _log('ringtone_set', {'id': id, 'target': target});

  Future<void> songPlay({required String id}) => _log('song_play', {'id': id});

  Future<void> songComplete({required String id}) =>
      _log('song_complete', {'id': id});

  Future<void> meditationPlay({
    required String id,
    required int durationListened,
  }) => _log('meditation_play', {
    'id': id,
    'duration_listened': durationListened,
  });

  Future<void> statusPhotoAdded() => _log('status_photo_added');

  Future<void> statusDownload({required String id}) =>
      _log('status_download', {'id': id});

  Future<void> statusShare({required String id, required String channel}) =>
      _log('status_share', {'id': id, 'channel': channel});

  Future<void> prarthanaSet({
    required String time,
    required String days,
    required String songId,
  }) => _log('prarthana_set', {'time': time, 'days': days, 'songId': songId});

  Future<void> prarthanaFired() => _log('prarthana_fired');

  Future<void> prarthanaSnooze() => _log('prarthana_snooze');

  Future<void> shareApp() => _log('share_app');

  Future<void> permissionPrompt({
    required String type,
    required String result,
  }) => _log('permission_prompt', {'type': type, 'result': result});

  Future<void> notificationReceived({required String campaignId}) =>
      _log('notification_received', {'campaignId': campaignId});

  Future<void> notificationOpen({required String campaignId}) =>
      _log('notification_open', {'campaignId': campaignId});

  Future<void> error({required String code, required String screen}) =>
      _log('error', {'code': code, 'screen': screen});
}

typedef AnalyticsSink =
    Future<void> Function(String name, Map<String, Object>? params);

Future<void> _noop(String name, Map<String, Object>? params) async {}
