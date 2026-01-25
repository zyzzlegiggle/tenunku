class OrderModel {
  final String id;
  final String buyerId;
  final String sellerId;
  final String productId;
  final int quantity;
  final double totalPrice;
  final String status;
  final String? rejectionReason;
  final String? trackingNumber;
  final String? shippingEvidenceUrl;
  final DateTime createdAt;

  // Joins (optional, might need to be fetched separately or via Supabase join)
  final String? buyerName;
  final String? productName;
  final String? productImageUrl;
  final String? sellerShopName;

  OrderModel({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.productId,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    this.rejectionReason,
    this.trackingNumber,
    this.shippingEvidenceUrl,
    required this.createdAt,
    this.buyerName,
    this.productName,
    this.productImageUrl,
    this.sellerShopName,
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
      rejectionReason: json['rejection_reason'],
      trackingNumber: json['tracking_number'],
      shippingEvidenceUrl: json['shipping_evidence_url'],
      createdAt: DateTime.parse(json['created_at']),
      buyerName: json['profiles'] != null
          ? json['profiles']['full_name']
          : null,
      productName: json['products'] != null ? json['products']['name'] : null,
      productImageUrl: json['products'] != null
          ? json['products']['image_url']
          : null,
      sellerShopName: json['profiles'] != null
          ? json['profiles']['shop_name']
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
      'rejection_reason': rejectionReason,
      'tracking_number': trackingNumber,
      'shipping_evidence_url': shippingEvidenceUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
