import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mess/main.dart' show baseUrl;
import '../Model/CustomerModel.dart';

class CustomerController extends GetxController {
  var customers = <CustomerModel>[].obs;
  var isLoading = false.obs;
  var isMoreLoading = false.obs;
  var hasMore = true.obs;

  int page = 1;
  int limit = 10;

  /// 🔹 Fetch customers (supports optional plan name search)
  Future<void> fetchCustomers({bool refresh = false, String? planName}) async {
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

      // ✅ Build URL dynamically with optional planName
      String url =
          '$baseUrl/customer?page=$page&limit=$limit${planName != null && planName.isNotEmpty ? '&search=$planName' : ''}';
      print("🌐 GET $url");

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List list = data['data'];

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
      } else {
        Get.snackbar("Error", "Failed to load customers");
      }
    } catch (e) {
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

  /// 🔹 Add Customer
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
  }) async {
    try {
      isLoading(true);
      final url = Uri.parse('$baseUrl/customer/register-user');

      final body = jsonEncode({
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
      });

      final headers = {"Content-Type": "application/json"};
      final response = await http.post(url, body: body, headers: headers);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);

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
        final error = jsonDecode(response.body);
        Get.snackbar(
          "Error",
          error['message'] ?? "Failed to add customer (Server Error)",
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

      final headers = {"Content-Type": "application/json"};
      final response = await http.patch(url, body: body, headers: headers);

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
      final response = await http.delete(url);

      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.snackbar("Success", "Customer deleted successfully");
        customers.removeWhere((c) => c.id == id);
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

      final headers = {"Content-Type": "application/json"};
      final response = await http.post(url, body: body, headers: headers);

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

  /// 🔹 Cancel Subscription
  Future<bool> cancelSubscription(
    String activeSubscriptionId,
    String customerProfileId,
  ) async {
    isLoading(true);
    final url = Uri.parse('$baseUrl/customer/cancel-subscription/$activeSubscriptionId');
    final response = await http.patch(url);

    if (response.statusCode == 200 || response.statusCode == 201) {
      Get.snackbar("Success", "Subscription cancelled successfully");

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
      debugPrint("❌ Error fetching customer: $e");
    }
  }
}
