double _parseAmount(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

class ExpenseModel {
  final String id;
  final String messId;
  final String categoryId;
  final String categoryName;
  final String title;
  final double amount;
  final double paidAmount;
  final double balanceDue;
  final bool isFullyPaid;
  final String date;
  final String description;
  final String? receiptUrl;
  final String status;
  final String? paymentMethod;
  final String? paidAt;

  ExpenseModel({
    required this.id,
    required this.messId,
    required this.categoryId,
    required this.categoryName,
    required this.title,
    required this.amount,
    required this.paidAmount,
    required this.balanceDue,
    required this.isFullyPaid,
    required this.date,
    required this.description,
    required this.status,
    this.receiptUrl,
    this.paymentMethod,
    this.paidAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    final category =
        json['category'] is Map ? json['category'] as Map<String, dynamic> : null;
    final amount = _parseAmount(json['amount']);
    final paidAmount = _parseAmount(json['paidAmount']);

    return ExpenseModel(
      id: (json['id'] ?? '').toString(),
      messId: (json['messId'] ?? '').toString(),
      categoryId: (json['categoryId'] ?? category?['id'] ?? '').toString(),
      categoryName: (category?['name'] ?? json['categoryName'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      amount: amount,
      paidAmount: paidAmount,
      balanceDue: _parseAmount(json['balanceDue']) == 0 && json['balanceDue'] == null
          ? (amount - paidAmount)
          : _parseAmount(json['balanceDue']),
      isFullyPaid: json['isFullyPaid'] is bool ? json['isFullyPaid'] as bool : paidAmount >= amount && amount > 0,
      date: (json['expenseDate'] ?? json['date'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      status: (json['status'] ?? 'UNPAID').toString(),
      receiptUrl: json['receiptUrl']?.toString(),
      paymentMethod: json['paymentMethod']?.toString(),
      paidAt: json['paidAt']?.toString(),
    );
  }
}
