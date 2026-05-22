import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mess/Screens/LoginScreen/Model/DistrictModel.dart';
import 'package:mess/main.dart';

class SignupController extends GetxController {
  // ================== DISTRICTS ==================
  List<DistrictModel> districtList = [];
  DistrictModel? selectedDistrict;
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  final int limit = 50;


  bool otpLoading = false;
  bool signupLoading = false;

  // ================== FORM DATA ==================
  String name = "";
  String ownerName = "";
  String phone = "";
  String email = "";
  String address = "";
  String messName = "";
  String otp = "";

  // ================== FETCH DISTRICTS ==================
  Future<void> fetchDistricts({bool loadMore = false}) async {
    try {
      if (isLoading) return;

      isLoading = true;
      update();

      if (!loadMore) {
        currentPage = 1;
        districtList.clear();
        hasMore = true;
      }

      final response = await http.get(
        Uri.parse(
          "$baseUrl/districts?page=$currentPage&limit=$limit",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List list = data['data'];

        List<DistrictModel> newDistricts =
            list.map((e) => DistrictModel.fromJson(e)).toList();

        districtList.addAll(newDistricts);

        // Check if more data exists
        if (newDistricts.length < limit) {
          hasMore = false;
        } else {
          currentPage++;
        }
      }
    } catch (e) {
      print("District Error: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  void selectDistrict(DistrictModel district) {
    selectedDistrict = district;
    update();
  }


  // ================== SEND OTP ==================
 Future<bool> sendOtp({
  required String name,
  required String ownerName,
  required String phone,
  required String email,
  required String address,
  required String messName,
  required String district,
}) async {
  try {
    otpLoading = true;
    update();

    final url = Uri.parse("$baseUrl/auth/mess-owner/send-otp");

    final requestBody = {
      "name": name,
      "ownerName": ownerName,
      "phone": phone,
      "email": email,
      "address": address,
      "district": district,
      "messName": messName,
    };

    // ================= DEBUG REQUEST =================
    print("🚀 ===== SEND OTP REQUEST =====");
    print("➡️ URL: $url");
    print("➡️ BODY: ${jsonEncode(requestBody)}");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(requestBody),
    );

    // ================= DEBUG RESPONSE =================
    print("✅ ===== SEND OTP RESPONSE =====");
    print("➡️ STATUS CODE: ${response.statusCode}");
    print("➡️ BODY: ${response.body}");

    final data = jsonDecode(response.body);

    if (response.statusCode == 200|| response.statusCode == 201) {
      Get.snackbar("Success", data["message"] ?? "OTP sent");

      print("🎉 OTP SENT SUCCESSFULLY");
      print("📦 Parsed Response: $data");

      return true;
    } else {
      

      return false;
    }
  } catch (e) {
    print("🔥 ===== SEND OTP EXCEPTION =====");
    print("❌ ERROR: $e");

    Get.snackbar("Error", e.toString());
    return false;
  } finally {
    otpLoading = false;
    update();
  }
}
  // ================== SIGNUP ==================
  Future<bool> signup({
    required String name,
    required String ownerName,
    required String phone,
    required String email,
    required String address,
    required String messName,
    required String district,
    required String otp,
  }) async {
    try {
      signupLoading = true;
      update();

      final response = await http.post(
        Uri.parse("$baseUrl/auth/mess-owner/signup"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "name": name,
          "ownerName": ownerName,
          "phone": phone,
          "email": email,
          "address": address,
          "district": district,
          "messName": messName,
          "otp": otp,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", data["message"]);

        // You can store token here later
        // String token = data["accessToken"];

        return true;
      } else {
        Get.snackbar("Error", data["message"] ?? "Signup failed");
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return false;
    } finally {
      signupLoading = false;
      update();
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchDistricts();
  }
}