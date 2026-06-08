class TierModel {
  String? id;
  int? minCustomers;
  int? maxCustomers;
  String? perCustomerRate;
  bool? isActive;
  String? createdAt;
  String? updatedAt;

  TierModel({
    this.id,
    this.minCustomers,
    this.maxCustomers,
    this.perCustomerRate,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  TierModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    minCustomers = json['minCustomers'];
    maxCustomers = json['maxCustomers'];
    perCustomerRate = json['perCustomerRate'];
    isActive = json['isActive'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['minCustomers'] = this.minCustomers;
    data['maxCustomers'] = this.maxCustomers;
    data['perCustomerRate'] = this.perCustomerRate;
    data['isActive'] = this.isActive;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
