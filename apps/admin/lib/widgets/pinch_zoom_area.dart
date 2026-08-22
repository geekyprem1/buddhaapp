import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/accessibility/application/zoom_controller.dart';

/// Two-finger pinch that drives the crisp text-zoom ([ZoomController]) instead
/// of the browser's blurry canvas zoom. Uses a passive [Listener] so it never
/// steals single-finger taps or scrolls — only a genuine two-pointer pinch is
/// treated as a zoom. On desktop (no touch) it stays completely inert.
class PinchZoomArea extends ConsumerStatefulWidget {
  const PinchZoomArea({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<PinchZoomArea> createState() => _PinchZoomAreaState();
}

class _PinchZoomAreaState extends ConsumerState<PinchZoomArea> {
  final Map<int, Offset> _pointers = {};
  double? _startDistance;
  double _startZoom = 1.0;
  bool _pinching = false;

  void _onDown(PointerDownEvent event) {
    _pointers[event.pointer] = event.position;
    if (_pointers.length == 2) _beginPinch();
  }

  void _beginPinch() {
    final points = _pointers.values.toList();
    _startDistance = (points[0] - points[1]).distance;
    _startZoom = ref.read(zoomControllerProvider);
    _pinching = _startDistance! > 0;
  }

  void _onMove(PointerMoveEvent event) {
    if (!_pointers.containsKey(event.pointer)) return;
    _pointers[event.pointer] = event.position;
    if (!_pinching || _pointers.length < 2 || _startDistance == null) return;

    final points = _pointers.values.toList();
    final distance = (points[0] - points[1]).distance;
    final factor = distance / _startDistance!;
    ref.read(zoomControllerProvider.notifier).previewZoom(_startZoom * factor);
  }

  void _onEnd(PointerEvent event) {
    final wasPinching = _pinching;
    _pointers.remove(event.pointer);
    if (_pointers.length < 2 && wasPinching) {
      _pinching = false;
      _startDistance = null;
      ref.read(zoomControllerProvider.notifier).commitZoom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onDown,
      onPointerMove: _onMove,
      onPointerUp: _onEnd,
      onPointerCancel: _onEnd,
      child: widget.child,
    );
  }
}
