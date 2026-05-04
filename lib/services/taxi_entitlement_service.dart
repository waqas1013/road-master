import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Access rules for taxi **personal progress** (Hem, Statistik) and **slutprov**.
///
/// Subscription is stored in [SharedPreferences] (`taxi_subscription_active`). Wire your
/// in-app purchase / backend to call [setTaxiSubscriptionActive] when a purchase validates.
class TaxiEntitlementService {
  TaxiEntitlementService._();
  static final TaxiEntitlementService instance = TaxiEntitlementService._();

  static const _prefKey = 'taxi_subscription_active';

  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  /// Whether practice stats on Hem / Statistik should reflect this device (requires account).
  bool get canViewPersonalTaxiProgress => isLoggedIn;

  /// Call when IAP or your backend confirms an active taxi plan for the signed-in user.
  Future<void> setTaxiSubscriptionActive(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_prefKey, value);
  }

  /// Active taxi subscription for the current **signed-in** user (local mirror until you add server truth).
  Future<bool> hasActiveTaxiSubscription() async {
    if (!isLoggedIn) return false;
    final p = await SharedPreferences.getInstance();
    if (p.containsKey(_prefKey)) {
      return p.getBool(_prefKey)!;
    }
    // Dev: allow flow without store; release: require explicit purchase flag.
    if (kDebugMode) return true;
    return false;
  }

  Future<bool> canStartSlutprov() async =>
      isLoggedIn && await hasActiveTaxiSubscription();
}
