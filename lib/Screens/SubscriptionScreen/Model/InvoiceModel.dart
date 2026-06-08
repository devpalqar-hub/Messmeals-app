class InvoiceModel {
  String? id;
  String? messId;
  String? periodStart;
  String? periodEnd;
  String? dueDate;
  int? customerCount;
  String? rate;
  String? amount;
  String? status;
  String? paidAt;
  String? razorpayOrderId;
  String? razorpayPaymentId;
  String? razorpaySignature;
  String? paymentProcessedAt;
  String? createdAt;
  String? updatedAt;

  InvoiceModel({
    this.id,
    this.messId,
    this.periodStart,
    this.periodEnd,
    this.dueDate,
    this.customerCount,
    this.rate,
    this.amount,
    this.status,
    this.paidAt,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.razorpaySignature,
    this.paymentProcessedAt,
    this.createdAt,
    this.updatedAt,
  });

  InvoiceModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    messId = json['messId'];
    periodStart = json['periodStart'];
    periodEnd = json['periodEnd'];
    dueDate = json['dueDate'];
    customerCount = json['customerCount'];
    rate = json['rate'];
    amount = json['amount'];
    status = json['status'];
    paidAt = json['paidAt'];
    razorpayOrderId = json['razorpayOrderId'];
    razorpayPaymentId = json['razorpayPaymentId'];
    razorpaySignature = json['razorpaySignature'];
    paymentProcessedAt = json['paymentProcessedAt'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['messId'] = this.messId;
    data['periodStart'] = this.periodStart;
    data['periodEnd'] = this.periodEnd;
    data['dueDate'] = this.dueDate;
    data['customerCount'] = this.customerCount;
    data['rate'] = this.rate;
    data['amount'] = this.amount;
    data['status'] = this.status;
    data['paidAt'] = this.paidAt;
    data['razorpayOrderId'] = this.razorpayOrderId;
    data['razorpayPaymentId'] = this.razorpayPaymentId;
    data['razorpaySignature'] = this.razorpaySignature;
    data['paymentProcessedAt'] = this.paymentProcessedAt;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
