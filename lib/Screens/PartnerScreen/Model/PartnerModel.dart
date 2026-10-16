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
      deliveryPartnerProfile:
          json['deliveryPartnerProfile'] != null
              ? PartnerProfile.fromJson(json['deliveryPartnerProfile'])
              : null,
      stats:
          json['stats'] != null ? PartnerStats.fromJson(json['stats']) : null,
    );
  }

  // ✅ ONLY ADD THIS (nothing else changed)
  Partner copyWith({bool? isActive}) {
    return Partner(
      id: id,
      name: name,
      email: email,
      phone: phone,
      isActive: isActive ?? this.isActive,
      deliveryPartnerProfile: deliveryPartnerProfile,
      stats: stats,
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

/// One subscription currently assigned to a delivery partner — from `GET
/// /deliveries/partner/{partnerId}/subscriptions`.
class AssignedSubscription {
  final String id;
  final String planName;
  final String price;
  final String customerName;
  final String customerPhone;

  AssignedSubscription({
    required this.id,
    required this.planName,
    required this.price,
    required this.customerName,
    required this.customerPhone,
  });

  factory AssignedSubscription.fromJson(Map<String, dynamic> json) {
    final plan =
        json['plan'] is Map ? json['plan'] as Map<String, dynamic> : null;
    final customerProfile =
        json['CustomerProfile'] is Map
            ? json['CustomerProfile'] as Map<String, dynamic>
            : null;
    final user =
        customerProfile?['user'] is Map
            ? customerProfile!['user'] as Map<String, dynamic>
            : null;

    return AssignedSubscription(
      id: (json['id'] ?? '').toString(),
      planName: (plan?['planName'] ?? '').toString(),
      price:
          (json['discountedPrice'] ??
                  json['totalPrice'] ??
                  plan?['price'] ??
                  '0')
              .toString(),
      customerName: (user?['name'] ?? 'Customer').toString(),
      customerPhone: (user?['phone'] ?? '').toString(),
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
