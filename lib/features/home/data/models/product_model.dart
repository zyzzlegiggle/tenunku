import 'benang_membumi_model.dart';

class Product {
  final String id;
  final String sellerId;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final List<String> imageUrls;
  final String? category;
  final int stock;
  final int soldCount;
  final int viewCount;
  final double averageRating;
  final int totalReviews;
  final String? colorMeaning;
  final String? patternMeaning;
  final String? usage;
  final String? patternId;
  final String? colorId;
  final String? usageId;
  // Joined fields
  final BenangPattern? benangPattern;
  final BenangColor? benangColor;
  final BenangUsage? benangUsage;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.sellerId,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    this.imageUrls = const [],
    this.category,
    this.stock = 0,
    this.soldCount = 0,
    this.viewCount = 0,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.colorMeaning,
    this.patternMeaning,
    this.usage,
    this.patternId,
    this.colorId,
    this.usageId,
    this.benangPattern,
    this.benangColor,
    this.benangUsage,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      sellerId: json['seller_id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'],
      imageUrls: json['image_urls'] != null
          ? List<String>.from(json['image_urls'])
          : [],
      category: json['category'],
      stock: json['stock'] ?? 0,
      soldCount: json['sold_count'] ?? 0,
      viewCount: json['view_count'] ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] ?? 0,
      colorMeaning: json['color_meaning'],
      patternMeaning: json['pattern_meaning'],
      usage: json['usage'],
      patternId: json['pattern_id'],
      colorId: json['color_id'],
      usageId: json['usage_id'],
      benangPattern: json['benang_patterns'] != null
          ? BenangPattern.fromJson(json['benang_patterns'])
          : null,
      benangColor: json['benang_colors'] != null
          ? BenangColor.fromJson(json['benang_colors'])
          : null,
      benangUsage: json['benang_usages'] != null
          ? BenangUsage.fromJson(json['benang_usages'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seller_id': sellerId,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'image_urls': imageUrls,
      'category': category,
      'stock': stock,
      'sold_count': soldCount,
      'view_count': viewCount,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'color_meaning': colorMeaning,
      'pattern_meaning': patternMeaning,
      'usage': usage,
      'pattern_id': patternId,
      'color_id': colorId,
      'usage_id': usageId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
