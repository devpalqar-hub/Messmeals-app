import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mess/Screens/HomeScreen/Service/HomeScreenController.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/main.dart' show baseUrl;
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/CustomerModel.dart';

class CustomerController extends GetxController {
   final AuthController authController = Get.put(AuthController());
   final DashboardController dashboardController = Get.find<DashboardController>();

  var customers = <CustomerModel>[].obs;
  var isLoading = false.obs;
  var isMoreLoading = false.obs;
  var hasMore = true.obs;

  int page = 1;
  int limit = 10;

  /// 🔹 Fetch customers (supports optional plan name search)
 Future<void> fetchCustomers({bool refresh = false, String? planName}) async {
    final messId = authController.selectedMessId.value;

    if (messId.isEmpty) {
      Get.snackbar("Error", "Please select a mess first");
      return;
    }

    if (refresh) {
      page = 1;
      hasMore(true);
      customers.clear();
    }

    if (!hasMore.value) return;

    try {
      if (refresh) {
        isLoading(true);
      } else {
        isMoreLoading(true);
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        Get.snackbar("Authentication Error", "Token not found. Please login again.");
        return;
      }

      // ✅ Include messId in URL
      String url =
          '$baseUrl/customer?messId=$messId&page=$page&limit=$limit${planName != null && planName.isNotEmpty ? '&search=$planName' : ''}';

      

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bearerToken,
        },
      );


      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List list = data['data'] ?? [];

        final fetched = list.map((e) => CustomerModel.fromJson(e)).toList();

        if (fetched.length < limit) {
          hasMore(false);
        }

        if (refresh) {
          customers.assignAll(fetched);
        } else {
          customers.addAll(fetched);
        }

        page++;
      } else if (response.statusCode == 401) {
        Get.snackbar("Session Expired", "Please login again.");
      } else {
        Get.snackbar("Error", "Failed to load customers");
      }
    } catch (e, st) {
      
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
      isMoreLoading(false);
    }
  }

  /// 🔹 Pull-to-refresh
  Future<void> refreshCustomers() async {
    await fetchCustomers(refresh: true);
  }
Future<void> addCustomer({
  required String name,
  required String phone,
  required String email,
  required String address,
  required String latitudeLongitude,
  required String currentLocation,
  required bool isActive,
  required String walletAmount,
  required String discount,
  required String planId,
  required String deliveryPartnerId,
  required String startDate,
  required String endDate,
  required String scheduleType,
  required List<String> selectedDays,
}) async {
  try {
    isLoading(true);
    final url = Uri.parse('$baseUrl/customer/register-user');

    // 🧠 Debug: Print payload before sending
    final requestBody = {
      "name": name,
      "phone": phone,
      "email": email,
      "address": address,
      "latitude_logitude": latitudeLongitude,
      "currentLocation": currentLocation,
      "is_active": isActive,
      "walletAmount": walletAmount,
      "discount": discount,
      "planId": planId,
      "deliveryPartnerId": deliveryPartnerId,
      "start_date": startDate,
      "end_date": endDate,
      "scheduleType": scheduleType.toUpperCase(),
      "selectedDays": scheduleType.toUpperCase() == "CUSTOM"
          ? selectedDays.map((d) => d.toUpperCase()).toList()
          : [],
    };

    print("📤 Sending to: $url");
    print("🧾 Request Body: ${jsonEncode(requestBody)}");

    final response = await http.post(
      url,
      body: jsonEncode(requestBody),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': bearerToken,
      },
    );

    print("📥 Response Code: ${response.statusCode}");
    print("📥 Response Body: ${response.body}");

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await dashboardController.fetchDashboardStats();

      Get.snackbar(
        "Success",
        data['message'] ?? "Customer added successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
      );

      await Future.delayed(const Duration(milliseconds: 800));
      await refreshCustomers();

      if (Get.isOverlaysOpen) {
        Get.back(closeOverlays: true);
      } else if (Get.key.currentState?.canPop() ?? false) {
        Get.back();
      }
    } else {
      print("❌ Server Error: ${response.body}");
      final error = jsonDecode(response.body);
      Get.snackbar(
        "Error",
        error['message'] ?? "Failed to add customer (Server Error)",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
      );
    }
  } catch (e, stack) {
    print("⚠️ Exception: $e");
    print("🪜 StackTrace: $stack");
    Get.snackbar(
      "Error",
      "Something went wrong: $e",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.9),
      colorText: Colors.white,
    );
  } finally {
    isLoading(false);
  }
}



  /// 🔹 Update Customer
  Future<void> updateCustomer({
    required String id,
    required String name,
    required String address,
    required String latitudeLongitude,
    required String currentLocation,
    required int walletAmount,
    required String planId,
    required String deliveryPartnerId,
    String? discount,
  }) async {
    try {
      isLoading(true);
      final url = Uri.parse('$baseUrl/customer/$id');

      final body = jsonEncode({
        "name": name,
        "address": address,
        "latitude_logitude": latitudeLongitude,
        "currentLocation": currentLocation,
        "walletAmount": walletAmount,
        "planId": planId,
        "deliveryPartnerId": deliveryPartnerId,
      });

      
      final response = await http.patch(url, body: body, 
        headers: {
        'Content-Type': 'application/json',
        'Authorization': bearerToken, 
      },);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Get.snackbar(
          "Success",
          data['message'] ?? "Customer updated successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
        );

        await Future.delayed(const Duration(milliseconds: 800));
        await refreshCustomers();

        if (Get.isOverlaysOpen) {
          Get.back(closeOverlays: true);
        } else if (Get.key.currentState?.canPop() ?? false) {
          Get.back();
        }
      } else {
        final error = jsonDecode(response.body);
        Get.snackbar(
          "Error",
          error['message'] ?? "Failed to update customer",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  /// 🔹 Delete Customer
  Future<void> deleteCustomer(String id) async {
    try {
      isLoading(true);
      final url = Uri.parse('$baseUrl/customer/$id');
      final response = await http.delete(url,  headers: {
        'Content-Type': 'application/json',
        'Authorization': bearerToken, 
      },);

      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.snackbar("Success", "Customer deleted successfully");
        customers.removeWhere((c) => c.id == id);
          await refreshCustomers();
          await dashboardController.fetchDashboardStats(); 
        Get.back();

      } else {
        final error = json.decode(response.body);
        Get.snackbar("Error", error['message'] ?? "Failed to delete customer");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  /// 🔹 Renew Subscription
  Future<bool> renewSubscription({
    required String planId,
    required String startDate,
    required String endDate,
    required String deliveryPartnerId,
    required String discount,
    required String customerProfileId,
  }) async {
    try {
      isLoading(true);

      final url = Uri.parse('$baseUrl/customer/renew-subscription');
      final body = jsonEncode({
        "planId": planId,
        "start_date": startDate,
        "end_date": endDate,
        "deliveryPartnerId": deliveryPartnerId,
        "discount": discount,
        "customerProfileId": customerProfileId,
      });

      
      final response = await http.post(url, body: body,   headers: {
        'Content-Type': 'application/json',
        'Authorization': bearerToken, 
      },);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", "Subscription renewed successfully");

        await Future.delayed(const Duration(milliseconds: 700));

        final customerUrl = Uri.parse('$baseUrl/customer/$customerProfileId');
        final customerResponse = await http.get(customerUrl);

        if (customerResponse.statusCode == 200) {
          final updatedData = json.decode(customerResponse.body)['data'];
          final updatedCustomer = CustomerModel.fromJson(updatedData);

          final index = customers.indexWhere((c) => c.id == customerProfileId);
          if (index != -1) {
            customers[index] = updatedCustomer;
            customers.refresh();
          }

          if (Get.isBottomSheetOpen ?? false) {
            Get.back(result: updatedCustomer);
          }
        }

        return true;
      } else {
        final error = json.decode(response.body);
        Get.snackbar("Error", error['message'] ?? "Failed to renew subscription");
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return false;
    } finally {
      isLoading(false);
    }
  }
/// 🔹 Pause Subscription
Future<void> pauseSubscription(
  String activeSubscriptionId,
  String customerProfileId,
  DateTime startDate,
  DateTime endDate,
) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      Get.snackbar("Error", "Please login again.");
      return;
    }

    final url = Uri.parse('$baseUrl/customer/pause-subscription/$activeSubscriptionId');
    final body = jsonEncode({
      "customerProfileId": customerProfileId,
      "pause_start_date": DateFormat('yyyy-MM-dd').format(startDate),
  "pause_end_date": DateFormat('yyyy-MM-dd').format(endDate),
    });

    print('🔹 [PauseSubscription] URL => $url');
    print('🔹 [PauseSubscription] Body => $body');
    print('🔹 [PauseSubscription] Token => $token');

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    print('🔹 [PauseSubscription] Status => ${response.statusCode}');
    print('🔹 [PauseSubscription] Response => ${response.body}');

    if (response.statusCode == 200) {
      Get.snackbar(
        "Paused Successfully",
        "Order paused from ${DateFormat('dd MMM').format(startDate)} to ${DateFormat('dd MMM').format(endDate)}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
      );
      await fetchCustomerDetails(customerProfileId);
    } else {
      final error = jsonDecode(response.body);
      Get.snackbar("Error", error['message'] ?? "Failed to pause order");
    }
  } catch (e) {
    print('❌ [PauseSubscription] Exception => $e');
    Get.snackbar("Error", e.toString());
  }
}



  /// 🔹 Cancel Subscription
  Future<bool> cancelSubscription(
    String activeSubscriptionId,
    String customerProfileId,
  ) async {
    isLoading(true);
    final url = Uri.parse('$baseUrl/customer/cancel-subscription/$activeSubscriptionId');
    final response = await http.patch(url,  headers: {
        'Content-Type': 'application/json',
        'Authorization': bearerToken, 
      },);

    if (response.statusCode == 200 || response.statusCode == 201) {
      Get.snackbar("Success", "Subscription cancelled successfully");

     

      final customerUrl = Uri.parse('$baseUrl/customer/$customerProfileId');
      final customerResponse = await http.get(customerUrl);

      if (customerResponse.statusCode == 200) {
        final updatedData = json.decode(customerResponse.body)['data'];
        final updatedCustomer = CustomerModel.fromJson(updatedData);

        final index = customers.indexWhere((c) => c.id == customerProfileId);
        if (index != -1) {
          customers[index] = updatedCustomer;
          customers.refresh();
        }

        if (Get.isBottomSheetOpen ?? false) {
          Get.back(result: updatedCustomer);
        }
        return true;
      }
    } else {
      final error = json.decode(response.body);
      Get.snackbar("Error", error['message'] ?? "Cancel subscription failed");
    }
    isLoading(false);
    return false;
  }

  /// 🔹 Update Wallet
  Future<void> updateWalletBalance({
    required String customerProfileId,
    required String amount,
  }) async {
    try {
      isLoading(true);
      final url = Uri.parse('$baseUrl/customer/update-wallet/$customerProfileId');
      final body = jsonEncode({"amount": amount});
      final headers = {"Content-Type": "application/json"};

      final response = await http.patch(url, body: body, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", "Wallet updated successfully");
        await dashboardController.fetchDashboardStats(); 

        final customerUrl = Uri.parse('$baseUrl/customer/$customerProfileId');
        final customerResponse = await http.get(customerUrl);

        if (customerResponse.statusCode == 200) {
          final updatedData = json.decode(customerResponse.body)['data'];
          final updatedCustomer = CustomerModel.fromJson(updatedData);

          final index = customers.indexWhere((c) => c.id == customerProfileId);
          if (index != -1) {
            customers[index] = updatedCustomer;
            customers.refresh();
          }

          if (Get.isBottomSheetOpen ?? false) {
            Get.back(result: updatedCustomer);
          }
        }
      } else {
        final error = json.decode(response.body);
        Get.snackbar("Error", error['message'] ?? "Failed to update wallet");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
    } finally {
      isLoading(false);
    }
  }

  /// 🔹 Fetch a single customer (refresh one entry)
  Future<void> fetchCustomerDetails(String customerProfileId) async {
    try {
      final url = Uri.parse('$baseUrl/customer/$customerProfileId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        final updatedCustomer = CustomerModel.fromJson(data);

        final index =
            customers.indexWhere((c) => c.customerProfileId == customerProfileId);
        if (index != -1) {
          customers[index] = updatedCustomer;
          customers.refresh();
        }

        update();
      }
    } catch (e) {
      debugPrint("Error fetching customer: $e");
    }
  }
}
