class ConversationModel {
  final String id;
  final String buyerId;
  final String sellerId;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final DateTime createdAt;

  // Joined fields from profiles
  final String? buyerName;
  final String? buyerAvatarUrl;
  final String? sellerName;
  final String? sellerAvatarUrl;
  final String? shopName;

  ConversationModel({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    this.lastMessage,
    this.lastMessageAt,
    required this.createdAt,
    this.buyerName,
    this.buyerAvatarUrl,
    this.sellerName,
    this.sellerAvatarUrl,
    this.shopName,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'],
      buyerId: json['buyer_id'],
      sellerId: json['seller_id'],
      lastMessage: json['last_message'],
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      buyerName: json['profiles'] != null
          ? json['profiles']['full_name']
          : null,
      buyerAvatarUrl: json['profiles'] != null
          ? json['profiles']['avatar_url']
          : null,
      sellerName: json['profiles'] != null
          ? json['profiles']['full_name']
          : null,
      sellerAvatarUrl: json['profiles'] != null
          ? json['profiles']['avatar_url']
          : null,
      shopName: json['profiles'] != null ? json['profiles']['shop_name'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyer_id': buyerId,
      'seller_id': sellerId,
      'last_message': lastMessage,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
