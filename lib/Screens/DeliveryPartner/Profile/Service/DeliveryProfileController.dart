// DELIVERY PARTNER MODULE — DISABLED (admin-only build for now)
// Entire file commented out below; not wired into the app.
/*
import 'dart:convert';
import 'dart:io';

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
  bool isUploadingLicense = false;
  bool isUploadingRc = false;

  DeliveryAgentProfileModel? profile;

  /// Local-only document state — no backend field exists yet to persist
  /// these against the agent's record (see DeliveryAgentProfileModel).
  String? licenseUrl;
  String? vehicleRcUrl;
  bool licenseVerified = true; // mocked
  bool rcVerified = true; // mocked

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
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = decoded is Map && decoded['data'] is Map ? decoded['data'] : decoded;
        profile = DeliveryAgentProfileModel.fromJson(Map<String, dynamic>.from(data));
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
      final response = await http.patch(
        uri,
        headers: _headers,
        body: jsonEncode({"name": name, "phone": phone}),
      );

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

  Future<void> uploadLicense(File file) async {
    await _uploadDocument(file, isLicense: true);
  }

  Future<void> uploadVehicleRc(File file) async {
    await _uploadDocument(file, isLicense: false);
  }

  Future<void> _uploadDocument(File file, {required bool isLicense}) async {
    if (isLicense) {
      isUploadingLicense = true;
    } else {
      isUploadingRc = true;
    }
    update();

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/s3/upload'),
      );
      request.headers['Authorization'] = bearerToken;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamed = await request.send();
      final body = await streamed.stream.bytesToString();

      if (streamed.statusCode == 200 || streamed.statusCode == 201) {
        final decoded = jsonDecode(body);
        final url =
            decoded is Map
                ? (decoded['url'] ?? (decoded['data'] is Map ? decoded['data']['url'] : null))
                : null;

        if (isLicense) {
          licenseUrl = url?.toString();
        } else {
          vehicleRcUrl = url?.toString();
        }
        AppToast.success('Document uploaded — pending verification');
      } else {
        AppToast.error('Upload failed');
      }
    } catch (e) {
      debugPrint('UPLOAD DOCUMENT ERROR: $e');
      AppToast.error('Something went wrong');
    } finally {
      if (isLicense) {
        isUploadingLicense = false;
      } else {
        isUploadingRc = false;
      }
      update();
    }
  }

  Map<String, String> get _headers => {
    "Content-Type": "application/json",
    "Authorization": bearerToken,
  };
}

*/
