import 'package:supabase_flutter/supabase_flutter.dart';

/// Wraps Supabase Auth for the two entry points the prototype offers:
/// phone OTP ("Kirim kode OTP" / "Verifikasi & masuk") and guest
/// ("Lanjut sebagai guest"). Guests get a real (anonymous) Supabase
/// session — via `signInAnonymously` — so their cart/orders/loyalty still
/// live in the real backend and can later be upgraded to a phone account
/// with `verifyOtp`'s implicit identity-linking.
class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;
  bool get isGuest => currentUser?.isAnonymous ?? false;
  bool get isSignedIn => currentUser != null && !isGuest;

  /// Sends an OTP. When called by a guest (anonymous session), this links
  /// the phone number to the *same* user id via `updateUser` instead of
  /// starting a fresh sign-in — so their cart/orders/loyalty history
  /// carries over instead of being orphaned under a new id.
  Future<void> sendOtp(String phoneE164) {
    if (isGuest) {
      return _client.auth.updateUser(UserAttributes(phone: phoneE164));
    }
    return _client.auth.signInWithOtp(phone: phoneE164);
  }

  Future<void> verifyOtp({required String phoneE164, required String code}) async {
    final type = isGuest ? OtpType.phoneChange : OtpType.sms;
    await _client.auth.verifyOTP(phone: phoneE164, token: code, type: type);
  }

  Future<void> continueAsGuest() async {
    if (_client.auth.currentUser == null) {
      await _client.auth.signInAnonymously();
    }
  }

  Future<void> signOut() => _client.auth.signOut();
}
