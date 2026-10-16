import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mess/Screens/DeliveryPartner/Profile/Models/DeliveryAgentProfileModel.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/Screens/Utils/AppToast.dart';
import 'package:mess/main.dart';

class DeliveryProfileController extends GetxController {
  bool isLoading = false;
  bool isSaving = false;

  DeliveryAgentProfileModel? profile;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading = true;
    update();

    try {
      final uri = Uri.parse('$baseUrl/delivery-agent/get/profile');
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data =
            decoded is Map && decoded['data'] is Map
                ? decoded['data']
                : decoded;
        profile = DeliveryAgentProfileModel.fromJson(
          Map<String, dynamic>.from(data),
        );
      }
    } catch (e) {
      debugPrint('FETCH DELIVERY PROFILE ERROR: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  /// Updates name/phone against the real backend record. [vehicleType] and
  /// [vehicleNumber] are kept in local state only (see model doc comment).
  Future<bool> updateProfile({
    required String name,
    required String phone,
    required String vehicleType,
    required String vehicleNumber,
  }) async {
    if (profile == null) return false;
    isSaving = true;
    update();

    try {
      final uri = Uri.parse('$baseUrl/delivery-agent/${profile!.id}');
      final response = await http
          .patch(
            uri,
            headers: _headers,
            body: jsonEncode({"name": name, "phone": phone}),
          )
          .timeout(const Duration(seconds: 15));

      profile = profile!.copyWith(
        name: name,
        phone: phone,
        vehicleType: vehicleType,
        vehicleNumber: vehicleNumber,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToast.success('Profile updated successfully');
        return true;
      }

      // Even if the server-side save fails, keep the locally-editable
      // vehicle fields updated since they aren't persisted anyway.
      AppToast.error('Saved locally — profile update failed on server');
      return false;
    } catch (e) {
      debugPrint('UPDATE DELIVERY PROFILE ERROR: $e');
      AppToast.error('Something went wrong');
      return false;
    } finally {
      isSaving = false;
      update();
    }
  }

  Map<String, String> get _headers => {
    "Content-Type": "application/json",
    "Authorization": bearerToken,
  };
}
