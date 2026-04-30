import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart' show Fluttertoast, Toast;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
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
  List<Map<String, dynamic>> ownedMesses = [];
  String selectedMessId = "";

  DateTime? tokenExpiry;
  Timer? _logoutTimer;

  void log(String msg) => print("AUTH_LOG → $msg");

  void _refreshUI() => update();

  void safeSnack(String title, String message) {
    if (Get.context == null) return;
    Get.snackbar(title, message, snackPosition: SnackPosition.BOTTOM);
  }

  // --- Auth Methods ---
Future<bool> sendOtp(String phone) async {
  try {
    isLoading = true;
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
      Fluttertoast.showToast(
          msg: data["message"] ?? "OTP sent successfully");
      return true;
    }

    Fluttertoast.showToast(
        msg: data["message"] ?? "User not registered");
    return false;
  } catch (e) {
    debugPrint("❌ SEND OTP ERROR: $e");
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

    final body = {
      "phone": phone,
      "sessionId": sessionId,
      "otp": otp,
    };

    debugPrint("🚀 VERIFY OTP API");
    debugPrint("➡️ URL: $url");
    debugPrint("➡️ BODY: ${jsonEncode(body)}");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    debugPrint("✅ STATUS: ${response.statusCode}");
    debugPrint("✅ RESPONSE: ${response.body}");

    final data = jsonDecode(response.body);

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        data["accessToken"] != null) {
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

    // Fetch messes from API
    await fetchOwnedMesses();

    // Default to first mess if available
    if (ownedMesses.isNotEmpty) {
      selectedMessId = ownedMesses.first["id"]?.toString() ?? "";
      await prefs.setString("selectedMessId", selectedMessId);
    }

    await prefs.setString("token", token);
    await prefs.setString("user", jsonEncode(data["user"]));
    await prefs.setString("ownedMesses", jsonEncode(ownedMesses));
    
    if (tokenExpiry != null) {
      await prefs.setString("tokenExpiry", tokenExpiry!.toIso8601String());
    }

    _startAutoLogoutTimer();
    _refreshUI();
    Get.offAll(() => const DashboardScreen());
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
        selectedMessId = prefs.getString("selectedMessId") ?? "";
        
        final storedMesses = prefs.getString("ownedMesses");
        if (storedMesses != null) {
          try {
            final List<dynamic> decoded = jsonDecode(storedMesses);
            // Robust parsing into List<Map>
            ownedMesses = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
          } catch (e) {
            ownedMesses = [];
          }
        }

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

  Future<void> fetchOwnedMesses() async {
    try {
      final url = Uri.parse("$baseUrl/customer/owners/messes");
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json", 
          "Authorization": bearerToken
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          // Map each item to Map<String, dynamic> safely
          ownedMesses = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
    } catch (e) {
      log("Fetch Messes Error → $e");
    } finally {
      _refreshUI(); // Ensure UI knows messes are loaded
    }
  }

  Future<void> logout({bool showMessage = true}) async {
    await _clearSessionData();
    _refreshUI();

    if (Get.context != null) {
      Get.offAll(() => const LoginScreen());
    }
    
    if (showMessage) safeSnack("Session expired", "Please login again.");
  }

  Future<void> _clearSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    token = "";
    bearerToken = "";
    sessionId = "";
    selectedMessId = "";
    ownedMesses = [];
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