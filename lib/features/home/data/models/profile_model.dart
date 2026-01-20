class Profile {
  final String id;
  final String? fullName;
  final String? shopName;
  final String? phone;
  final String? role;
  final String? avatarUrl;
  final String? description;
  final String? hope;
  final String? dailyActivity;
  final int? age;

  Profile({
    required this.id,
    this.fullName,
    this.shopName,
    this.phone,
    this.role,
    this.avatarUrl,
    this.description,
    this.hope,
    this.dailyActivity,
    this.age,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      fullName: json['full_name'],
      shopName: json['shop_name'],
      phone: json['phone'],
      role: json['role'],
      avatarUrl: json['avatar_url'],
      description: json['description'],
      hope: json['hope'],
      dailyActivity: json['daily_activity'],
      age: json['age'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'shop_name': shopName,
      'phone': phone,
      'role': role,
      'avatar_url': avatarUrl,
      'description': description,
      'hope': hope,
      'daily_activity': dailyActivity,
      'age': age,
    };
  }
}
