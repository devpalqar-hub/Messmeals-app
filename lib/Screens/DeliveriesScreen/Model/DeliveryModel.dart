class Delivery {
  final String id;
  final String date;
  final String status;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final Customer? customer;
  final Plan? plan;
  final Partner? partner;
  final List<DeliveryVariation> deliveryVariations; // Added

  Delivery({
    required this.id,
    required this.date,
    required this.status,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.customer,
    this.plan,
    this.partner,
    required this.deliveryVariations, // Added
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    var list = json['deliveryVariations'] as List?;
    List<DeliveryVariation> variationsList =
        list != null
            ? list.map((i) => DeliveryVariation.fromJson(i)).toList()
            : [];

    return Delivery(
      id: json['id'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      customer:
          json['customer'] != null ? Customer.fromJson(json['customer']) : null,
      plan: json['plan'] != null ? Plan.fromJson(json['plan']) : null,
      partner:
          json['partner'] != null ? Partner.fromJson(json['partner']) : null,
      deliveryVariations: variationsList,
    );
  }
}

// Represents each specific delivery-variation map item row
class DeliveryVariation {
  final String id;
  final String deliveryId;
  final String variationId;
  final String status;
  final String createdAt;
  final String updatedAt;
  final MealVariation? variation; // Nested object detail

  DeliveryVariation({
    required this.id,
    required this.deliveryId,
    required this.variationId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.variation,
  });

  factory DeliveryVariation.fromJson(Map<String, dynamic> json) {
    return DeliveryVariation(
      id: json['id'] ?? '',
      deliveryId: json['deliveryId'] ?? '',
      variationId: json['variationId'] ?? '',
      status: json['status'] ?? 'PENDING',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      variation:
          json['variation'] != null
              ? MealVariation.fromJson(json['variation'])
              : null,
    );
  }
}

// Inner nested detail of the structural variation metadata definition
class MealVariation {
  final String id;
  final String title;
  final String? description;

  MealVariation({required this.id, required this.title, this.description});

  factory MealVariation.fromJson(Map<String, dynamic> json) {
    return MealVariation(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
    );
  }
}

class Customer {
  final String id;
  final String walletAmount;
  final String address;
  final String? currentLocation;
  final String? latitudeLongitude;
  final User? user;

  Customer({
    required this.id,
    required this.walletAmount,
    required this.address,
    this.currentLocation,
    this.latitudeLongitude,
    this.user,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? '',
      walletAmount: json['walletAmount'] ?? '0',
      address: json['address'] ?? '',
      currentLocation: json['current_location'],
      latitudeLongitude: json['latitude_logitude'], // matches JSON spelling key
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class Plan {
  final String id;
  final String planName;
  final String price;

  Plan({required this.id, required this.planName, required this.price});

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'] ?? '',
      planName: json['planName'] ?? '',
      price: json['price'] ?? '0',
    );
  }
}

class Partner {
  final String id;
  final String? deliveryCounts;
  final String? deliveryRegion;
  final bool isOnline;
  final User? user;

  Partner({
    required this.id,
    this.deliveryCounts,
    this.deliveryRegion,
    required this.isOnline,
    this.user,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['id'] ?? '',
      deliveryCounts: json['deliveryCounts']?.toString(),
      deliveryRegion: json['deliveryRegion'],
      isOnline: json['isonline'] ?? false, // matches JSON lower 'isonline' key
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class User {
  final String id;
  final String name;
  final String? email;
  final String phone;

  User({required this.id, required this.name, this.email, required this.phone});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'] ?? '',
    );
  }
}
