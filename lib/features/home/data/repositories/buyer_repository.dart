import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';

class BuyerRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ==================== PROFILE METHODS ====================

  Future<Profile?> getProfile(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return Profile.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateProfile(Profile profile) async {
    final updates = profile.toJson();
    updates.remove('id');
    updates.remove('role');

    await _supabase.from('profiles').update(updates).eq('id', profile.id);
  }

  // ==================== FAVORITES METHODS ====================

  Future<List<Product>> getFavorites(String userId) async {
    final data = await _supabase
        .from('favorites')
        .select('*, products(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List).map((e) => Product.fromJson(e['products'])).toList();
  }

  Future<void> addFavorite(String userId, String productId) async {
    await _supabase.from('favorites').insert({
      'user_id': userId,
      'product_id': productId,
    });
  }

  Future<void> removeFavorite(String userId, String productId) async {
    await _supabase
        .from('favorites')
        .delete()
        .eq('user_id', userId)
        .eq('product_id', productId);
  }

  Future<bool> isFavorite(String userId, String productId) async {
    final data = await _supabase
        .from('favorites')
        .select('id')
        .eq('user_id', userId)
        .eq('product_id', productId)
        .maybeSingle();

    return data != null;
  }

  // ==================== RECENTLY VIEWED METHODS ====================

  Future<List<Product>> getRecentlyViewed(
    String userId, {
    int limit = 20,
  }) async {
    final data = await _supabase
        .from('recently_viewed')
        .select('*, products(*)')
        .eq('user_id', userId)
        .order('viewed_at', ascending: false)
        .limit(limit);

    return (data as List).map((e) => Product.fromJson(e['products'])).toList();
  }

  Future<void> trackProductView(String userId, String productId) async {
    // Use upsert to update viewed_at if already exists, or insert if new
    await _supabase.from('recently_viewed').upsert({
      'user_id': userId,
      'product_id': productId,
      'viewed_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id,product_id');
  }

  // ==================== BUY AGAIN METHODS ====================

  /// Get products from completed orders for "Beli Lagi" feature
  Future<List<Product>> getBuyAgainProducts(String userId) async {
    // Get completed orders with product info
    final data = await _supabase
        .from('orders')
        .select('*, products(*)')
        .eq('buyer_id', userId)
        .eq('status', 'completed')
        .order('created_at', ascending: false);

    // Extract unique products
    final Map<String, Product> productMap = {};
    for (final order in data as List) {
      if (order['products'] != null) {
        final product = Product.fromJson(order['products']);
        productMap[product.id] = product;
      }
    }

    return productMap.values.toList();
  }

  // ==================== REVIEW METHODS ====================

  /// Get completed orders that haven't been reviewed yet
  Future<List<OrderModel>> getOrdersNeedingReview(String userId) async {
    // Get completed orders
    final orders = await _supabase
        .from('orders')
        .select('*, products(*), profiles:seller_id(full_name, shop_name)')
        .eq('buyer_id', userId)
        .eq('status', 'completed')
        .order('created_at', ascending: false);

    final List<OrderModel> needsReview = [];

    for (final order in orders as List) {
      // Check if this order has a review
      final review = await _supabase
          .from('reviews')
          .select('id')
          .eq('order_id', order['id'])
          .maybeSingle();

      if (review == null) {
        needsReview.add(OrderModel.fromJson(order));
      }
    }

    return needsReview;
  }

  /// Submit a review for an order
  Future<void> submitReview({
    required String productId,
    required String userId,
    required String orderId,
    required int rating,
    String? comment,
    String? imageUrl,
  }) async {
    await _supabase.from('reviews').insert({
      'product_id': productId,
      'user_id': userId,
      'order_id': orderId,
      'rating': rating,
      'comment': comment,
      'image_url': imageUrl,
    });

    // Update product average rating
    final reviews = await _supabase
        .from('reviews')
        .select('rating')
        .eq('product_id', productId);

    if ((reviews as List).isNotEmpty) {
      final totalRating = reviews.fold<int>(
        0,
        (sum, r) => sum + (r['rating'] as int),
      );
      final avgRating = totalRating / reviews.length;

      await _supabase
          .from('products')
          .update({
            'average_rating': avgRating,
            'total_reviews': reviews.length,
          })
          .eq('id', productId);
    }
  }

  // ==================== ORDER METHODS ====================

  /// Get all orders for buyer
  Future<List<OrderModel>> getBuyerOrders(
    String userId, {
    String? status,
  }) async {
    var query = _supabase
        .from('orders')
        .select('*, products(*), profiles:seller_id(full_name, shop_name)')
        .eq('buyer_id', userId);

    if (status != null) {
      query = query.eq('status', status);
    }

    final data = await query.order('created_at', ascending: false);

    return (data as List).map((e) => OrderModel.fromJson(e)).toList();
  }
}
