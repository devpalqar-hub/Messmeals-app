// lib/Screens/DashboardScreen/Model/DashboardModel.dart
class DashboardModel {
  final double totalRevenue;
  final int completedOrders;
  final int totalOrders;
  final int totalCustomers;
  final int totalPartners;
  final int activePartners;
  final double avgPerCustomer;
  final double pendingRevenue;
  final double todaysRevenue;

  DashboardModel({
    required this.totalRevenue,
    required this.completedOrders,
    required this.totalOrders,
    required this.totalCustomers,
    required this.totalPartners,
    required this.activePartners,
    required this.avgPerCustomer,
    required this.pendingRevenue,
    required this.todaysRevenue,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      completedOrders: json['completedOrders'] ?? 0,
      totalOrders: json['totalOrders'] ?? 0,
      totalCustomers: json['totalCustomers'] ?? 0,
      totalPartners: json['totalPartners'] ?? 0,
      activePartners: json['activePartners'] ?? 0,
      avgPerCustomer: (json['avgPerCustomer'] ?? 0).toDouble(),
      pendingRevenue: (json['pendingRevenue'] ?? 0).toDouble(),
      todaysRevenue: (json['todaysRevenue'] ?? 0).toDouble(),
    );
  }
}
