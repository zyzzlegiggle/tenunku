import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import '../models/product_model.dart';
import '../models/benang_membumi_model.dart';
import '../models/review_model.dart';
import '../models/order_model.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class SellerRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get seller statistics (total sold, views, reviews)
  Future<Map<String, int>> getSellerStats(String sellerId) async {
    // Get total products sold (sum of sold_count from all seller products)
    final products = await _supabase
        .from('products')
        .select('sold_count, view_count, id')
        .eq('seller_id', sellerId);

    int totalSold = 0;
    int totalViews = 0;
    final productIds = <String>[];

    for (final p in products as List) {
      totalSold += (p['sold_count'] as int?) ?? 0;
      totalViews += (p['view_count'] as int?) ?? 0;
      productIds.add(p['id'] as String);
    }

    // Get total reviews count for all seller's products
    int totalReviews = 0;
    if (productIds.isNotEmpty) {
      final reviews = await _supabase
          .from('reviews')
          .select('id')
          .inFilter('product_id', productIds);
      totalReviews = (reviews as List).length;
    }

    return {
      'totalSold': totalSold,
      'totalViews': totalViews,
      'totalReviews': totalReviews,
    };
  }

  // ignore: unused_element
  Future<List<OrderModel>> getSellerOrders(
    String sellerId, {
    String? status,
  }) async {
    var query = _supabase
        .from('orders')
        .select('*, profiles:buyer_id(*), products:product_id(*)')
        .eq('seller_id', sellerId);

    if (status != null) {
      query = query.eq('status', status);
    }

    final data = await query.order('created_at', ascending: false);

    return (data as List).map((e) => OrderModel.fromJson(e)).toList();
  }

  Future<void> updateOrderStatus(
    String orderId,
    String newStatus, {
    String? rejectionReason,
  }) async {
    final updates = {'status': newStatus};
    if (rejectionReason != null) {
      updates['rejection_reason'] = rejectionReason;
    }

    await _supabase.from('orders').update(updates).eq('id', orderId);
  }

  Future<void> updateOrderTrackingNumber(
    String orderId,
    String trackingNumber, {
    String? shippingEvidenceUrl,
  }) async {
    final updates = {
      'tracking_number': trackingNumber,
      // If we have an evidence URL, update it. If not, maybe keep it as is or null.
      // For now let's only update if provided or allow null if we want to clear it?
      // Simple approach: if passed, update it.
    };
    if (shippingEvidenceUrl != null) {
      updates['shipping_evidence_url'] = shippingEvidenceUrl;
    }

    await _supabase.from('orders').update(updates).eq('id', orderId);
  }

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
        .select('*, benang_patterns(*), benang_colors(*), benang_usages(*)')
        .eq('seller_id', sellerId)
        .order('created_at', ascending: false);

    return (data as List).map((e) => Product.fromJson(e)).toList();
  }

  Future<List<Product>> getAllProducts() async {
    final data = await _supabase
        .from('products')
        .select('*, benang_patterns(*), benang_colors(*), benang_usages(*)')
        .order('created_at', ascending: false);

    return (data as List).map((e) => Product.fromJson(e)).toList();
  }

  Future<List<Review>> getProductReviews(String productId) async {
    final data = await _supabase
        .from('reviews')
        .select('*, profiles(full_name, avatar_url)')
        .eq('product_id', productId)
        .order('created_at', ascending: false);

    return (data as List).map((e) => Review.fromJson(e)).toList();
  }

  /// Get review for a specific order (for Diterima tab display)
  Future<Review?> getOrderReview(String orderId) async {
    try {
      final data = await _supabase
          .from('reviews')
          .select('*, profiles(full_name, avatar_url)')
          .eq('order_id', orderId)
          .maybeSingle();

      if (data != null) {
        return Review.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateProduct(Product product) async {
    final updates = product.toJson();
    updates.remove('id');
    updates.remove('seller_id');
    updates.remove('created_at');

    await _supabase.from('products').update(updates).eq('id', product.id);
  }

  Future<void> createProduct(Product product) async {
    final data = product.toJson();
    data.remove(
      'id',
    ); // Generate ID by DB or let Supabase handle if using gen_random_uuid
    data.remove('created_at'); // Let DB handle default

    // If ID is required by model but generated by DB, we might usually send it without ID
    // But Product model has required ID. We can either generate UUID here or ignore it.
    // Ideally we generate UUID here if we want to use it immediately, or let DB do it.
    // Since Product model demands ID, let's assume we generated one or pass a dummy one that gets ignored if we exclude it.

    // Actually, to insert we just need the values.
    // The previous implementation plan suggested removing ID.

    await _supabase.from('products').insert(data);
  }

  // ==================== CHAT METHODS ====================

  /// Get all conversations for a seller
  Future<List<ConversationModel>> getSellerConversations(
    String sellerId,
  ) async {
    final data = await _supabase
        .from('conversations')
        .select('*, profiles:buyer_id(full_name, avatar_url)')
        .eq('seller_id', sellerId)
        .order('last_message_at', ascending: false);

    return (data as List).map((e) => ConversationModel.fromJson(e)).toList();
  }

  /// Get all messages for a conversation
  Future<List<MessageModel>> getMessages(String conversationId) async {
    final data = await _supabase
        .from('messages')
        .select('*, profiles:sender_id(full_name, avatar_url)')
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);

    return (data as List).map((e) => MessageModel.fromJson(e)).toList();
  }

  /// Send a message in a conversation
  Future<void> sendMessage(
    String conversationId,
    String senderId,
    String content,
  ) async {
    // Insert the message
    await _supabase.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': content,
    });

    // Update conversation with last message
    await _supabase
        .from('conversations')
        .update({
          'last_message': content,
          'last_message_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', conversationId);
  }

  /// Mark all messages as read for a user in a conversation
  Future<void> markMessagesAsRead(String conversationId, String userId) async {
    await _supabase
        .from('messages')
        .update({'is_read': true})
        .eq('conversation_id', conversationId)
        .neq('sender_id', userId);
  }

  /// Get unread message count for a conversation (messages not sent by this user)
  Future<int> getUnreadCount(String conversationId, String userId) async {
    final data = await _supabase
        .from('messages')
        .select('id')
        .eq('conversation_id', conversationId)
        .eq('is_read', false)
        .neq('sender_id', userId);

    return (data as List).length;
  }

  // ==================== BENANG MEMBUMI METHODS ====================

  Future<List<BenangPattern>> getBenangPatterns() async {
    final data = await _supabase.from('benang_patterns').select();
    return (data as List).map((e) => BenangPattern.fromJson(e)).toList();
  }

  Future<List<BenangColor>> getBenangColors() async {
    final data = await _supabase.from('benang_colors').select();
    return (data as List).map((e) => BenangColor.fromJson(e)).toList();
  }

  Future<List<BenangUsage>> getBenangUsages() async {
    final data = await _supabase.from('benang_usages').select();
    return (data as List).map((e) => BenangUsage.fromJson(e)).toList();
  }
}
