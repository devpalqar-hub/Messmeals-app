// DELIVERY PARTNER MODULE — DISABLED (admin-only build for now)
// Entire file commented out below; not wired into the app.
/*
import 'package:get/get.dart';
import 'package:mess/Screens/DeliveryPartner/Earnings/Models/EarningsModel.dart';

/// Placeholder earnings data source — the backend has no earnings module
/// for delivery agents yet. UI is fully built against this so it's a
/// drop-in swap once a real endpoint exists.
class MockEarningsController extends GetxController {
  final List<DayEarning> weekly = [
    DayEarning(day: 'Mon', amount: 1300),
    DayEarning(day: 'Tue', amount: 2100),
    DayEarning(day: 'Wed', amount: 1600),
    DayEarning(day: 'Thu', amount: 2400),
    DayEarning(day: 'Fri', amount: 2000),
    DayEarning(day: 'Sat', amount: 1800),
    DayEarning(day: 'Sun', amount: 1700),
  ];

  final List<EarningsTransactionModel> transactions = [
    EarningsTransactionModel(
      id: '1',
      customerName: 'Sona',
      mealLabel: 'Lunch',
      date: '09 Sep 2026',
      amount: 200,
      isPaid: true,
    ),
    EarningsTransactionModel(
      id: '2',
      customerName: 'Priya',
      mealLabel: 'Dinner',
      date: '09 Sep 2026',
      amount: 200,
      isPaid: false,
    ),
    EarningsTransactionModel(
      id: '3',
      customerName: 'Aromal',
      mealLabel: 'Breakfast',
      date: '08 Sep 2026',
      amount: 200,
      isPaid: true,
    ),
    EarningsTransactionModel(
      id: '4',
      customerName: 'Vishnu',
      mealLabel: 'Lunch',
      date: '08 Sep 2026',
      amount: 200,
      isPaid: true,
    ),
    EarningsTransactionModel(
      id: '5',
      customerName: 'Anjali',
      mealLabel: 'Dinner',
      date: '07 Sep 2026',
      amount: 200,
      isPaid: false,
    ),
    EarningsTransactionModel(
      id: '6',
      customerName: 'Ramesh',
      mealLabel: 'Lunch',
      date: '06 Sep 2026',
      amount: 200,
      isPaid: true,
    ),
    EarningsTransactionModel(
      id: '7',
      customerName: 'Sona',
      mealLabel: 'Breakfast',
      date: '06 Sep 2026',
      amount: 200,
      isPaid: true,
    ),
  ];

  double get totalEarnings =>
      transactions.fold(0, (sum, t) => sum + t.amount);

  double get paidTotal =>
      transactions.where((t) => t.isPaid).fold(0, (sum, t) => sum + t.amount);

  double get pendingTotal =>
      transactions.where((t) => !t.isPaid).fold(0, (sum, t) => sum + t.amount);

  int get deliveriesCount => transactions.length;

  int get paidCount => transactions.where((t) => t.isPaid).length;

  double get todayEarnings => weekly.isNotEmpty ? weekly.last.amount : 0;

  List<EarningsTransactionModel> get paidTransactions =>
      transactions.where((t) => t.isPaid).toList();

  List<EarningsTransactionModel> get pendingTransactions =>
      transactions.where((t) => !t.isPaid).toList();
}

*/
