import 'dart:async';

/// Presets for the meditation sleep timer (FR-10.4 / T2.49).
abstract class SleepTimerPresets {
  SleepTimerPresets._();

  static const minutes = [5, 10, 15, 30, 60];
}

/// Counts down, then calls [onElapsed]. Lives on the shared audio handler
/// so it keeps running if the user leaves the full player.
class SleepTimer {
  SleepTimer({
    required this.onElapsed,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final void Function() onElapsed;
  final DateTime Function() _clock;

  Timer? _fire;
  Timer? _tick;
  DateTime? _endsAt;
  Duration? _chosen;
  final _remaining = StreamController<Duration?>.broadcast();

  Stream<Duration?> get remainingStream async* {
    yield remaining;
    yield* _remaining.stream;
  }

  Duration? get remaining {
    final ends = _endsAt;
    if (ends == null) return null;
    final left = ends.difference(_clock());
    return left.isNegative ? Duration.zero : left;
  }

  Duration? get chosen => isActive ? _chosen : null;

  bool get isActive => _endsAt != null;

  void start(Duration duration) {
    cancel();
    if (duration <= Duration.zero) return;
    _chosen = duration;
    _endsAt = _clock().add(duration);
    _remaining.add(duration);
    _fire = Timer(duration, _elapsed);
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      _remaining.add(remaining);
    });
  }

  void cancel() {
    _fire?.cancel();
    _tick?.cancel();
    _fire = null;
    _tick = null;
    _endsAt = null;
    _chosen = null;
    if (!_remaining.isClosed) {
      _remaining.add(null);
    }
  }

  void dispose() {
    cancel();
    _remaining.close();
  }

  void _elapsed() {
    _fire?.cancel();
    _tick?.cancel();
    _fire = null;
    _tick = null;
    _endsAt = null;
    _chosen = null;
    if (!_remaining.isClosed) {
      _remaining.add(null);
    }
    onElapsed();
  }
}
