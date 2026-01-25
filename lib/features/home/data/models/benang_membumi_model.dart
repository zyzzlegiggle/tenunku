class BenangPattern {
  final String id;
  final String name;
  final String meaning;
  final String? imageUrl;
  final DateTime createdAt;

  BenangPattern({
    required this.id,
    required this.name,
    required this.meaning,
    this.imageUrl,
    required this.createdAt,
  });

  factory BenangPattern.fromJson(Map<String, dynamic> json) {
    return BenangPattern(
      id: json['id'],
      name: json['name'],
      meaning: json['meaning'],
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class BenangColor {
  final String id;
  final String name;
  final String meaning;
  final String? hexCode;
  final DateTime createdAt;

  BenangColor({
    required this.id,
    required this.name,
    required this.meaning,
    this.hexCode,
    required this.createdAt,
  });

  factory BenangColor.fromJson(Map<String, dynamic> json) {
    return BenangColor(
      id: json['id'],
      name: json['name'],
      meaning: json['meaning'],
      hexCode: json['hex_code'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class BenangUsage {
  final String id;
  final String name;
  final String meaning;
  final String? iconUrl;
  final DateTime createdAt;

  BenangUsage({
    required this.id,
    required this.name,
    required this.meaning,
    this.iconUrl,
    required this.createdAt,
  });

  factory BenangUsage.fromJson(Map<String, dynamic> json) {
    return BenangUsage(
      id: json['id'],
      name: json['name'],
      meaning: json['meaning'],
      iconUrl: json['icon_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
