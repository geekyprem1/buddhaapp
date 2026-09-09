import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Live `config/premium` doc for the admin premium settings page.
final adminPremiumConfigProvider = StreamProvider<PremiumConfig>((ref) {
  return ref.watch(configRepositoryProvider).watchPremiumConfig();
});
