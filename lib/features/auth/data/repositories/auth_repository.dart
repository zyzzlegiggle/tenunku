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
    required String phone,
    required String role,
  }) async {
    // We store extra data in metadata first.
    // The Trigger in Supabase will copy this to the public.profiles table.
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'phone': phone, 'role': role},
    );
  }

  /// Sign In with Email and Password
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
