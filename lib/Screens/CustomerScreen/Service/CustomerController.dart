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

  var customers = <CustomerModel>[];
  var isLoading = false;
  var isMoreLoading = false;
  var hasMore = true;

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
      hasMore = true;
      customers.clear();
      update(); // 🔥 update UI
    }

    if (!hasMore) return;

    try {
      if (refresh) {
        isLoading = true;
      } else {
        isMoreLoading = true;
      }
      update(); // 🔥

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) return;

      final url =
          '$baseUrl/customer?messId=$messId&page=$page&limit=$limit'
          '${planName != null && planName.isNotEmpty ? '&search=$planName' : ''}';

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

        final fetched =
            list.map((e) => CustomerModel.fromJson(e)).toList();

        if (fetched.length < limit) {
          hasMore = false;
        }

        customers.addAll(fetched);
        page++;
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading = false;
      isMoreLoading = false;
      update(); // 🔥 VERY IMPORTANT
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
    isLoading = true;
    update(); 

    final url = Uri.parse('$baseUrl/customer/register-user');

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

    final response = await http.post(
      url,
      body: jsonEncode(requestBody),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': bearerToken,
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);

      await dashboardController.fetchDashboardStats();
      await refreshCustomers();

      Get.snackbar(
        "Success",
        data['message'] ?? "Customer added successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (Get.isOverlaysOpen) {
        Get.back(closeOverlays: true);
      } else if (Get.key.currentState?.canPop() ?? false) {
        Get.back();
      }
    } else {
      final error = jsonDecode(response.body);
      Get.snackbar(
        "Error",
        error['message'] ?? "Failed to add customer",
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
    isLoading = false;
    update(); // 🔥 IMPORTANT
  }
}

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
    isLoading = true;
    update();

    final url = Uri.parse('$baseUrl/customer/$id');

    final body = jsonEncode({
      "name": name,
      "address": address,
      "latitude_logitude": latitudeLongitude,
      "currentLocation": currentLocation,
      "walletAmount": walletAmount,
      "planId": planId,
      "deliveryPartnerId": deliveryPartnerId,
      if (discount != null) "discount": discount,
    });

    final response = await http.patch(
      url,
      body: body,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': bearerToken,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      await refreshCustomers();

      Get.snackbar(
        "Success",
        data['message'] ?? "Customer updated successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
      );

      await Future.delayed(const Duration(milliseconds: 500));

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
    isLoading = false;
    update(); // 🔥 UI refresh
  }
}


  /// 🔹 Delete Customer
 Future<void> deleteCustomer(String customerProfileId) async {
  try {
    isLoading = true;
    update();

    // Construct URL
    final url = '$baseUrl/customer/$customerProfileId';
    print("🗑 DELETE URL => $url");

    // Headers
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': bearerToken,
    };
    print("🗑 DELETE HEADERS => $headers");

    // Make the DELETE request
    final response = await http.delete(
      Uri.parse(url),
      headers: headers,
    );

    print("🗑 DELETE STATUS CODE => ${response.statusCode}");
    print("🗑 DELETE RESPONSE BODY => ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 204) {
      // Remove customer locally
      customers.removeWhere(
        (c) => c.customerProfileId == customerProfileId,
      );
      print("🗑 Customer removed locally: $customerProfileId");

      // Refresh dashboard stats
      await dashboardController.fetchDashboardStats();

      Get.snackbar(
        "Success",
        "Customer deleted successfully",
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        "Error",
        "Failed to delete customer. Status: ${response.statusCode}",
      );
    }
  } catch (e, stackTrace) {
    print("❌ DELETE EXCEPTION => $e");
    print("❌ STACKTRACE => $stackTrace");
    Get.snackbar("Error", e.toString());
  } finally {
    isLoading = false;
    update(); // Refresh UI
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
    isLoading = true;
    update();

    final url = Uri.parse('$baseUrl/customer/renew-subscription');

    final body = jsonEncode({
      "planId": planId,
      "start_date": startDate,
      "end_date": endDate,
      "deliveryPartnerId": deliveryPartnerId,
      "discount": discount,
      "customerProfileId": customerProfileId,
    });

    final response = await http.post(
      url,
      body: body,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': bearerToken,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      Get.snackbar("Success", "Subscription renewed successfully");

      final customerUrl = Uri.parse('$baseUrl/customer/$customerProfileId');
      final customerResponse = await http.get(customerUrl, headers: {
        'Authorization': bearerToken,
      });

      if (customerResponse.statusCode == 200) {
        final updatedData = jsonDecode(customerResponse.body)['data'];
        final updatedCustomer = CustomerModel.fromJson(updatedData);

        final index = customers.indexWhere((c) => c.id == customerProfileId);
        if (index != -1) {
          customers[index] = updatedCustomer;
          update();
        }

        if (Get.isBottomSheetOpen ?? false) {
          Get.back(result: updatedCustomer);
        }
      }

      return true;
    } else {
      final error = jsonDecode(response.body);
      Get.snackbar("Error", error['message'] ?? "Failed to renew subscription");
      return false;
    }
  } catch (e) {
    Get.snackbar("Error", e.toString());
    return false;
  } finally {
    isLoading = false;
    update();
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
  try {
    isLoading = true;
    update();

    final url = Uri.parse(
      '$baseUrl/customer/cancel-subscription/$activeSubscriptionId',
    );

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': bearerToken,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      Get.snackbar("Success", "Subscription cancelled successfully");

      final customerUrl = Uri.parse('$baseUrl/customer/$customerProfileId');
      final customerResponse = await http.get(customerUrl, headers: {
        'Authorization': bearerToken,
      });

      if (customerResponse.statusCode == 200) {
        final updatedData = jsonDecode(customerResponse.body)['data'];
        final updatedCustomer = CustomerModel.fromJson(updatedData);

        final index = customers.indexWhere((c) => c.id == customerProfileId);
        if (index != -1) {
          customers[index] = updatedCustomer;
          update();
        }

        if (Get.isBottomSheetOpen ?? false) {
          Get.back(result: updatedCustomer);
        }
      }

      return true;
    } else {
      final error = jsonDecode(response.body);
      Get.snackbar("Error", error['message'] ?? "Cancel subscription failed");
      return false;
    }
  } finally {
    isLoading = false;
    update();
  }
}

Future<bool> cancelSubscriptionRange(
  String activeSubscriptionId,
  String customerProfileId, {
  required String cancellationStartDate,
  required String cancellationEndDate,
}) async {
  try {
    isLoading = true;
    update();

    final url = Uri.parse(
      '$baseUrl/customer/cancel-subscription/$activeSubscriptionId',
    );

    final body = jsonEncode({
      "cancellation_start_date": cancellationStartDate,
      "cancellation_end_date": cancellationEndDate,
    });

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': bearerToken,
      },
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);

      Get.snackbar(
        "Success",
        data['message'] ?? "Subscription cancelled successfully",
      );

      final customerUrl = Uri.parse('$baseUrl/customer/$customerProfileId');
      final customerResponse = await http.get(customerUrl, headers: {
        'Authorization': bearerToken,
      });

      if (customerResponse.statusCode == 200) {
        final updatedData = jsonDecode(customerResponse.body)['data'];
        final updatedCustomer = CustomerModel.fromJson(updatedData);

        final index = customers.indexWhere((c) => c.id == customerProfileId);
        if (index != -1) {
          customers[index] = updatedCustomer;
          update();
        }

        if (Get.isBottomSheetOpen ?? false) {
          Get.back(result: updatedCustomer);
        }

        return true;
      }
    } else {
      final error = jsonDecode(response.body);
      Get.snackbar("Error", error['message'] ?? "Cancel subscription failed");
    }
  } catch (e) {
    Get.snackbar("Error", e.toString());
  } finally {
    isLoading = false;
    update();
  }

  return false;
}


  /// 🔹 Update Wallet
 Future<void> updateWalletBalance({
  required String customerProfileId,
  required String amount,
}) async {
  try {
    isLoading = true;
    update();

    final url = Uri.parse(
      '$baseUrl/customer/update-wallet/$customerProfileId',
    );

    final body = jsonEncode({"amount": amount});

    final response = await http.patch(
      url,
      body: body,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': bearerToken,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      Get.snackbar("Success", "Wallet updated successfully");

      await dashboardController.fetchDashboardStats();

      final customerUrl = Uri.parse('$baseUrl/customer/$customerProfileId');
      final customerResponse = await http.get(customerUrl, headers: {
        'Authorization': bearerToken,
      });

      if (customerResponse.statusCode == 200) {
        final updatedData = jsonDecode(customerResponse.body)['data'];
        final updatedCustomer = CustomerModel.fromJson(updatedData);

        final index = customers.indexWhere((c) => c.id == customerProfileId);
        if (index != -1) {
          customers[index] = updatedCustomer;
          update();
        }

        if (Get.isBottomSheetOpen ?? false) {
          Get.back(result: updatedCustomer);
        }
      }
    } else {
      final error = jsonDecode(response.body);
      Get.snackbar("Error", error['message'] ?? "Failed to update wallet");
    }
  } catch (e) {
    Get.snackbar("Error", e.toString());
  } finally {
    isLoading = false;
    update();
  }
}


  /// 🔹 Fetch a single customer (refresh one entry)
  Future<void> fetchCustomerDetails(String customerProfileId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/customer/$customerProfileId'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        final updatedCustomer = CustomerModel.fromJson(data);

        final index = customers
            .indexWhere((c) => c.customerProfileId == customerProfileId);

        if (index != -1) {
          customers[index] = updatedCustomer;
          update();
        }
      }
    } catch (e) {
      debugPrint("Error fetching customer: $e");
    }
  }
}