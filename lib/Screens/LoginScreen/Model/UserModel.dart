class UserModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String role;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? otp;
  final DateTime? expiresAt;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.isVerified,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.otp,
    this.expiresAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      phone: json["phone"] ?? "",
      email: json["email"] ?? "",
      role: json["role"] ?? "",
      isVerified: json["is_verified"] ?? false,
      isActive: json["is_active"] ?? false,
      createdAt: DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? "") ?? DateTime.now(),
      otp: json["otp"],
      expiresAt: json["expiresAt"] != null
          ? DateTime.tryParse(json["expiresAt"])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "phone": phone,
      "email": email,
      "role": role,
      "is_verified": isVerified,
      "is_active": isActive,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
      "otp": otp,
      "expiresAt": expiresAt?.toIso8601String(),
    };
  }
}
