import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// Server-authoritative premium entitlement.
///
/// The `verifyPurchase` / RTDN Cloud Functions write `users/{uid}.premiumUntil`
/// (a Timestamp) after verifying with the Play Developer API. The app trusts
/// ONLY that field: premium == `premiumUntil` is in the future. This is why a
/// cancelled/expired/refunded subscription reliably drops the paywall back in
/// (the client purchase cache can no longer grant access on its own).
final premiumControllerProvider =
    NotifierProvider<PremiumController, bool>(PremiumController.new);

class PremiumController extends Notifier<bool> {
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSub;
  Timer? _expiryTimer;
  DateTime? _premiumUntil;

  @override
  bool build() {
    final billing = ref.watch(billingServiceProvider);

    // The store purchase stream is only a *trigger*: when a purchase is
    // delivered/restored we ask the server to (re)verify it. The server's
    // premiumUntil is the source of truth, not this event.
    _purchaseSub = billing.purchaseStream.listen(_onPurchases);

    _listenToUserDoc();

    ref.onDispose(() {
      _purchaseSub?.cancel();
      _userSub?.cancel();
      _expiryTimer?.cancel();
    });

    // Nudge the store to replay purchases so a returning subscriber gets
    // re-verified even if they reinstalled. Non-fatal.
    unawaited(_refreshFromStore(billing));

    return false;
  }

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  void _listenToUserDoc() {
    _userSub?.cancel();
    final uid = _uid;
    if (uid == null) {
      _apply(null);
      return;
    }
    _userSub = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snap) {
      final raw = snap.data()?['premiumUntil'];
      DateTime? until;
      if (raw is Timestamp) until = raw.toDate();
      _apply(until);
    }, onError: (_) {});
  }

  /// Applies a new expiry: updates entitlement now and schedules a flip to
  /// false exactly when it expires (so access ends without needing a relaunch).
  void _apply(DateTime? until) {
    _premiumUntil = until;
    _expiryTimer?.cancel();
    final now = DateTime.now();
    final active = until != null && until.isAfter(now);
    if (state != active) state = active;
    if (active) {
      final d = until.difference(now);
      // Cap the timer so very long durations don't overflow.
      final delay = d > const Duration(days: 1) ? const Duration(days: 1) : d;
      _expiryTimer = Timer(delay + const Duration(seconds: 1), () {
        _apply(_premiumUntil); // re-evaluate (turns false once past expiry)
      });
    }
  }

  Future<void> _refreshFromStore(BillingService billing) async {
    try {
      if (!await billing.isAvailable()) return;
      await billing.loadProduct();
      await billing.restore();
    } catch (_) {}
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    final billing = ref.read(billingServiceProvider);
    for (final p in purchases) {
      if (BillingService.concernsOurProduct(p) &&
          (p.status == PurchaseStatus.purchased ||
              p.status == PurchaseStatus.restored)) {
        await _verify(p);
      }
      await billing.complete(p);
    }
  }

  /// Sends the purchase token to the server for authoritative verification.
  /// The resulting premiumUntil arrives back via the user-doc listener.
  Future<void> _verify(PurchaseDetails purchase) async {
    final token = purchase.verificationData.serverVerificationData;
    if (token.isEmpty) return;
    try {
      final fn = FirebaseFunctions.instanceFor(
        region: AppConstants.functionsRegion,
      ).httpsCallable('verifyPurchase');
      await fn.call<Map<String, dynamic>>({
        'productId': purchase.productID,
        'purchaseToken': token,
      });
    } catch (_) {
      // Non-fatal — RTDN or a later refresh will reconcile.
    }
  }

  /// Launch the purchase flow. Returns false if the store couldn't start it.
  /// Entitlement is granted after server verification (via the user-doc
  /// listener), not here.
  Future<bool> subscribe() async {
    try {
      return await ref.read(billingServiceProvider).buy();
    } catch (_) {
      return false;
    }
  }

  /// Re-check: replay purchases (→ re-verify) and re-attach the user listener.
  Future<void> refreshFromStore() async {
    _listenToUserDoc();
    await _refreshFromStore(ref.read(billingServiceProvider));
  }

  /// Kept for the "Restore purchases" button.
  Future<void> restore() => refreshFromStore();
}
