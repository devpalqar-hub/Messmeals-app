import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mess/Screens/HomeScreen/HomeView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mess/main.dart';
import 'package:mess/Screens/LoginScreen/Model/UserModel.dart';
import 'package:mess/Screens/LoginScreen/LoginScreen.dart';

String bearerToken = "";

class AuthController extends GetxController {
  RxBool isLoggedIn = false.obs;
  RxBool isLoading = false.obs;
  RxString token = "".obs;
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  RxList<Map<String, dynamic>> ownedMesses = <Map<String, dynamic>>[].obs;
  RxString selectedMessId = "".obs;

  DateTime? tokenExpiry;
  Timer? _logoutTimer;

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

  /// ================== VERIFY OTP ==================
  Future<void> verifyOtp(String phone, String otp) async {
    try {
      final url = Uri.parse("$baseUrl/auth/verify-otp");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone, "otp": otp}),
      );

      final data = jsonDecode(response.body);

      if ((response.statusCode == 201) && data["accessToken"] != null) {
        final prefs = await SharedPreferences.getInstance();

        token.value = data["accessToken"];
        bearerToken = "Bearer ${token.value}";
        currentUser.value = UserModel.fromJson(data["user"]);
        isLoggedIn.value = true;

        tokenExpiry = _decodeTokenExpiry(token.value);
        if (tokenExpiry == null) {
          logout();
          return;
        }

        await fetchOwnedMesses();

        if (ownedMesses.isNotEmpty) {
          selectedMessId.value = ownedMesses.first["id"];
          await prefs.setString("selectedMessId", selectedMessId.value);
        }

        await prefs.setString("token", token.value);
        await prefs.setString("user", jsonEncode(data["user"]));
        await prefs.setString("ownedMesses", jsonEncode(ownedMesses));
        await prefs.setString("tokenExpiry", tokenExpiry!.toIso8601String());

        _startAutoLogoutTimer();

       Get.offAll(() => const DashboardScreen());
      } else {
        Get.snackbar("Error", data["message"] ?? "Invalid OTP");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  /// ================== FETCH OWNED MESSES ==================
  Future<void> fetchOwnedMesses() async {
    try {
      isLoading(true);
      final url = Uri.parse("$baseUrl/customer/owners/messes");
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": bearerToken,
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          ownedMesses.value = List<Map<String, dynamic>>.from(decoded);
        } else {
          ownedMesses.clear();
        }
      } else {
        ownedMesses.clear();
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  /// ================== CHECK LOGIN STATUS ==================
  Future<void> checkLoginStatus() async {
    isLoading(true);
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString("token");
    final storedUser = prefs.getString("user");
    final storedSelectedMessId = prefs.getString("selectedMessId");
    final storedOwnedMesses = prefs.getString("ownedMesses");

    if (storedToken != null && storedUser != null) {
      final expiry = _decodeTokenExpiry(storedToken);
      final now = DateTime.now();

      if (expiry != null && expiry.isAfter(now)) {
        token.value = storedToken;
        bearerToken = "Bearer ${token.value}";
        currentUser.value = UserModel.fromJson(jsonDecode(storedUser));
        selectedMessId.value = storedSelectedMessId ?? "";

        if (storedOwnedMesses != null) {
          ownedMesses.value =
              List<Map<String, dynamic>>.from(jsonDecode(storedOwnedMesses));
        }

        tokenExpiry = expiry;
        isLoggedIn.value = true;
        _startAutoLogoutTimer();
        isLoading(false);
        return;
      }
    }

    logout();
    isLoading(false);
  }

  /// ================== AUTO LOGOUT TIMER ==================
  void _startAutoLogoutTimer() {
    _logoutTimer?.cancel();
    if (tokenExpiry == null) return;

    final secondsUntilLogout =
        tokenExpiry!.difference(DateTime.now()).inSeconds;

    if (secondsUntilLogout > 0) {
      _logoutTimer = Timer(Duration(seconds: secondsUntilLogout), logout);
    } else {
      logout();
    }
  }

  /// ================== DECODE JWT TOKEN EXPIRY ==================
  DateTime? _decodeTokenExpiry(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return null;

      final payload =
          jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      if (payload.containsKey('exp')) {
        final exp = payload['exp'];
        return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// ================== LOGOUT ==================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    token.value = "";
    bearerToken = "";
    selectedMessId.value = "";
    ownedMesses.clear();
    currentUser.value = null;
    isLoggedIn.value = false;
    _logoutTimer?.cancel();

    Get.offAll(() => const LoginScreen());
    Get.snackbar("Session expired", "Please login again.");
  }
}
