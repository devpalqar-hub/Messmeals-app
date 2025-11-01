class Delivery {
  final String id;
  final String date;
  final String status;
  final Customer? customer;
  final Plan? plan;
  final Partner? partner;

  Delivery({
    required this.id,
    required this.date,
    required this.status,
    this.customer,
    this.plan,
    this.partner,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] ?? '',
      customer: json['customer'] != null ? Customer.fromJson(json['customer']) : null,
      plan: json['plan'] != null ? Plan.fromJson(json['plan']) : null,
      partner: json['partner'] != null ? Partner.fromJson(json['partner']) : null,
    );
  }
}

class Customer {
  final String id;
  final String address;
  final User? user;

  Customer({
    required this.id,
    required this.address,
    this.user,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? '',
      address: json['address'] ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class Plan {
  final String id;
  final String planName;
  final String price;

  Plan({
    required this.id,
    required this.planName,
    required this.price,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'] ?? '',
      planName: json['planName'] ?? '',
      price: json['price'] ?? '',
    );
  }
}

class Partner {
  final String id;
  final String deliveryRegion;
  final User? user;

  Partner({
    required this.id,
    required this.deliveryRegion,
    this.user,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['id'] ?? '',
      deliveryRegion: json['deliveryRegion'] ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String phone;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}
