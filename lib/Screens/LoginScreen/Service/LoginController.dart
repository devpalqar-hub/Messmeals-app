import 'dart:async';
import 'dart:convert';
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart' show Fluttertoast;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mess/Screens/Utils/AppToast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mess/main.dart';
import 'package:mess/Screens/HomeScreen/HomeView.dart';
import 'package:mess/Screens/LoginScreen/Model/UserModel.dart';
import 'package:mess/Screens/LoginScreen/LoginScreen.dart';

String bearerToken = "";

class AuthController extends GetxController {
  bool isLoggedIn = false;
  bool isLoading = false;
  String token = "";
  String sessionId = "";
  UserModel? currentUser;

  // List of messes owned by the user
  // List<Map<String, dynamic>> ownedMesses = [];
  // String selectedMessId = "";

  DateTime? tokenExpiry;
  Timer? _logoutTimer;

  TextEditingController phoneController = TextEditingController();

  String selectedCountry = "IN";

  String get countryCode =>
      "+${CountryPickerUtils.getCountryByIsoCode(selectedCountry).phoneCode}";

  /// Set when the last `sendOtp` call failed because no account exists
  /// for the given phone number. Used by the UI to decide whether to
  /// show the "Account Not Found" bottom sheet.
  bool lastLoginUserNotFound = false;
  String lastErrorMessage = "";

  void log(String msg) => print("AUTH_LOG → $msg");

  void _refreshUI() => update();

  void safeSnack(String title, String message) {
    AppToast.show(title: title, message: message);
  }

  // --- Auth Methods ---
  Future<bool> sendOtp(String phone, {bool silent = false}) async {
    try {
      isLoading = true;
      lastLoginUserNotFound = false;
      lastErrorMessage = "";
      _refreshUI();

      final url = Uri.parse("$baseUrl/auth/send-login-otp");

      final requestBody = {"phone": phone};

      debugPrint("🚀 SEND OTP API");
      debugPrint("➡️ URL: $url");
      debugPrint("➡️ BODY: ${jsonEncode(requestBody)}");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      debugPrint("✅ STATUS: ${response.statusCode}");
      debugPrint("✅ RESPONSE: ${response.body}");

      final data = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data["sessionId"] != null) {
        sessionId = data["sessionId"];
        if (!silent) {
          Fluttertoast.showToast(msg: data["message"] ?? "OTP sent successfully");
        }
        return true;
      }

      final message = (data["message"] ?? "User not registered").toString();
      lastErrorMessage = message;

      final lowerMsg = message.toLowerCase();
      lastLoginUserNotFound =
          response.statusCode == 404 ||
          lowerMsg.contains("not regist") ||
          lowerMsg.contains("not found") ||
          lowerMsg.contains("no account") ||
          lowerMsg.contains("does not exist") ||
          lowerMsg.contains("doesn't exist") ||
          lowerMsg.contains("no user");

      if (!silent) Fluttertoast.showToast(msg: message);
      return false;
    } catch (e) {
      debugPrint("❌ SEND OTP ERROR: $e");
      lastErrorMessage = "Something went wrong. Please try again.";
      if (!silent) Fluttertoast.showToast(msg: lastErrorMessage);
      return false;
    } finally {
      isLoading = false;
      _refreshUI();
    }
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    try {
      isLoading = true;
      _refreshUI();

      final url = Uri.parse("$baseUrl/auth/verify-otp");

      final body = {"phone": phone, "sessionId": sessionId, "otp": otp};

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data["accessToken"] != null) {
        bearerToken = "Bearer " + data["accessToken"];

        await _onLoginSuccess(data);
        return true;
      } else {
        safeSnack("Error", data["message"] ?? "Invalid OTP");
        return false;
      }
    } catch (e) {
      debugPrint("❌ VERIFY OTP ERROR: $e");
      return false;
    } finally {
      isLoading = false;
      _refreshUI();
    }
  }

  Future<void> _onLoginSuccess(dynamic data) async {
    final prefs = await SharedPreferences.getInstance();

    token = data["accessToken"];
    bearerToken = "Bearer $token";
    currentUser = UserModel.fromJson(data["user"]);
    isLoggedIn = true;
    tokenExpiry = _decodeTokenExpiry(token);

    await prefs.setString("token", token);
    await prefs.setString("LOGIN", "IN");
    if (tokenExpiry != null) {
      await prefs.setString("tokenExpiry", tokenExpiry!.toIso8601String());
    }

    _startAutoLogoutTimer();
    _refreshUI();
    Get.offAll(() => DashboardScreen());
  }

  // --- Logic Methods ---

  Future<void> checkLoginStatus() async {
    isLoading = true;
    _refreshUI();

    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString("token");
    final storedUser = prefs.getString("user");

    if (storedToken != null && storedUser != null) {
      final expiry = _decodeTokenExpiry(storedToken);
      if (expiry != null && expiry.isAfter(DateTime.now())) {
        token = storedToken;
        bearerToken = "Bearer $token";
        currentUser = UserModel.fromJson(jsonDecode(storedUser));

        tokenExpiry = expiry;
        isLoggedIn = true;
        _startAutoLogoutTimer();
        isLoading = false;
        _refreshUI();
        return;
      }
    }

    await _clearSessionData();
    isLoading = false;
    _refreshUI();
  }

  Future<void> logout({bool showMessage = true}) async {
    await _clearSessionData();
    _refreshUI();

    if (Get.context != null) {
      Get.offAll(() => LoginScreen());
    }

    if (showMessage) safeSnack("Session expired", "Please login again.");
  }

  Future<void> _clearSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    token = "";
    bearerToken = "";
    sessionId = "";
    currentUser = null;
    isLoggedIn = false;
    _logoutTimer?.cancel();
  }

  void _startAutoLogoutTimer() {
    _logoutTimer?.cancel();
    if (tokenExpiry == null) return;
    final seconds = tokenExpiry!.difference(DateTime.now()).inSeconds;
    if (seconds > 0) {
      _logoutTimer = Timer(Duration(seconds: seconds), logout);
    } else {
      logout();
    }
  }

  DateTime? _decodeTokenExpiry(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return null;
      final payload = base64Url.normalize(parts[1]);
      final decoded = jsonDecode(utf8.decode(base64Url.decode(payload)));
      return decoded.containsKey('exp')
          ? DateTime.fromMillisecondsSinceEpoch(decoded['exp'] * 1000)
          : null;
    } catch (e) {
      return null;
    }
  }
}
