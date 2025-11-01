class Partner {
  final String id;
  final String name;
  final String email;
  final String phone;
  final bool isActive;
  final PartnerProfile? deliveryPartnerProfile;
  final PartnerStats? stats;

  Partner({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.isActive,
    this.deliveryPartnerProfile,
    this.stats,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      isActive: json['is_active'] ?? false,
      deliveryPartnerProfile: json['deliveryPartnerProfile'] != null
          ? PartnerProfile.fromJson(json['deliveryPartnerProfile'])
          : null,
      stats: json['stats'] != null ? PartnerStats.fromJson(json['stats']) : null,
    );
  }
}

class PartnerProfile {
  final String id;
  final String address;
  final String deliveryRegion;

  PartnerProfile({
    required this.id,
    required this.address,
    required this.deliveryRegion,
  });

  factory PartnerProfile.fromJson(Map<String, dynamic> json) {
    return PartnerProfile(
      id: json['id'] ?? '',
      address: json['address'] ?? '',
      deliveryRegion: json['deliveryRegion'] ?? '',
    );
  }
}

class PartnerStats {
  final int totalDeliveries;
  final int completedDeliveries;
  final int pendingDeliveries;
  final int totalEarnings;

  PartnerStats({
    required this.totalDeliveries,
    required this.completedDeliveries,
    required this.pendingDeliveries,
    required this.totalEarnings,
  });

  factory PartnerStats.fromJson(Map<String, dynamic> json) {
    return PartnerStats(
      totalDeliveries: json['totalDeliveries'] ?? 0,
      completedDeliveries: json['completedDeliveries'] ?? 0,
      pendingDeliveries: json['pendingDeliveries'] ?? 0,
      totalEarnings: json['totalEarnings'] ?? 0,
    );
  }
}
