import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mess/Screens/LoginScreen/Model/UserModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mess/main.dart';
import 'package:mess/Screens/HomeScreen/HomeView.dart';
import 'package:mess/Screens/LoginScreen/LoginScreen.dart';

class AuthController extends GetxController {
  RxBool isLoggedIn = false.obs;
  RxString token = "".obs;
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  DateTime? tokenExpiry;
  Timer? _logoutTimer;

  /// ================== SEND REGISTER OTP ==================
  Future<bool> sendRegisterOtp({
    required String name,
    required String phone,
    required String email,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/auth/send-reg-otp");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "phone": phone,
          "email": email,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("OTP Sent", data["message"] ?? "Registration OTP sent!");
        return true;
      } else {
        Get.snackbar("Error", data["message"] ?? "Failed to send OTP");
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return false;
    }
  }

  /// ================== SEND LOGIN OTP ==================
  Future<bool> sendOtp(String phone) async {
    try {
      final url = Uri.parse("$baseUrl/auth/send-login-otp");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("OTP Sent", data["message"] ?? "OTP sent successfully!");
        return true;
      } else {
        Get.snackbar("Error", data["message"] ?? "Failed to send OTP");
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return false;
    }
  }

  /// ================== VERIFY OTP (FOR LOGIN OR REGISTER) ==================
  Future<void> verifyOtp(String phone, String otp) async {
    try {
      final url = Uri.parse("$baseUrl/auth/verify-otp");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone": phone,
          "otp": otp,
        }),
      );

      final data = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data["accessToken"] != null) {
        final prefs = await SharedPreferences.getInstance();

        /// Store token
        token.value = data["accessToken"];

        /// Parse user model
        final userData = data["user"];
        currentUser.value = UserModel.fromJson(userData);
        isLoggedIn.value = true;

        /// Save locally
        await prefs.setString("token", token.value);
        await prefs.setString("user", jsonEncode(userData));

        /// Handle expiry if provided
        if (userData["expiresAt"] != null) {
          tokenExpiry = DateTime.tryParse(userData["expiresAt"]);
          if (tokenExpiry != null) {
            await prefs.setString("expiry", tokenExpiry!.toIso8601String());
            _startAutoLogoutTimer();
          }
        }

        /// Navigate to Dashboard
        Get.offAll(() => const DashboardScreen());
        Get.snackbar("Success", "Welcome ${currentUser.value?.name ?? 'User'}!");
      } else {
        Get.snackbar("Error", data["message"] ?? "Invalid OTP");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  /// ================== AUTO LOGIN CHECK ==================
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString("token");
    final storedUser = prefs.getString("user");
    final expiry = prefs.getString("expiry");

    if (storedToken != null && storedUser != null && expiry != null) {
      final expiryDate = DateTime.tryParse(expiry);
      if (expiryDate != null && DateTime.now().isBefore(expiryDate)) {
        token.value = storedToken;
        currentUser.value = UserModel.fromJson(jsonDecode(storedUser));
        tokenExpiry = expiryDate;
        isLoggedIn.value = true;
        _startAutoLogoutTimer();
        Get.offAll(() => const DashboardScreen());
        return;
      }
    }

    isLoggedIn.value = false;
    Get.offAll(() => const LoginScreen());
  }

  /// ================== AUTO LOGOUT TIMER ==================
  void _startAutoLogoutTimer() {
    _logoutTimer?.cancel();
    if (tokenExpiry != null) {
      final timeToExpire = tokenExpiry!.difference(DateTime.now());
      if (timeToExpire.isNegative) {
        logout();
      } else {
        _logoutTimer = Timer(timeToExpire, logout);
      }
    }
  }

  /// ================== LOGOUT ==================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    token.value = "";
    currentUser.value = null;
    isLoggedIn.value = false;

    Get.offAll(() => const LoginScreen());
    Get.snackbar("Logged Out", "Session ended. Please login again.");
  }
}
