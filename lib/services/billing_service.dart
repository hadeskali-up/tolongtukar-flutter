import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'settings_service.dart';
class BillingService {
  BillingService(this.settings); final SettingsService settings; static const productId='remove_ads'; StreamSubscription<List<PurchaseDetails>>? _sub;
  Future<void> initialize(void Function(bool) changed) async { _sub=InAppPurchase.instance.purchaseStream.listen((items) async { for(final p in items){if(p.productID==productId&&p.status==PurchaseStatus.purchased){await settings.putBool(SettingsService.isPro,true);changed(true);}if(p.pendingCompletePurchase)await InAppPurchase.instance.completePurchase(p);} }); await restore(changed); }
  Future<String?> buy(void Function(bool) changed) async { if(!await InAppPurchase.instance.isAvailable())return 'Google Play Billing unavailable'; final r=await InAppPurchase.instance.queryProductDetails({productId}); if(r.productDetails.isEmpty)return "Product 'remove_ads' not found. Add it in Play Console."; final ok=await InAppPurchase.instance.buyNonConsumable(purchaseParam:PurchaseParam(productDetails:r.productDetails.first)); return ok?null:'Unable to launch purchase'; }
  Future<void> restore(void Function(bool) changed) async { await InAppPurchase.instance.restorePurchases(); }
  Future<void> dispose() async=>_sub?.cancel();
}
