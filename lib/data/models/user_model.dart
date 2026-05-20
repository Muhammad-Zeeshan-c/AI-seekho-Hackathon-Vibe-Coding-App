/// Represents a registered client or worker on the KaamKaar platform.
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final bool isVerified;
  final String? city;
  final String? area;
  final double? lat;
  final double? lng;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.isVerified = false,
    this.city,
    this.area,
    this.lat,
    this.lng,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
        phone: json['phone'] as String?,
        isVerified: json['is_verified'] as bool? ?? false,
        city: json['city'] as String?,
        area: json['area'] as String?,
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'phone': phone,
        'is_verified': isVerified,
        'city': city,
        'area': area,
        'lat': lat,
        'lng': lng,
        'created_at': createdAt.toIso8601String(),
      };

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? phone,
    bool? isVerified,
    String? city,
    String? area,
    double? lat,
    double? lng,
    DateTime? createdAt,
  }) =>
      UserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        role: role ?? this.role,
        phone: phone ?? this.phone,
        isVerified: isVerified ?? this.isVerified,
        city: city ?? this.city,
        area: area ?? this.area,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        createdAt: createdAt ?? this.createdAt,
      );
}
