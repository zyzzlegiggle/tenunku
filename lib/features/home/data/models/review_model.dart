class Review {
  final String id;
  final String productId;
  final String userId;
  final String? orderId; // Link review to specific order
  final String? userName; // Joined from profile
  final String? userAvatarUrl; // Joined from profile
  final int rating;
  final String? comment;
  final String? imageUrl; // Photo review support
  final DateTime createdAt;

  Review({
    required this.id,
    required this.productId,
    required this.userId,
    this.orderId,
    this.userName,
    this.userAvatarUrl,
    required this.rating,
    this.comment,
    this.imageUrl,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      productId: json['product_id'],
      userId: json['user_id'],
      orderId: json['order_id'],
      userName: json['profiles']?['full_name'], // Assuming join
      userAvatarUrl: json['profiles']?['avatar_url'], // Assuming join
      rating: json['rating'],
      comment: json['comment'],
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'user_id': userId,
      'order_id': orderId,
      'rating': rating,
      'comment': comment,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
