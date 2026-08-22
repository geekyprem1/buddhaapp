import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'zoom_controller.g.dart';

/// Accessibility text zoom for low-vision editors (WCAG 1.4.4 resize text).
/// The value multiplies every text size in the desk via [MediaQuery.textScaler]
/// and is persisted so the choice survives a refresh or sign-out.
const double kMinZoom = 1.0;
const double kMaxZoom = 2.0;
const double kZoomStep = 0.1;
const double _defaultZoom = 1.0;

const String _zoomPrefKey = 'admin.accessibility.textZoom';

/// Injected in `main` with a real [SharedPreferences] instance.
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) =>
    throw UnimplementedError('Override sharedPreferencesProvider in main().');

@Riverpod(keepAlive: true)
class ZoomController extends _$ZoomController {
  @override
  double build() {
    final stored = ref.watch(sharedPreferencesProvider).getDouble(_zoomPrefKey);
    return _clamp(stored ?? _defaultZoom);
  }

  /// Whether zoom can still step up / down (used to disable buttons at limits).
  bool get canIncrease => state < kMaxZoom - 0.0001;
  bool get canDecrease => state > kMinZoom + 0.0001;

  void increase() => _set(state + kZoomStep);
  void decrease() => _set(state - kZoomStep);
  void reset() => _set(_defaultZoom);

  void _set(double value) {
    final next = _clamp(double.parse(value.toStringAsFixed(2)));
    if (next == state) return;
    state = next;
    ref.read(sharedPreferencesProvider).setDouble(_zoomPrefKey, next);
  }

  double _clamp(double value) =>
      value.clamp(kMinZoom, kMaxZoom).toDouble();
}
