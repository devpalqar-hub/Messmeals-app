// DELIVERY PARTNER MODULE — DISABLED (admin-only build for now)
// Entire file commented out below; not wired into the app.
/*
class DeliveryAgentProfileModel {
  final String id;
  final String name;
  final String phone;
  final bool isActive;
  final bool isVerified;

  /// The backend's delivery-agent record has no vehicle-type/number fields
  /// yet — these are placeholders (editable locally, not persisted) until
  /// that's added server-side.
  final String vehicleType;
  final String vehicleNumber;

  DeliveryAgentProfileModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.isActive,
    required this.isVerified,
    this.vehicleType = 'Two Wheeler',
    this.vehicleNumber = '',
  });

  factory DeliveryAgentProfileModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map ? json['user'] as Map<String, dynamic> : null;
    return DeliveryAgentProfileModel(
      id: (json['id'] ?? '').toString(),
      name: (user?['name'] ?? json['name'] ?? '').toString(),
      phone: (user?['phone'] ?? json['phone'] ?? '').toString(),
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      isVerified: json['is_verified'] ?? json['isVerified'] ?? false,
    );
  }

  DeliveryAgentProfileModel copyWith({
    String? name,
    String? phone,
    String? vehicleType,
    String? vehicleNumber,
  }) {
    return DeliveryAgentProfileModel(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      isActive: isActive,
      isVerified: isVerified,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
    );
  }
}

*/
