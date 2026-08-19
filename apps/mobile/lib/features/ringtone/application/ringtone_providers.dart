import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../platform/ringtone_service.dart';

part 'ringtone_providers.g.dart';

@Riverpod(keepAlive: true)
RingtoneService ringtoneService(Ref ref) => RingtoneService();

/// Survives the WRITE_SETTINGS activity so we can finish the set on resume.
@Riverpod(keepAlive: true)
class PendingRingtone extends _$PendingRingtone {
  @override
  PendingRingtoneSet? build() => null;

  void hold(PendingRingtoneSet pending) => state = pending;

  void clear() => state = null;
}
