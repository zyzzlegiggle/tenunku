import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import '../models/product_model.dart';

class SellerRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Profile?> getProfile(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return Profile.fromJson(data);
    } catch (e) {
      // Return null if not found or error
      return null;
    }
  }

  Future<void> updateProfile(Profile profile) async {
    // Exclude ID from update payload usually, but RLS handles check.
    // We send fields we want to update.
    final updates = profile.toJson();
    updates.remove('id'); // ID is primary key
    updates.remove(
      'role',
    ); // Typically role isn't self-editable easily effectively

    await _supabase.from('profiles').update(updates).eq('id', profile.id);
  }

  Future<List<Product>> getSellerProducts(String sellerId) async {
    final data = await _supabase
        .from('products')
        .select()
        .eq('seller_id', sellerId)
        .order('created_at', ascending: false);

    return (data as List).map((e) => Product.fromJson(e)).toList();
  }

  Future<List<Product>> getAllProducts() async {
    final data = await _supabase
        .from('products')
        .select()
        .order('created_at', ascending: false);

    return (data as List).map((e) => Product.fromJson(e)).toList();
  }
}
