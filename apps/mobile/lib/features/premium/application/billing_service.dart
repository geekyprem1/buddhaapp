import 'dart:async';

import 'package:core/core.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Thin wrapper over [InAppPurchase] for the single monthly subscription.
///
/// Client-side only (per product decision): the app trusts an active/restored
/// purchase for the subscription product to grant entitlement. Server-side
/// verification via the Play Developer API can be layered on later without
/// changing the UI.
class BillingService {
  BillingService({InAppPurchase? iap})
      : _iap = iap ?? InAppPurchase.instance;

  final InAppPurchase _iap;

  static const _productId = PremiumProducts.monthlySubscriptionId;

  ProductDetails? _product;
  ProductDetails? get product => _product;

  Stream<List<PurchaseDetails>> get purchaseStream => _iap.purchaseStream;

  Future<bool> isAvailable() => _iap.isAvailable();

  /// Loads the subscription product from the store. Safe to call repeatedly.
  Future<ProductDetails?> loadProduct() async {
    if (!await _iap.isAvailable()) return null;
    final response = await _iap.queryProductDetails({_productId});
    if (response.productDetails.isEmpty) return null;
    _product = response.productDetails.first;
    return _product;
  }

  /// Launches the Play purchase flow for the subscription.
  Future<bool> buy() async {
    final product = _product ?? await loadProduct();
    if (product == null) return false;
    final param = PurchaseParam(productDetails: product);
    // Subscriptions use buyNonConsumable in in_app_purchase.
    return _iap.buyNonConsumable(purchaseParam: param);
  }

  /// Re-delivers past purchases (used by "Restore purchases").
  Future<void> restore() => _iap.restorePurchases();

  /// Acknowledge/complete a delivered purchase so Play stops re-notifying.
  Future<void> complete(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }

  /// True when a purchase for our subscription is in a granting state.
  static bool grantsEntitlement(PurchaseDetails p) {
    return p.productID == _productId &&
        (p.status == PurchaseStatus.purchased ||
            p.status == PurchaseStatus.restored);
  }
}
