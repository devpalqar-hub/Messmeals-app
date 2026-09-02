import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mess/Screens/LoginScreen/Model/DistrictModel.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/Screens/Utils/AppToast.dart';
import 'package:mess/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupController extends GetxController {
  // Backend error/message fields sometimes come back as a String, but on
  // validation failures some endpoints return a List or Map instead. Casting
  // those directly to String throws "type 'X' is not a subtype of type
  // 'String'", which is what was crashing the Create Account screen.
  String _extractMessage(dynamic value, String fallback) {
    if (value == null) return fallback;
    if (value is String) return value;
    if (value is List) return value.map((e) => e.toString()).join('\n');
    return value.toString();
  }


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
  String zipcode = "";

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
        Uri.parse("$baseUrl/districts?page=$currentPage&limit=$limit"),
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
  required String zipcode,
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
      //"district": district,
      "postcode": zipcode,
      "messName": messName,
    };

    // =========================================================
    // REQUEST DEBUG
    // =========================================================

    print("\n");
    print("==================================================");
    print("🚀 SEND OTP API REQUEST");
    print("==================================================");

    print("🌐 BASE URL       : $baseUrl");
    print("🔗 ENDPOINT       : /auth/mess-owner/send-otp");
    print("➡️ FULL URL       : $url");
    print("📡 METHOD         : POST");

    print("--------------------------------------------------");
    print("📋 REQUEST HEADERS");
    print("--------------------------------------------------");

    final requestHeaders = {
      "Content-Type": "application/json",
    };

    requestHeaders.forEach((key, value) {
      print("   $key : $value");
    });

    print("--------------------------------------------------");
    print("📦 REQUEST BODY");
    print("--------------------------------------------------");

    print("   name      : $name");
    print("   ownerName : $ownerName");
    print("   phone     : $phone");
    print("   email     : $email");
    print("   address   : $address");
    print("   postcode  : $zipcode");
    print("   messName  : $messName");

    print("--------------------------------------------------");
    print("📤 JSON BODY");
    print("--------------------------------------------------");

    print(jsonEncode(requestBody));

    print("==================================================");
    print("⏳ SENDING REQUEST...");
    print("==================================================");

    // =========================================================
    // API REQUEST
    // =========================================================

    final response = await http.post(
      url,
      headers: requestHeaders,
      body: jsonEncode(requestBody),
    );

    // =========================================================
    // RESPONSE DEBUG
    // =========================================================

    print("\n");
    print("==================================================");
    print("📥 SEND OTP API RESPONSE");
    print("==================================================");

    print("🔢 STATUS CODE    : ${response.statusCode}");
    print("📊 CONTENT LENGTH : ${response.contentLength}");
    print("🔗 REQUEST URL    : ${response.request?.url}");

    print("--------------------------------------------------");
    print("📋 RESPONSE HEADERS");
    print("--------------------------------------------------");

    response.headers.forEach((key, value) {
      print("   $key : $value");
    });

    print("--------------------------------------------------");
    print("📄 RAW RESPONSE BODY");
    print("--------------------------------------------------");

    print(response.body);

    print("==================================================");

    // =========================================================
    // PARSE RESPONSE
    // =========================================================

    dynamic data;

    try {
      data = jsonDecode(response.body);

      print("--------------------------------------------------");
      print("🧩 PARSED RESPONSE");
      print("--------------------------------------------------");

      print(data);

      if (data is Map) {
        data.forEach((key, value) {
          print("   $key : $value");
        });
      }
    } catch (e) {
      print("⚠️ RESPONSE IS NOT VALID JSON");
      print("❌ JSON PARSE ERROR: $e");
    }

    // =========================================================
    // SUCCESS
    // =========================================================

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("\n");
      print("==================================================");
      print("🎉 OTP SENT SUCCESSFULLY");
      print("==================================================");

      if (data is Map) {
        print("✅ Message : ${data["message"]}");
      }

      print("==================================================");

      AppToast.success(
        data is Map
            ? _extractMessage(data["message"], "OTP sent")
            : "OTP sent",
      );

      return true;
    }

    // =========================================================
    // API ERROR
    // =========================================================

    print("\n");
    print("==================================================");
    print("❌ SEND OTP API FAILED");
    print("==================================================");

    print("🔴 Status Code : ${response.statusCode}");
    print("🔴 Response    : ${response.body}");

    if (data is Map) {
      print("🔴 Error       : ${data["error"]}");
      print("🔴 Message     : ${data["message"]}");
      print("🔴 Status      : ${data["status"]}");
    }

    print("==================================================");

    AppToast.error(
      data is Map
          ? _extractMessage(data["message"], "Failed to send OTP")
          : "Failed to send OTP",
    );

    return false;
  } catch (e, stackTrace) {
    // =========================================================
    // EXCEPTION DEBUG
    // =========================================================

    print("\n");
    print("==================================================");
    print("🔥 SEND OTP EXCEPTION");
    print("==================================================");

    print("❌ ERROR TYPE : ${e.runtimeType}");
    print("❌ ERROR      : $e");

    print("--------------------------------------------------");
    print("📚 STACK TRACE");
    print("--------------------------------------------------");

    print(stackTrace);

    print("==================================================");

    AppToast.error(e.toString());

    return false;
  } finally {
    otpLoading = false;
    update();

    print("🔄 OTP LOADING : $otpLoading");
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
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "ownerName": ownerName,
          "phone": phone,
          "email": email,
          "address": address,
          //  "district": district,
          "postcode": zipcode,
          "messName": messName,
          "otp": otp,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToast.success(_extractMessage(data["message"], "Success"));

        // Some signup responses don't include a token (e.g. pending
        // approval), so only store it when it's actually a String.
        final token = data["accessToken"];
        if (token is String && token.isNotEmpty) {
          bearerToken = "Bearer $token";
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString("token", token);
          await prefs.setString("LOGIN", "IN");
        }
        return true;
      } else {
        AppToast.error(_extractMessage(data["message"], "Signup failed"));
        return false;
      }
    } catch (e) {
      AppToast.error(e.toString());
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
