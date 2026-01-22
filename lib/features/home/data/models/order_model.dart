class OrderModel {
  final String id;
  final String buyerId;
  final String sellerId;
  final String productId;
  final int quantity;
  final double totalPrice;
  final String status;
  final DateTime createdAt;

  // Joins (optional, might need to be fetched separately or via Supabase join)
  final String? buyerName;
  final String? productName;
  final String? productImageUrl;

  OrderModel({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.productId,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.buyerName,
    this.productName,
    this.productImageUrl,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      buyerId: json['buyer_id'],
      sellerId: json['seller_id'],
      productId: json['product_id'],
      quantity: json['quantity'] ?? 1,
      totalPrice: (json['total_price'] as num).toDouble(),
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
      buyerName: json['profiles'] != null
          ? json['profiles']['full_name']
          : null,
      productName: json['products'] != null ? json['products']['name'] : null,
      productImageUrl: json['products'] != null
          ? json['products']['image_url']
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyer_id': buyerId,
      'seller_id': sellerId,
      'product_id': productId,
      'quantity': quantity,
      'total_price': totalPrice,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
