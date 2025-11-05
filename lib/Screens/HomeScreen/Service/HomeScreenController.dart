import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mess/Screens/HomeScreen/Model/DashboardModel.dart';
import 'package:mess/Screens/HomeScreen/Model/VariationCountModel.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardController extends GetxController {
  var dashboardData = Rxn<DashboardModel>();
  var variationData = Rxn<VariationCountModel>();
  var isLoading = false.obs;
  var isVariationLoading = false.obs;
  var selectedDate = DateTime.now().obs;

  final AuthController authController = Get.put(AuthController());

  @override
  void onInit() {
    super.onInit();

    // 🔹 Automatically fetch data when selected mess changes
    ever(authController.selectedMessId, (_) {
      if (authController.selectedMessId.value.isNotEmpty) {
        fetchDashboardStats();
        fetchVariationCount(selectedDate.value);
      }
    });

    // 🔹 If mess already selected, fetch data immediately
    if (authController.selectedMessId.value.isNotEmpty) {
      fetchDashboardStats();
      fetchVariationCount(selectedDate.value);
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// ===================== DASHBOARD STATS =====================
  Future<void> fetchDashboardStats() async {
    try {
      isLoading.value = true;
      final token = await _getToken();
      final messId = authController.selectedMessId.value;

      if (messId.isEmpty) {
       
        return;
      }

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
        dashboardData.value = DashboardModel.fromJson(data);
      } else if (response.statusCode == 403) {
        Get.snackbar("Session Expired", "Please log in again.");
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        Get.offAllNamed('/login');
      } else {
        Get.snackbar("Error", "Failed to fetch dashboard stats");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// ===================== VARIATION COUNT =====================
  Future<void> fetchVariationCount(DateTime date) async {
    try {
      isVariationLoading.value = true;
      final token = await _getToken();
      final messId = authController.selectedMessId.value;

      if (messId.isEmpty) {
        print("⚠️ No mess selected. Skipping fetchVariationCount.");
        return;
      }

      final formattedDate =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final url = Uri.parse(
          '$baseUrl/customer/variation/count?date=$formattedDate&messId=$messId');

      print("📅 Fetching variation for: $formattedDate");
      print("🟢 URL: $url");

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("🔹 Status: ${response.statusCode}");
      print("🔹 Body: ${response.body}");

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

  void updateDate(DateTime newDate) {
    selectedDate.value = newDate;
    fetchVariationCount(newDate);
  }
}
