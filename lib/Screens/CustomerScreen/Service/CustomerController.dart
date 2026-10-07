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
import 'package:mess/main.dart' show baseUrl, bearerToken;
import 'package:shared_preferences/shared_preferences.dart';

class CustomerController extends GetxController {
  final HomeScreenController dashboardController =
      Get.find<HomeScreenController>();

  var customers = <CustomerModel>[];
  var isLoading = false;
  var isMoreLoading = false;
  var hasMore = true;

  var summary = CustomerSummaryModel.empty();
  var isSummaryLoading = false;

  int page = 1;
  int limit = 10;

  /// The backend's error `message` field isn't always a plain string (e.g.
  /// NestJS validation errors return a list) — this turns whatever shape
  /// comes back into something safe to show in a toast.
  String _extractErrorMessage(String responseBody, String fallback) {
    try {
      final decoded = jsonDecode(responseBody);
      final msg = decoded is Map ? decoded['message'] : null;
      if (msg is String && msg.isNotEmpty) return msg;
      if (msg is List && msg.isNotEmpty) return msg.join(', ');
      return fallback;
    } catch (_) {
      return fallback;
    }
  }

  /// 📊 Fetch summary stats (active subscriptions / ending soon / amount to collect)
  Future<void> fetchCustomerSummary() async {
    final messId = dashboardController.selectedMessId;
    if (messId == null) return;

    try {
      isSummaryLoading = true;
      update();

      final response = await http.get(
        Uri.parse('$baseUrl/customer/summary?messId=$messId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bearerToken,
        },
      );

      if (response.statusCode == 200) {
        summary = CustomerSummaryModel.fromJson(json.decode(response.body));
      }
    } catch (e) {
      debugPrint("❌ SUMMARY ERROR: $e");
    } finally {
      isSummaryLoading = false;
      update();
    }
  }

  Future<void> fetchCustomers({
    bool refresh = false,
    String? search,
    String? planId,
    String? subscriptionFilter,
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
          '$baseUrl/customer?page=$page&limit=$limit&messId=$messId'
          '${search != null && search.isNotEmpty ? '&search=$search' : ''}'
          '${planId != null && planId.isNotEmpty ? '&planId=$planId' : ''}'
          '${subscriptionFilter != null && subscriptionFilter.isNotEmpty ? '&subscriptionFilter=$subscriptionFilter' : ''}';
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
      final messId = dashboardController.selectedMessId;
      if (messId == null) {
        Fluttertoast.showToast(
          msg: "No mess selected. Please select a mess first.",
        );
        return false;
      }

      final url = Uri.parse("$baseUrl/customer/register-user");
      final requestBody = {
        "name": name,
        "phone": phone,
        if (email.isNotEmpty) "email": email,
        "address": address,
        "location": location,
        "messId": messId, // ← THIS was missing
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

      // Surface the backend's real reason for ANY failure, not just
      // 400/409 — a 403 (or anything else) used to fall through to a bare
      // "Failed: 403" with the actual cause thrown away, making it
      // impossible to tell a permission issue from a session/validation
      // one. `message` can also come back as a List (e.g. validator-style
      // field errors), which `?? fallback` alone doesn't guard against.
      Fluttertoast.showToast(
        msg: _extractErrorMessage(
          response.body,
          "Failed: ${response.statusCode}",
        ),
      );
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

      final response = await http.patch(
        url,
        body: jsonEncode(bodyMap),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bearerToken,
        },
      );

      if (kDebugMode) {
        debugPrint("STATUS: ${response.statusCode}");
        debugPrint("BODY: ${_prettyJsonString(response.body)}");
      }

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
      debugPrint("❌ UPDATE CUSTOMER ERROR: $e\n$stack");
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

      final response = await http.delete(
        Uri.parse('$baseUrl/customer/$Id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bearerToken,
        },
      );

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

      final response = await http.post(
        Uri.parse('$baseUrl/customer/renew-subscription'),
        body: jsonEncode({
          "planId": planId,
          "start_date": startDate,
          "end_date": endDate,
          "deliveryPartnerId": deliveryPartnerId,
          "discount": discount,
          "customerProfileId": customerProfileId,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bearerToken,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await dashboardController.fetchDashboardStats();
        await refreshCustomers();
        AppToast.success("Subscription renewed successfully");

        final customerResponse = await http.get(
          Uri.parse('$baseUrl/customer/$customerProfileId'),
          headers: {'Authorization': bearerToken},
        );

        if (customerResponse.statusCode == 200) {
          final updatedCustomer = CustomerModel.fromJson(
            jsonDecode(customerResponse.body)['data'],
          );
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

      final response = await http.patch(
        Uri.parse('$baseUrl/customer/pause-subscription/$activeSubscriptionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "customerProfileId": customerProfileId,
          "pause_start_date": DateFormat('yyyy-MM-dd').format(startDate),
          "pause_end_date": DateFormat('yyyy-MM-dd').format(endDate),
        }),
      );

      if (response.statusCode == 200) {
        AppToast.show(
          title: "Paused Successfully",
          message:
              "Order paused from ${DateFormat('dd MMM').format(startDate)} to ${DateFormat('dd MMM').format(endDate)}",
        );
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

      final response = await http.patch(
        Uri.parse(
          '$baseUrl/customer/cancel-subscription/$activeSubscriptionId',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bearerToken,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToast.success("Subscription cancelled successfully");

        final customerResponse = await http.get(
          Uri.parse('$baseUrl/customer/$customerProfileId'),
          headers: {'Authorization': bearerToken},
        );

        if (customerResponse.statusCode == 200) {
          final updatedCustomer = CustomerModel.fromJson(
            jsonDecode(customerResponse.body)['data'],
          );
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

      final response = await http.patch(
        Uri.parse('$baseUrl/customer/update-wallet/$customerProfileId'),
        body: jsonEncode({"amount": amount}),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bearerToken,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToast.success("Wallet updated successfully");
        await dashboardController.fetchDashboardStats();

        final customerResponse = await http.get(
          Uri.parse('$baseUrl/customer/$customerProfileId'),
          headers: {'Authorization': bearerToken},
        );

        if (customerResponse.statusCode == 200) {
          final updatedCustomer = CustomerModel.fromJson(
            jsonDecode(customerResponse.body)['data'],
          );
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
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/customer/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': bearerToken,
        },
      );

      if (response.statusCode == 200) {
        final updatedCustomer = CustomerModel.fromJson(
          json.decode(response.body)['data'],
        );
        final index = customers.indexWhere((c) => c.id == id);
        if (index != -1) {
          customers[index] = updatedCustomer;
          update();
        }
      }
    } catch (e) {
      debugPrint("❌ ERROR: $e");
    }
  }

  String _prettyJsonString(String input) {
    try {
      return const JsonEncoder.withIndent('  ').convert(jsonDecode(input));
    } catch (_) {
      return input;
    }
  }
}
