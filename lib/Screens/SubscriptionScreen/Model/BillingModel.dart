class BillingModel {
  String? messId;
  String? messName;
  bool? isActive;
  String? messStatus;
  bool? onTrial;
  CurrentPeriod? currentPeriod;
  String? nextBillingDate;
  String? nextDueDate;
  int? customerCount;
  int? perCustomerRate;
  String? rateSource;
  int? amount;
  int? perCustomerRateOverride;
  UnpaidInvoice? unpaidInvoice;
  bool? billingDisabled;
  String? billingDisabledAt;
  String? billingReactivatesAt;
  Enforcement? enforcement;

  BillingModel({
    this.messId,
    this.messName,
    this.isActive,
    this.messStatus,
    this.onTrial,
    this.currentPeriod,
    this.nextBillingDate,
    this.nextDueDate,
    this.customerCount,
    this.perCustomerRate,
    this.rateSource,
    this.amount,
    this.perCustomerRateOverride,
    this.unpaidInvoice,
    this.billingDisabled,
    this.billingDisabledAt,
    this.billingReactivatesAt,
    this.enforcement,
  });

  BillingModel.fromJson(Map<String, dynamic> json) {
    messId = json['messId'];
    messName = json['messName'];
    isActive = json['isActive'];
    messStatus = json['messStatus'];
    onTrial = json['onTrial'];
    currentPeriod =
        json['currentPeriod'] != null
            ? new CurrentPeriod.fromJson(json['currentPeriod'])
            : null;
    nextBillingDate = json['nextBillingDate'];
    nextDueDate = json['nextDueDate'];
    customerCount = json['customerCount'];
    perCustomerRate = json['perCustomerRate'];
    rateSource = json['rateSource'];
    amount = json['amount'];
    perCustomerRateOverride = json['perCustomerRateOverride'];
    unpaidInvoice =
        json['unpaidInvoice'] != null
            ? new UnpaidInvoice.fromJson(json['unpaidInvoice'])
            : null;
    billingDisabled = json['billingDisabled'];
    billingDisabledAt = json['billingDisabledAt'];
    billingReactivatesAt = json['billingReactivatesAt'];
    enforcement =
        json['enforcement'] != null
            ? new Enforcement.fromJson(json['enforcement'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['messId'] = this.messId;
    data['messName'] = this.messName;
    data['isActive'] = this.isActive;
    data['messStatus'] = this.messStatus;
    data['onTrial'] = this.onTrial;
    if (this.currentPeriod != null) {
      data['currentPeriod'] = this.currentPeriod!.toJson();
    }
    data['nextBillingDate'] = this.nextBillingDate;
    data['nextDueDate'] = this.nextDueDate;
    data['customerCount'] = this.customerCount;
    data['perCustomerRate'] = this.perCustomerRate;
    data['rateSource'] = this.rateSource;
    data['amount'] = this.amount;
    data['perCustomerRateOverride'] = this.perCustomerRateOverride;
    if (this.unpaidInvoice != null) {
      data['unpaidInvoice'] = this.unpaidInvoice!.toJson();
    }
    data['billingDisabled'] = this.billingDisabled;
    data['billingDisabledAt'] = this.billingDisabledAt;
    data['billingReactivatesAt'] = this.billingReactivatesAt;
    if (this.enforcement != null) {
      data['enforcement'] = this.enforcement!.toJson();
    }
    return data;
  }
}

class CurrentPeriod {
  String? periodStart;
  String? periodEnd;
  String? dueDate;

  CurrentPeriod({this.periodStart, this.periodEnd, this.dueDate});

  CurrentPeriod.fromJson(Map<String, dynamic> json) {
    periodStart = json['periodStart'];
    periodEnd = json['periodEnd'];
    dueDate = json['dueDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['periodStart'] = this.periodStart;
    data['periodEnd'] = this.periodEnd;
    data['dueDate'] = this.dueDate;
    return data;
  }
}

class UnpaidInvoice {
  String? id;
  String? status;
  int? amount;
  String? dueDate;
  String? periodStart;
  String? periodEnd;
  int? customerCount;
  int? perCustomerRate;
  String? createdAt;

  UnpaidInvoice({
    this.id,
    this.status,
    this.amount,
    this.dueDate,
    this.periodStart,
    this.periodEnd,
    this.customerCount,
    this.perCustomerRate,
    this.createdAt,
  });

  UnpaidInvoice.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    amount = json['amount'];
    dueDate = json['dueDate'];
    periodStart = json['periodStart'];
    periodEnd = json['periodEnd'];
    customerCount = json['customerCount'];
    perCustomerRate = json['perCustomerRate'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['status'] = this.status;
    data['amount'] = this.amount;
    data['dueDate'] = this.dueDate;
    data['periodStart'] = this.periodStart;
    data['periodEnd'] = this.periodEnd;
    data['customerCount'] = this.customerCount;
    data['perCustomerRate'] = this.perCustomerRate;
    data['createdAt'] = this.createdAt;
    return data;
  }
}

class Enforcement {
  bool? billingDisabled;
  String? dueDate;
  String? disableAt;

  Enforcement({this.billingDisabled, this.dueDate, this.disableAt});

  Enforcement.fromJson(Map<String, dynamic> json) {
    billingDisabled = json['billingDisabled'];
    dueDate = json['dueDate'];
    disableAt = json['disableAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['billingDisabled'] = this.billingDisabled;
    data['dueDate'] = this.dueDate;
    data['disableAt'] = this.disableAt;
    return data;
  }
}
