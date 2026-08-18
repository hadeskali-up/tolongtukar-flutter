import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'settings_service.dart';

class BillingService {
  BillingService(this.settings);
  final SettingsService settings;
  static const productId = 'remove_ads';
  StreamSubscription<List<PurchaseDetails>>? _sub;

  Future<void> initialize(void Function(bool) changed) async {
    _sub = InAppPurchase.instance.purchaseStream.listen((items) async {
      for (final purchase in items) {
        final entitled = purchase.productID == productId &&
            (purchase.status == PurchaseStatus.purchased ||
                purchase.status == PurchaseStatus.restored);
        if (entitled) {
          await settings.putBool(SettingsService.isPro, true);
          changed(true);
        }
        if (purchase.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchase);
        }
      }
    });
    await restore(changed);
  }

  Future<String?> buy(void Function(bool) changed) async {
    if (!await InAppPurchase.instance.isAvailable()) {
      return 'Google Play Billing unavailable';
    }
    final result = await InAppPurchase.instance.queryProductDetails({productId});
    if (result.productDetails.isEmpty) {
      return "Product 'remove_ads' not found. Add it in Play Console.";
    }
    final ok = await InAppPurchase.instance.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: result.productDetails.first),
    );
    return ok ? null : 'Unable to launch purchase';
  }

  Future<void> restore(void Function(bool) changed) async {
    await InAppPurchase.instance.restorePurchases();
  }

  Future<void> dispose() async => _sub?.cancel();
}
