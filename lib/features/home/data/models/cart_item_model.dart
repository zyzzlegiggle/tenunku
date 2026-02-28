class CartItem {
  final String id;
  final String buyerId;
  final String productId;
  final String sellerId;
  final int quantity;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Joined fields (from products table)
  final String? productName;
  final String? productImageUrl;
  final double? productPrice;
  final String? sellerName;

  CartItem({
    required this.id,
    required this.buyerId,
    required this.productId,
    required this.sellerId,
    required this.quantity,
    required this.createdAt,
    this.updatedAt,
    this.productName,
    this.productImageUrl,
    this.productPrice,
    this.sellerName,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      buyerId: json['buyer_id'],
      productId: json['product_id'],
      sellerId: json['seller_id'],
      quantity: json['quantity'] ?? 1,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      productName: json['products'] != null ? json['products']['name'] : null,
      productImageUrl: json['products'] != null
          ? json['products']['image_url']
          : null,
      productPrice: json['products'] != null
          ? (json['products']['price'] as num?)?.toDouble()
          : null,
      sellerName: json['profiles'] != null
          ? (json['profiles']['shop_name'] ?? json['profiles']['full_name'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyer_id': buyerId,
      'product_id': productId,
      'seller_id': sellerId,
      'quantity': quantity,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      // joined fields not usually serialized back for inserts
    };
  }

  CartItem copyWith({
    String? id,
    String? buyerId,
    String? productId,
    String? sellerId,
    int? quantity,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? productName,
    String? productImageUrl,
    double? productPrice,
    String? sellerName,
  }) {
    return CartItem(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      productId: productId ?? this.productId,
      sellerId: sellerId ?? this.sellerId,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      productName: productName ?? this.productName,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      productPrice: productPrice ?? this.productPrice,
      sellerName: sellerName ?? this.sellerName,
    );
  }
}
