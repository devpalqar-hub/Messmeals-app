// lib/Screens/DashboardScreen/Service/DashboardController.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mess/main.dart';
import '../Model/DashboardModel.dart';
import '../Model/VariationCountModel.dart';

class DashboardController extends GetxController {
  var dashboardData = Rxn<DashboardModel>();
  var variationData = Rxn<VariationCountModel>();
  var isLoading = false.obs;
  var isVariationLoading = false.obs;

  // Selected date from calendar
  var selectedDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardStats();
    fetchVariationCount(selectedDate.value);
  }

  /// Fetch overall dashboard stats
  Future<void> fetchDashboardStats() async {
    try {
      isLoading.value = true;
      final response = await http.get(Uri.parse('$baseUrl/auth/stats'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        dashboardData.value = DashboardModel.fromJson(data);
      } else {
        Get.snackbar("Error", "Failed to fetch dashboard stats");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch variation count by selected date
  Future<void> fetchVariationCount(DateTime date) async {
    try {
      isVariationLoading.value = true;
      final formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      final response = await http.get(
        Uri.parse('$baseUrl/customer/variation/count?date=$formattedDate'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        variationData.value = VariationCountModel.fromJson(data);
      } else {
        Get.snackbar("Error", "Failed to fetch variation count");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isVariationLoading.value = false;
    }
  }

  /// Called when user picks a new date from calendar
  // inside DashboardController
void updateDate(DateTime newDate) {
  selectedDate.value = newDate;
  fetchVariationCount(newDate);
}

}
