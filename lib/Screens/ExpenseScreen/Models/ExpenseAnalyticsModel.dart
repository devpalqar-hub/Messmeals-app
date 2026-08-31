double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

/// One amount/count bucket, e.g. the "paid"/"unpaid"/"pending"/"total"
/// entries inside GET /expenses' embedded `summary` block, or the
/// `{ totalExpense, totalCount }` shape returned by
/// GET /expenses/analytics/summary.
class ExpenseAmountCount {
  final double amount;
  final double paidAmount;
  final int count;

  ExpenseAmountCount({
    required this.amount,
    required this.paidAmount,
    required this.count,
  });

  factory ExpenseAmountCount.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ExpenseAmountCount(amount: 0, paidAmount: 0, count: 0);
    }
    return ExpenseAmountCount(
      amount: _toDouble(json['amount'] ?? json['totalExpense'] ?? json['total']),
      paidAmount: _toDouble(json['paidAmount']),
      count: _toInt(json['count'] ?? json['totalCount']),
    );
  }
}

/// The `summary` block embedded in GET /expenses:
/// { total, paid, partiallyPaid, unpaid, pending } — each an amount/count
/// pair, scoped to the current category/date-range/search filters and
/// independent of the status filter, so tab counters stay stable while
/// switching tabs.
class ExpenseListSummary {
  final ExpenseAmountCount total;
  final ExpenseAmountCount paid;
  final ExpenseAmountCount partiallyPaid;
  final ExpenseAmountCount unpaid;
  final ExpenseAmountCount pending;

  ExpenseListSummary({
    required this.total,
    required this.paid,
    required this.partiallyPaid,
    required this.unpaid,
    required this.pending,
  });

  factory ExpenseListSummary.fromJson(Map<String, dynamic>? json) {
    Map<String, dynamic>? bucket(String key) =>
        json?[key] is Map ? json![key] as Map<String, dynamic> : null;

    return ExpenseListSummary(
      total: ExpenseAmountCount.fromJson(bucket('total')),
      paid: ExpenseAmountCount.fromJson(bucket('paid')),
      partiallyPaid: ExpenseAmountCount.fromJson(bucket('partiallyPaid')),
      unpaid: ExpenseAmountCount.fromJson(bucket('unpaid')),
      pending: ExpenseAmountCount.fromJson(bucket('pending')),
    );
  }
}
