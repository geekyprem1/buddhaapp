import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import 'premium_controller.dart';

/// Returns true if the user may proceed with a premium action. If they are
/// not premium, opens the paywall and returns false so the caller aborts.
///
/// Use at the point of the *locked* action:
///  - wallpaper / ringtone: when the user taps "Set"
///  - song / meditation / chanting / vandana / video: when the user opens/plays
bool ensurePremium(WidgetRef ref, BuildContext context) {
  final isPremium = ref.read(premiumControllerProvider);
  if (isPremium) return true;
  context.push(AppRoutes.premium);
  return false;
}
