import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mess/Screens/HomeScreen/Model/DashboardModel.dart';
import 'package:mess/Screens/HomeScreen/Model/VariationCountModel.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardController extends GetxController {
  // Standard variables instead of Rx
  DashboardModel? dashboardData;
  VariationCountModel? variationData;
  bool isLoading = false;
  bool isVariationLoading = false;
  DateTime selectedDate = DateTime.now();

  final AuthController authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    
    // Initial fetch if messId exists
    if (authController.selectedMessId.isNotEmpty) {
      refreshAllData();
    }
  }

  // Helper to refresh everything and update UI
  void refreshAllData() {
    fetchDashboardStats();
    fetchVariationCount(selectedDate);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchDashboardStats() async {
    try {
      isLoading = true;
      update(); // Notify UI to show loader

      final token = await _getToken();
      final messId = authController.selectedMessId;

      if (messId.isEmpty) return;

      final url = Uri.parse('$baseUrl/auth/stats?messId=$messId');
    
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        dashboardData = DashboardModel.fromJson(data);
      } else if (response.statusCode == 403) {
        _handleLogout();
      } else {
        Get.snackbar("Error", "Failed to fetch dashboard stats");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading = false;
      update(); // Notify UI that loading is finished
    }
  }

  Future<void> fetchVariationCount(DateTime date) async {
    try {
      isVariationLoading = true;
      update();

      final token = await _getToken();
      final messId = authController.selectedMessId;

      if (messId.isEmpty) return;

      final formattedDate =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      
      final url = Uri.parse(
          '$baseUrl/customer/variation/count?date=$formattedDate&messId=$messId');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        variationData = VariationCountModel.fromJson(data);
      } else {
        Get.snackbar("Error", "Failed to fetch variation count");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isVariationLoading = false;
      update();
    }
  }

  void updateDate(DateTime newDate) {
    selectedDate = newDate;
    fetchVariationCount(newDate);
    // update() is called inside fetchVariationCount finally block
  }

  Future<void> _handleLogout() async {
    Get.snackbar("Session Expired", "Please log in again.");
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Get.offAllNamed('/login');
  }
}