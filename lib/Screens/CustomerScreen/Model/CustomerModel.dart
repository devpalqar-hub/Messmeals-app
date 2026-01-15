class CustomerModel {
  final String id;
  final String customerProfileId;
  final String name;
  final String email;
  final String phone;
  final bool isActive;
  final String address;
  final String currentLocation;
  final String latitudeLongitude;
  final int walletBalance;
  final int noOfDaysToEnd;
  final int totalOrders;
  final int totalSpent;
  final List<ActiveSubscription> activeSubscriptions;

  CustomerModel({
    required this.id,
    required this.customerProfileId,
    required this.name,
    required this.email,
    required this.phone,
    required this.isActive,
    required this.address,
    required this.currentLocation,
    required this.latitudeLongitude,
    required this.walletBalance,
    required this.noOfDaysToEnd,
    required this.totalOrders,
    required this.totalSpent,
    required this.activeSubscriptions,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] ?? '',
      customerProfileId: json['customerProfileId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      isActive: json['is_active'] ?? false,
      address: json['address'] ?? '',
      currentLocation: json['current_location'] ?? '',
      latitudeLongitude: json['latitude_logitude'] ?? '',
      walletBalance: json['walletBalance'] ?? 0,
      noOfDaysToEnd: json['noOfDaysToEnd'] ?? 0,
      totalOrders: json['totalOrders'] ?? 0,
      totalSpent: json['totalSpent'] ?? 0,
      activeSubscriptions: (json['activeSubscriptions'] as List<dynamic>?)
              ?.map((e) => ActiveSubscription.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ActiveSubscription {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final int totalPrice;
  final int discountedPrice;
  final String deliveryPartnerProfileId;
  final Plan plan;
  final String scheduleType; 
  final List<String> days; 

  ActiveSubscription({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.totalPrice,
    required this.discountedPrice,
    required this.deliveryPartnerProfileId,
    required this.plan,
    this.scheduleType = "EVERYDAY", 
    this.days = const [],
  });

  factory ActiveSubscription.fromJson(Map<String, dynamic> json) {
    return ActiveSubscription(
      id: json['id'] ?? '',
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] ?? '') ?? DateTime.now(),
      isActive: json['is_active'] ?? false,
      totalPrice: json['totalPrice'] ?? 0,
      discountedPrice: json['discountedPrice'] ?? 0,
      deliveryPartnerProfileId: json['deliveryPartnerProfileId'] ?? '',
      plan: Plan.fromJson(json['plan'] ?? {}),
      scheduleType: json['scheduleType'] ?? "EVERYDAY",
      days: json['days'] != null
          ? List<String>.from(json['days'])
          : [],
    );
  }
}

class Plan {
  final String id;
  final String name;
  final int price;
  final String description;
  final List<Variation> variation;
  final Mess mess;
  final List<PlanImage> images;

  Plan({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.variation,
    required this.mess,
    required this.images,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      description: json['description'] ?? '',
      variation: (json['variation'] as List<dynamic>?)
              ?.map((e) => Variation.fromJson(e))
              .toList() ??
          [],
      mess: Mess.fromJson(json['mess'] ?? {}),
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => PlanImage.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Variation {
  final String id;
  final String title;
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Variation({
    required this.id,
    required this.title,
    required this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory Variation.fromJson(Map<String, dynamic> json) {
    return Variation(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }
}

class Mess {
  final String id;
  final String name;
  final String description;
  final String address;
  final String phone;
  final String email;
  final bool isActive;

  Mess({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.phone,
    required this.email,
    required this.isActive,
  });

  factory Mess.fromJson(Map<String, dynamic> json) {
    return Mess(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      isActive: json['is_active'] ?? false,
    );
  }
}

class PlanImage {
  final String url;
  final String altText;

  PlanImage({
    required this.url,
    required this.altText,
  });

  factory PlanImage.fromJson(Map<String, dynamic> json) {
    return PlanImage(
      url: json['url'] ?? '',
      altText: json['altText'] ?? '',
    );
  }
}
