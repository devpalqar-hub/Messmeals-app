import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mess/Screens/HomeScreen/Model/DashboardModel.dart';
import 'package:mess/Screens/HomeScreen/Model/MessModel.dart';
import 'package:mess/Screens/HomeScreen/Model/VariationCountModel.dart';
import 'package:mess/Screens/LoginScreen/LoginScreen.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreenController extends GetxController {
  // Standard variables instead of Rx
  DashboardModel? dashboardData;
  VariationCountModel? variationData;
  bool isLoading = false;
  bool isVariationLoading = false;
  DateTime selectedDate = DateTime.now();
  String authToken = "";
  final AuthController authController = Get.find<AuthController>();
  List<MessModel> messes =[ ];

  @override
  void onInit() {
    super.onInit();

    // Initial fetch if messId exists

    fetchMyMesses();

    if (authController.selectedMessId.isNotEmpty) {
      refreshAllData();
    }
  }

  fetchMyMesses() async {
    authToken = await _getToken() ?? "";

    final response = await http.get(
      Uri.parse('$baseUrl/customer/owners/messes'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );
    print(response.body);
    if (response.statusCode == 200) {
      for (var data in json.decode(response.body)) {
        messes.add(MessModel.fromJson(data));
      }

      update();
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
        update();
      } else if (response.statusCode == 403 || response.statusCode == 401) {
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
      final token = await _getToken();
      final messId = authController.selectedMessId;

      if (messId.isEmpty) return;

      final formattedDate =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      final url = Uri.parse(
        '$baseUrl/customer/variation/count?date=$formattedDate&messId=$messId',
      );

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
    Get.deleteAll();
    Get.offAll(() => LoginScreen());
  }
}
