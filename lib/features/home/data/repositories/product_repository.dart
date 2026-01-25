import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

class ProductRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get recommended products (random/latest for now)
  Future<List<Product>> getRecommendedProducts() async {
    final data = await _supabase
        .from('products')
        .select('*, benang_patterns(*), benang_colors(*), benang_usages(*)')
        .limit(6)
        .order('created_at', ascending: false); // For now just latest

    return (data as List).map((e) => Product.fromJson(e)).toList();
  }

  /// Get best selling products
  Future<List<Product>> getBestSellingProducts() async {
    final data = await _supabase
        .from('products')
        .select('*, benang_patterns(*), benang_colors(*), benang_usages(*)')
        .order('sold_count', ascending: false)
        .limit(10);

    return (data as List).map((e) => Product.fromJson(e)).toList();
  }

  /// Search and filter products
  Future<List<Product>> searchProducts({
    String? query,
    String? category,
    String? sort, // 'price_asc', 'price_desc', 'name_asc', 'name_desc'
    String? patternId,
    String? colorId,
    String? usageId,
  }) async {
    dynamic dbQuery = _supabase
        .from('products')
        .select('*, benang_patterns(*), benang_colors(*), benang_usages(*)');

    if (query != null && query.isNotEmpty) {
      dbQuery = dbQuery.ilike('name', '%$query%');
    }

    if (category != null &&
        category != 'Semua Kategori' &&
        category.isNotEmpty) {
      dbQuery = dbQuery.eq('category', category);
    }

    if (patternId != null) {
      dbQuery = dbQuery.eq('pattern_id', patternId);
    }
    if (colorId != null) {
      dbQuery = dbQuery.eq('color_id', colorId);
    }
    if (usageId != null) {
      dbQuery = dbQuery.eq('usage_id', usageId);
    }

    if (sort != null) {
      switch (sort) {
        case 'Harga Terendah':
          dbQuery = dbQuery.order('price', ascending: true);
          break;
        case 'Harga Tertinggi':
          dbQuery = dbQuery.order('price', ascending: false);
          break;
        case 'Nama A-Z':
          dbQuery = dbQuery.order('name', ascending: true);
          break;
        case 'Nama Z-A':
          dbQuery = dbQuery.order('name', ascending: false);
          break;
        default:
          dbQuery = dbQuery.order('created_at', ascending: false);
      }
    } else {
      dbQuery = dbQuery.order('created_at', ascending: false);
    }

    final data = await dbQuery;
    return (data as List).map((e) => Product.fromJson(e)).toList();
  }

  /// Get products by seller ID
  Future<List<Product>> getProductsBySeller(String sellerId) async {
    final data = await _supabase
        .from('products')
        .select('*, benang_patterns(*), benang_colors(*), benang_usages(*)')
        .eq('seller_id', sellerId)
        .order('created_at', ascending: false);

    return (data as List).map((e) => Product.fromJson(e)).toList();
  }
}
