import 'package:supabase_flutter/supabase_flutter.dart';

class UserSettingsRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get user settings (language, etc.)
  Future<Map<String, dynamic>?> getUserSettings(String userId) async {
    try {
      final data = await _supabase
          .from('user_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      return data;
    } catch (e) {
      return null;
    }
  }

  /// Save or update language preference
  Future<void> saveLanguage(String userId, String language) async {
    final existing = await getUserSettings(userId);

    if (existing == null) {
      // Insert new settings
      await _supabase.from('user_settings').insert({
        'user_id': userId,
        'language': language,
      });
    } else {
      // Update existing
      await _supabase
          .from('user_settings')
          .update({'language': language})
          .eq('user_id', userId);
    }
  }

  /// Get notification settings
  Future<Map<String, dynamic>> getNotificationSettings(String userId) async {
    final settings = await getUserSettings(userId);
    if (settings != null && settings['notification_preferences'] != null) {
      return Map<String, dynamic>.from(settings['notification_preferences']);
    }
    // Return defaults if not found
    return {
      'app': true,
      'surat': false,
      'orders': true,
      'chat': true,
      'email': true,
      'whatsapp': false,
    };
  }

  /// Save notification settings
  Future<void> saveNotificationSettings(
    String userId,
    Map<String, dynamic> preferences,
  ) async {
    final existing = await getUserSettings(userId);

    if (existing == null) {
      // Insert new settings
      await _supabase.from('user_settings').insert({
        'user_id': userId,
        'notification_preferences': preferences,
      });
    } else {
      // Update existing
      await _supabase
          .from('user_settings')
          .update({'notification_preferences': preferences})
          .eq('user_id', userId);
    }
  }

  /// Get language preference
  Future<String> getLanguage(String userId) async {
    final settings = await getUserSettings(userId);
    return settings?['language'] ?? 'id';
  }
}
