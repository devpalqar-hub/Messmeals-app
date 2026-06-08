class CustomerDetailModel {
  String? id;
  String? customerProfileId;
  String? name;
  String? email;
  String? phone;
  int? walletBalance;
  String? currentLocation;
  String? latitudeLogitude;
  String? address;
  int? noOfDaysToEnd;
  int? totalOrders;
  int? totalSpent;
  List<ActiveSubscriptions>? activeSubscriptions;

  CustomerDetailModel({
    this.id,
    this.customerProfileId,
    this.name,
    this.email,
    this.phone,
    this.walletBalance,
    this.currentLocation,
    this.latitudeLogitude,
    this.address,
    this.noOfDaysToEnd,
    this.totalOrders,
    this.totalSpent,
    this.activeSubscriptions,
  });

  CustomerDetailModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerProfileId = json['customerProfileId'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    walletBalance = json['walletBalance'];
    currentLocation = json['current_location'];
    latitudeLogitude = json['latitude_logitude'];
    address = json['address'];
    noOfDaysToEnd = json['noOfDaysToEnd'];
    totalOrders = json['totalOrders'];
    totalSpent = json['totalSpent'];
    if (json['activeSubscriptions'] != null) {
      activeSubscriptions = <ActiveSubscriptions>[];
      json['activeSubscriptions'].forEach((v) {
        activeSubscriptions!.add(new ActiveSubscriptions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['customerProfileId'] = this.customerProfileId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['walletBalance'] = this.walletBalance;
    data['current_location'] = this.currentLocation;
    data['latitude_logitude'] = this.latitudeLogitude;
    data['address'] = this.address;
    data['noOfDaysToEnd'] = this.noOfDaysToEnd;
    data['totalOrders'] = this.totalOrders;
    data['totalSpent'] = this.totalSpent;
    if (this.activeSubscriptions != null) {
      data['activeSubscriptions'] =
          this.activeSubscriptions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ActiveSubscriptions {
  String? id;
  String? startDate;
  String? endDate;
  List? seletedDays;
  String? scheduletype;
  int? totalPrice;
  int? discountedPrice;
  String? deliveryPartnerProfileId;
  Plan? plan;
  String? status;

  ActiveSubscriptions({
    this.id,
    this.startDate,
    this.endDate,
    this.seletedDays,
    this.scheduletype,
    this.totalPrice,
    this.discountedPrice,
    this.deliveryPartnerProfileId,
    this.plan,
    this.status,
  });

  ActiveSubscriptions.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    seletedDays = json['seletedDays'];
    scheduletype = json['scheduletype'];
    totalPrice = json['totalPrice'];
    discountedPrice = json['discountedPrice'];
    deliveryPartnerProfileId = json['deliveryPartnerProfileId'];
    status = json["status"];
    plan = json['plan'] != null ? new Plan.fromJson(json['plan']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['seletedDays'] = this.seletedDays;
    data['scheduletype'] = this.scheduletype;
    data['totalPrice'] = this.totalPrice;
    data['discountedPrice'] = this.discountedPrice;
    data['deliveryPartnerProfileId'] = this.deliveryPartnerProfileId;
    if (this.plan != null) {
      data['plan'] = this.plan!.toJson();
    }
    return data;
  }
}

class Plan {
  String? id;
  String? name;
  int? price;

  Plan({this.id, this.name, this.price});

  Plan.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['price'] = this.price;
    return data;
  }
}
