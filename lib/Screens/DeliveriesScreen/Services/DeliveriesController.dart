import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mess/Screens/DeliveriesScreen/Model/DeliveryModel.dart';
import 'package:mess/Screens/HomeScreen/Service/HomeScreenController.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/main.dart';

class DeliveriesController extends GetxController {
   final AuthController authController = Get.put(AuthController());
   final DashboardController dashboardController = Get.find<DashboardController>();

  var isLoading = false.obs;
  var deliveries = <Delivery>[].obs;
  var page = 1.obs;
  var limit = 10.obs;

  /// ✅ Fetch Deliveries (with optional date and status filters)
  Future<void> fetchDeliveries({
    DateTime? date,
    String? status,
  }) async {
    try {
      isLoading.value = true;

      final messId = authController.selectedMessId.value;
      if (messId.isEmpty) {
        Get.snackbar("Error", "Please select a mess first");
        isLoading.value = false;
        return;
      }

      // 🔹 Build query params dynamically
      final Map<String, String> queryParams = {
        'page': page.value.toString(),
        'limit': limit.value.toString(),
        'messId': messId,
      };

      if (date != null) {
        queryParams['date'] = date.toIso8601String().split('T')[0];
      }

      if (status != null && status.trim().isNotEmpty) {
        queryParams['status'] = status.toUpperCase();
      }

      final uri = Uri.parse('$baseUrl/deliveries')
          .replace(queryParameters: queryParams);
    

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bearerToken,
        },
      );

     
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> dataList = jsonData['data'] ?? [];
        deliveries.value = dataList.map((e) => Delivery.fromJson(e)).toList();
       
      } else {
        Get.snackbar('Error', 'Failed to fetch deliveries: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load deliveries: $e');
   
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Generate Deliveries by Date
  Future<void> generateDeliveriesByDate(DateTime date) async {
    try {
      isLoading.value = true;

      final response = await http.post(
        Uri.parse('$baseUrl/deliveries/create-by-date'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"date": date.toIso8601String().split('T')[0]}),
      );

  

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Deliveries generated successfully');
        await dashboardController.fetchDashboardStats(); 
        await fetchDeliveries(date: date);
      } else {
        final msg = json.decode(response.body)['message'] ?? 'Unknown error';
        Get.snackbar('Error', 'Failed to generate deliveries: $msg');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error generating deliveries: $e');
     
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Update Delivery Status (PENDING, PROGRESS, DELIVERED)
  Future<void> updateDeliveryStatus(String deliveryId, String newStatus) async {
    try {
      isLoading.value = true;

      final url = Uri.parse('$baseUrl/deliveries/$deliveryId/status');
      final body = json.encode({"status": newStatus.toUpperCase()});


      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );


      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final updatedStatus = data['status'] ?? newStatus;
        Get.snackbar('Success', 'Delivery status updated to $updatedStatus');
         await dashboardController.fetchDashboardStats(); 
        await fetchDeliveries(); // refresh list after update
      } else {
        final msg = json.decode(response.body)['message'] ?? 'Unknown error';
        Get.snackbar('Error', 'Failed to update status: $msg');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error updating delivery status: $e');
   
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Search Deliveries (helper for UI filters)
  Future<void> searchDeliveries({
    DateTime? date,
    String? status,
  }) async {
    print("🔎 Searching deliveries for → date: $date, status: $status");
    await fetchDeliveries(date: date, status: status);
  }
}
