import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Returns the current user or null if not logged in.
  User? get currentUser => _supabase.auth.currentUser;

  /// Listen to auth state changes.
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Sign Up with Email and Password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? username,
    required String phone,
    required String role,
    String? birthDate,
    String? nik,
  }) async {
    // We store extra data in metadata first.
    // The Trigger in Supabase will copy this to the public.profiles table.
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'username': username,
        'phone': phone,
        'role': role,
        'birth_date': birthDate,
        'nik': nik,
      },
    );
  }

  Future<void> updateShopDetails({
    required String shopName,
    required String shopAddress,
    required String shopDescription,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw 'User not logged in';

    await _supabase
        .from('profiles')
        .update({
          'shop_name': shopName,
          'shop_address': shopAddress,
          'shop_description': shopDescription,
        })
        .eq('id', user.id);
  }

  /// Helper to get email by identity (username or shopName)
  Future<String> _getEmailByIdentity({
    String? username,
    String? shopName,
  }) async {
    // Call the RPC function we defined in Supabase
    final response = await _supabase.rpc(
      'get_email_by_identity',
      params: {'p_username': username, 'p_shop_name': shopName},
    );

    if (response == null) {
      throw 'User not found';
    }
    return response as String;
  }

  /// Sign In with Username (for Pembeli)
  Future<AuthResponse> signInWithUsername({
    required String username,
    required String password,
  }) async {
    final email = await _getEmailByIdentity(username: username);
    return await signInWithPassword(email: email, password: password);
  }

  /// Sign In with Shop Name (for Penjual)
  /// Note: The UI asks for "Nama Lengkap" (Full Name) and "Nama Toko".
  /// For login, "Nama Toko" is the unique identifier we rely on.
  /// "Nama Lengkap" acts as a verification field or just extra confirmation.
  Future<AuthResponse> signInSeller({
    required String shopName,
    required String
    fullName, // Included for flow consistency, could verify against profile if needed
    required String password,
  }) async {
    final email = await _getEmailByIdentity(shopName: shopName);

    // Optional: Verify full name matches if needed, but for now we just rely on password auth.
    // If strict verification is needed, we'd need to fetch the profile after login.

    return await signInWithPassword(email: email, password: password);
  }

  /// Sign In with Email and Password (Low-level)
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign In with OTP (Phone)
  Future<void> signInWithOtp({required String phone}) async {
    await _supabase.auth.signInWithOtp(
      phone: phone,
      // If using email OTP, use email: email
    );
  }

  /// Verify OTP (Email)
  Future<AuthResponse> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    return await _supabase.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.signup,
    );
  }

  /// Verify OTP (Phone)
  Future<AuthResponse> verifyOtp({
    required String phone,
    required String token,
  }) async {
    return await _supabase.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
  }

  /// Sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
