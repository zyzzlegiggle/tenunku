class Product {
  final String id;
  final String sellerId;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final String? category;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.sellerId,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    this.category,
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
      category: json['category'],
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
      'category': category,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
