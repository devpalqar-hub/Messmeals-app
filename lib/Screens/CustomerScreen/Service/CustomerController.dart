import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mess/Screens/CustomerScreen/Model/CustomerModel.dart';
import 'package:mess/Screens/HomeScreen/Service/HomeScreenController.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/Screens/Utils/AppToast.dart';
import 'package:mess/main.dart' show baseUrl;
import 'package:shared_preferences/shared_preferences.dart';

class CustomerController extends GetxController {
  // final AuthController authController = Get.put(AuthController());
  final HomeScreenController dashboardController =
      Get.find<HomeScreenController>();

  var customers = <CustomerModel>[];
  var isLoading = false;
  var isMoreLoading = false;
  var hasMore = true;

  int page = 1;
  int limit = 10;

  Future<void> fetchCustomers({
    bool refresh = false,
    String? search,
    String? planId,
  }) async {
    final messId = dashboardController.selectedMessId;

    if (messId == null) {
      AppToast.error("Please select a mess first");
      return;
    }

    if (refresh) {
      page = 1;
      hasMore = true;
      customers.clear();
      update();
    }

    if (!hasMore) return;

    try {
      isLoading = refresh;
      isMoreLoading = !refresh;
      update();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        debugPrint("❌ Token missing");
        return;
      }

      final url =
          '$baseUrl/customer?page=$page&limit=$limit&messId=$messId '
          '${search != null && search.isNotEmpty ? '&search=$search' : ''}'
          '${planId != null && planId.isNotEmpty ? '&planId=$planId' : ''}';
      debugPrint("--------url: $url");

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

        debugPrint("📦 ITEMS RECEIVED: ${list.length}");

        final fetched = list.map((e) => CustomerModel.fromJson(e)).toList();

        if (fetched.length < limit) {
          hasMore = false;
          debugPrint("⚠️ hasMore = false (end of list)");
        }

        customers.addAll(fetched);
        page++;

        debugPrint("📊 TOTAL CUSTOMERS: ${customers.length}");
      } else {
        debugPrint("❌ API ERROR: ${response.statusCode}");
        AppToast.error("Failed to fetch customers");
      }
    } catch (e) {
      AppToast.error(e.toString());
    } finally {
      isLoading = false;
      isMoreLoading = false;
      update();
    }
  }

  Future<void> refreshCustomers() async {
    await fetchCustomers(refresh: true);
  }

  Future<bool> addCustomer({
    required String name,
    required String phone,
    required String email,
    required String address,
    required String location,
    required String planId,
    required String deliveryPartnerId,
    required String startDate,
    required String endDate,
    required String walletAmount,
    required String discountAmount,
    required String deliveryType,
    required String preferredTime,
    required List<String> deliveryDays,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/customer/register-user");
      final requestBody = {
        "name": name,
        "phone": phone,
        if (email.isNotEmpty) "email": email,
        "address": address,
        "location": location,
        "planId": planId,
        "deliveryPartnerId": deliveryPartnerId,
        "start_date": DateFormat(
          "yyyy-MM-dd",
        ).format(DateTime.parse(startDate)),
        "end_date": DateFormat("yyyy-MM-dd").format(DateTime.parse(endDate)),

        "walletAmount": double.tryParse(walletAmount) ?? 0,

        "discountAmount": double.tryParse(discountAmount) ?? 0,

        "deliveryType": deliveryType,

        "preferredTime": preferredTime,

        "deliveryDays": deliveryDays,
      };

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": bearerToken,
        },
        body: jsonEncode(requestBody),
      );
      if (response.body.isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);

          debugPrint(const JsonEncoder.withIndent('  ').convert(decoded));
        } catch (e) {}
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        Fluttertoast.showToast(msg: "Customer added successfully");

        return true;
      }

      Fluttertoast.showToast(msg: "Failed: ${response.statusCode}");

      return false;
    } catch (e) {
      return false;
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

      final bodyMap = {
        "name": name,
        "address": address,
        "latitude_logitude": latitudeLongitude,
        "currentLocation": currentLocation,
        "walletAmount": walletAmount,
        "planId": planId,
        "deliveryPartnerId": deliveryPartnerId,
        if (discount != null) "discount": discount,
      };

      final body = jsonEncode(bodyMap);

      final startTime = DateTime.now();

      final response = await http.patch(
        url,
        body: body,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bearerToken,
        },
      );

      final endTime = DateTime.now();

      /// 🔥 RESPONSE LOG
      if (kDebugMode) {
        debugPrint("=========== UPDATE CUSTOMER RESPONSE ==========");
        debugPrint("STATUS   : ${response.statusCode}");
        debugPrint(
          "TIME     : ${endTime.difference(startTime).inMilliseconds} ms",
        );
        debugPrint("BODY     : ${_prettyJsonString(response.body)}");
        debugPrint("===============================================");
      }

      /// 🔥 401 AUTO LOGOUT (IMPORTANT)
      // if (response.statusCode == 401) {
      //   Get.snackbar("Session Expired", "Please login again");
      //   await authController.logout(); // make sure you have this
      //   return;
      // }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        await dashboardController.fetchDashboardStats();
        await refreshCustomers();

        AppToast.success(data['message'] ?? "Customer updated successfully");

        await Future.delayed(const Duration(milliseconds: 500));

        if (Get.isOverlaysOpen) {
          Get.back(closeOverlays: true);
        } else if (Get.key.currentState?.canPop() ?? false) {
          Get.back();
        }
      } else {
        final error = jsonDecode(response.body);

        AppToast.error(error['message'] ?? "Failed to update customer");
      }
    } catch (e, stack) {
      debugPrint("❌ UPDATE CUSTOMER ERROR: $e");
      debugPrint("📍 STACK TRACE: $stack");

      AppToast.error("Something went wrong: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> deleteCustomer(String Id) async {
    try {
      isLoading = true;
      update();

      final url = '$baseUrl/customer/$Id';
      debugPrint("🗑 DELETE URL => $url");

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bearerToken,
        },
      );

      debugPrint("🗑 STATUS => ${response.statusCode}");
      debugPrint("🗑 BODY => ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        customers.removeWhere((c) => c.id == Id);
        await refreshCustomers();
        await dashboardController.fetchDashboardStats();

        AppToast.success("Customer deleted successfully");
      } else {
        AppToast.error("Failed to delete customer");
      }
    } catch (e) {
      AppToast.error(e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }

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

      final Map<String, dynamic> bodyMap = {
        "planId": planId,
        "start_date": startDate,
        "end_date": endDate,
        "deliveryPartnerId": deliveryPartnerId,
        "discount": discount,
        "customerProfileId": customerProfileId,
      };

      final body = jsonEncode(bodyMap);

      // ⏱️ Start time

      final response = await http.post(
        url,
        body: body,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bearerToken,
        },
      );

      // ⏱️ End time

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ Refresh dashboard
        await dashboardController.fetchDashboardStats();
        await refreshCustomers();

        AppToast.success("Subscription renewed successfully");

        // ✅ Refresh single customer
        final customerUrl = Uri.parse('$baseUrl/customer/$customerProfileId');
        final customerResponse = await http.get(
          customerUrl,
          headers: {'Authorization': bearerToken},
        );

        if (customerResponse.statusCode == 200) {
          final updatedData = jsonDecode(customerResponse.body)['data'];
          final updatedCustomer = CustomerModel.fromJson(updatedData);

          final index = customers.indexWhere((c) => c.id == customerProfileId);
          if (index != -1) {
            customers[index] = updatedCustomer;
            update();
          }
        }

        return true;
      } else {
        final error = jsonDecode(response.body);
        AppToast.error(error['message'] ?? "Failed to renew subscription");
        return false;
      }
    } catch (e) {
      AppToast.error(e.toString());
      return false;
    } finally {
      isLoading = false;
      update();
    }
  }

  String _prettyJsonString(String input) {
    try {
      final jsonObj = jsonDecode(input);
      return const JsonEncoder.withIndent('  ').convert(jsonObj);
    } catch (e) {
      return input;
    }
  }

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
        AppToast.error("Please login again.");
        return;
      }

      final url = Uri.parse(
        '$baseUrl/customer/pause-subscription/$activeSubscriptionId',
      );

      final bodyMap = {
        "customerProfileId": customerProfileId,
        "pause_start_date": DateFormat('yyyy-MM-dd').format(startDate),
        "pause_end_date": DateFormat('yyyy-MM-dd').format(endDate),
      };

      final body = jsonEncode(bodyMap);

      /// 🔥 LOG REQUEST
      debugPrint("========== PAUSE SUBSCRIPTION REQUEST ==========");
      debugPrint("URL: $url");
      debugPrint("METHOD: PATCH");
      debugPrint(
        "HEADERS: {Content-Type: application/json, Authorization: Bearer $token}",
      );
      debugPrint("BODY: $body");
      debugPrint("================================================");

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      /// 🔥 LOG RESPONSE
      debugPrint("========== PAUSE SUBSCRIPTION RESPONSE ==========");
      debugPrint("STATUS CODE: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");
      debugPrint("=================================================");

      if (response.statusCode == 200) {
        await refreshCustomers();

        AppToast.show(
          title: "Paused Successfully",
          message:
              "Order paused from ${DateFormat('dd MMM').format(startDate)} to ${DateFormat('dd MMM').format(endDate)}",
        );

        // Refresh data
        await dashboardController.fetchDashboardStats();
        await refreshCustomers();
        await fetchCustomerDetails(customerProfileId);
      } else {
        final error = jsonDecode(response.body);
        AppToast.error(error['message'] ?? "Failed to pause order");
      }
    } catch (e) {
      debugPrint("❌ EXCEPTION: $e");
      AppToast.error(e.toString());
    }
  }

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

      /// 🔥 LOG REQUEST
      debugPrint("========== CANCEL SUBSCRIPTION REQUEST ==========");
      debugPrint("URL: $url");
      debugPrint("METHOD: PATCH");
      debugPrint(
        "HEADERS: {Content-Type: application/json, Authorization: $bearerToken}",
      );
      debugPrint("BODY: {}");
      debugPrint("=================================================");

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bearerToken,
        },
      );

      /// 🔥 LOG RESPONSE
      debugPrint("========== CANCEL SUBSCRIPTION RESPONSE ==========");
      debugPrint("STATUS CODE: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");
      debugPrint("==================================================");

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToast.success("Subscription cancelled successfully");

        /// 🔥 FETCH UPDATED CUSTOMER
        final customerUrl = Uri.parse('$baseUrl/customer/$customerProfileId');

        debugPrint("====== FETCH UPDATED CUSTOMER REQUEST ======");
        debugPrint("URL: $customerUrl");
        debugPrint("METHOD: GET");
        debugPrint("HEADERS: {Authorization: $bearerToken}");
        debugPrint("===========================================");

        final customerResponse = await http.get(
          customerUrl,
          headers: {'Authorization': bearerToken},
        );

        /// 🔥 LOG CUSTOMER RESPONSE
        debugPrint("====== FETCH UPDATED CUSTOMER RESPONSE ======");
        debugPrint("STATUS CODE: ${customerResponse.statusCode}");
        debugPrint("BODY: ${customerResponse.body}");
        debugPrint("============================================");

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
        AppToast.error(error['message'] ?? "Cancel subscription failed");
        return false;
      }
    } catch (e) {
      debugPrint("❌ EXCEPTION: $e");
      AppToast.error(e.toString());
      return false;
    } finally {
      isLoading = false;
      update();
    }
  }

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

      final bodyMap = {"amount": amount};
      final body = jsonEncode(bodyMap);

      /// 🔥 LOG REQUEST
      debugPrint("========== UPDATE WALLET REQUEST ==========");
      debugPrint("URL: $url");
      debugPrint("METHOD: PATCH");
      debugPrint(
        "HEADERS: {Content-Type: application/json, Authorization: $bearerToken}",
      );
      debugPrint("BODY: $body");
      debugPrint("===========================================");

      final response = await http.patch(
        url,
        body: body,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bearerToken,
        },
      );

      /// 🔥 LOG RESPONSE
      debugPrint("========== UPDATE WALLET RESPONSE ==========");
      debugPrint("STATUS CODE: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");
      debugPrint("============================================");

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToast.success("Wallet updated successfully");

        await dashboardController.fetchDashboardStats();

        /// 🔥 FETCH UPDATED CUSTOMER
        final customerUrl = Uri.parse('$baseUrl/customer/$customerProfileId');

        debugPrint("====== FETCH UPDATED CUSTOMER REQUEST ======");
        debugPrint("URL: $customerUrl");
        debugPrint("METHOD: GET");
        debugPrint("HEADERS: {Authorization: $bearerToken}");
        debugPrint("===========================================");

        final customerResponse = await http.get(
          customerUrl,
          headers: {'Authorization': bearerToken},
        );

        /// 🔥 LOG CUSTOMER RESPONSE
        debugPrint("====== FETCH UPDATED CUSTOMER RESPONSE ======");
        debugPrint("STATUS CODE: ${customerResponse.statusCode}");
        debugPrint("BODY: ${customerResponse.body}");
        debugPrint("============================================");

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
        AppToast.error(error['message'] ?? "Failed to update wallet");
      }
    } catch (e) {
      debugPrint("❌ EXCEPTION: $e");
      AppToast.error(e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> fetchCustomerDetails(String id) async {
    final url = '$baseUrl/customer/$id';

    try {
      debugPrint("🚀 FETCH CUSTOMER DETAILS → $id");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bearerToken,
        },
      );

      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];

        final updatedCustomer = CustomerModel.fromJson(data);

        final index = customers.indexWhere((c) => c.id == id);

        if (index != -1) {
          customers[index] = updatedCustomer;
          update();
          debugPrint("✅ Customer updated in list");
        } else {
          debugPrint("⚠️ Customer NOT FOUND in list");
        }
      }
    } catch (e) {
      debugPrint("❌ ERROR: $e");
    }
  }
}
