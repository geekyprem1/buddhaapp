import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'billing_service.dart';

/// The billing wrapper (single instance for the app lifetime).
final billingServiceProvider = Provider<BillingService>((ref) {
  return BillingService();
});

/// The premium (subscription) config from Firestore — currently just the
/// admin-uploaded promo video shown on the premium screen.
final premiumConfigProvider = StreamProvider<PremiumConfig>((ref) {
  return ref.watch(configRepositoryProvider).watchPremiumConfig();
});

/// Holds and persists the user's premium entitlement.
///
/// Client-side (per product decision): entitlement flips true when the store
/// reports an active/restored purchase for the subscription. The last known
/// value is cached in Hive so a returning subscriber isn't briefly locked out
/// before the store responds.
final premiumControllerProvider =
    NotifierProvider<PremiumController, bool>(PremiumController.new);

class PremiumController extends Notifier<bool> {
  static const _prefsKey = 'is_premium';

  StreamSubscription<List<PurchaseDetails>>? _sub;

  @override
  bool build() {
    final billing = ref.watch(billingServiceProvider);

    _sub = billing.purchaseStream.listen(_onPurchases);
    ref.onDispose(() => _sub?.cancel());

    // Kick off product load + restore so returning subscribers are recognised
    // without any tap. Errors are non-fatal (store may be unavailable).
    unawaited(_init(billing));

    return _cached();
  }

  bool _cached() {
    try {
      return Hive.box('app_prefs').get(_prefsKey) == true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _init(BillingService billing) async {
    try {
      if (!await billing.isAvailable()) return;
      await billing.loadProduct();
      await billing.restore();
    } catch (_) {
      // Ignore — cached value stands until the store responds.
    }
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    final billing = ref.read(billingServiceProvider);
    var granted = state;
    for (final p in purchases) {
      if (BillingService.grantsEntitlement(p)) {
        granted = true;
      }
      // Always finish handled purchases so Play stops re-notifying.
      await billing.complete(p);
    }
    if (granted != state) _setPremium(granted);
  }

  void _setPremium(bool value) {
    state = value;
    try {
      Hive.box('app_prefs').put(_prefsKey, value);
    } catch (_) {}
  }

  /// Launch the purchase flow. Returns false if the store couldn't start it.
  /// Entitlement is granted asynchronously via [purchaseStream].
  Future<bool> subscribe() async {
    try {
      return await ref.read(billingServiceProvider).buy();
    } catch (_) {
      return false;
    }
  }

  /// Re-deliver past purchases (the "Restore purchases" action).
  Future<void> restore() async {
    try {
      await ref.read(billingServiceProvider).restore();
    } catch (_) {}
  }
}
