import 'dart:async';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart' show Fluttertoast, Toast, ToastGravity;
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
  RxString sessionId = "".obs;
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  RxList<Map<String, dynamic>> ownedMesses = <Map<String, dynamic>>[].obs;
  RxString selectedMessId = "".obs;

  DateTime? tokenExpiry;
  Timer? _logoutTimer;

  
  void log(String msg) => print("AUTH_LOG → $msg");

  void safeSnack(String title, String message) {
    if (Get.context == null) {
      log("SNACK BLOCKED ($title): $message");
      return;
    }
    Future.delayed(const Duration(milliseconds: 100), () {
      if (Get.context != null) {
        Get.snackbar(
          title,
          message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    });
  }

  Future<bool> sendOtp(String phone) async {
  try {
    isLoading(true); 
    log("Sending OTP…");

    final url = Uri.parse("$baseUrl/auth/send-login-otp");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"phone": phone}),
    );

    final data = jsonDecode(response.body);
    log("RAW RESPONSE → $data");

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        data["sessionId"] != null) {
      sessionId.value = data["sessionId"];

      Fluttertoast.showToast(
        msg: data["message"] ?? "OTP sent successfully",
        toastLength: Toast.LENGTH_SHORT,
      );

      return true; 
    }


    Fluttertoast.showToast(
      msg: data["message"] ?? "User not registered",
      toastLength: Toast.LENGTH_SHORT,
    );

    return false;
  } catch (e) {
    Fluttertoast.showToast(
      msg: "Something went wrong",
      toastLength: Toast.LENGTH_SHORT,
    );
    log("Send OTP Error → $e");
    return false;
  } finally {
    isLoading(false); 
  }
}


 Future<bool> verifyOtp(String phone, String otp) async {
  try {
    log("Verifying OTP…");

    final url = Uri.parse("$baseUrl/auth/verify-otp");
    final body = {
      "phone": phone,
      "sessionId": sessionId.value,
      "otp": otp,
    };

    log("VERIFY BODY → $body");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);
    log("Verify OTP Response → $data");

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        data["accessToken"] != null) {
      await _onLoginSuccess(data);
      return true; 
    } else {
      safeSnack("Error", data["message"] ?? "Invalid OTP");
      return false; 
    }
  } catch (e) {
    safeSnack("Error", e.toString());
    log("Verify OTP Error → $e");
    return false;
  }
}

  Future<void> _onLoginSuccess(dynamic data) async {
    final prefs = await SharedPreferences.getInstance();

    token.value = data["accessToken"];
    bearerToken = "Bearer ${token.value}";

    currentUser.value = UserModel.fromJson(data["user"]);
    isLoggedIn.value = true;

    tokenExpiry = _decodeTokenExpiry(token.value);

    await fetchOwnedMesses();

    if (ownedMesses.isNotEmpty) {
      selectedMessId.value = ownedMesses.first["id"];
      await prefs.setString("selectedMessId", selectedMessId.value);
    }

    await prefs.setString("token", token.value);
    await prefs.setString("user", jsonEncode(data["user"]));
    await prefs.setString("ownedMesses", jsonEncode(ownedMesses));
    if (tokenExpiry != null) {
      await prefs.setString("tokenExpiry", tokenExpiry!.toIso8601String());
    }

    _startAutoLogoutTimer();

    log("LOGIN SUCCESS → Redirecting Dashboard");
    Get.offAll(() => const DashboardScreen());
  }

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

      log("Fetch Messes Response → ${response.body}");

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
      safeSnack("Error", e.toString());
      log("Fetch Messes Error → $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> checkLoginStatus() async {
    log("Checking login status…");
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

    logout(showMessage: false);
    isLoading(false);
  }

  void _startAutoLogoutTimer() {
    _logoutTimer?.cancel();
    if (tokenExpiry == null) return;

    final secondsUntilLogout = tokenExpiry!.difference(DateTime.now()).inSeconds;

    if (secondsUntilLogout > 0) {
      log("Auto-logout in $secondsUntilLogout seconds");
      _logoutTimer = Timer(Duration(seconds: secondsUntilLogout), logout);
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

      if (decoded.containsKey('exp')) {
        return DateTime.fromMillisecondsSinceEpoch(decoded['exp'] * 1000);
      }
      return null;
    } catch (e) {
      log("JWT Decode Error → $e");
      return null;
    }
  }

  Future<void> logout({bool showMessage = true}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    token.value = "";
    bearerToken = "";
    sessionId.value = "";
    selectedMessId.value = "";
    ownedMesses.clear();
    currentUser.value = null;
    isLoggedIn.value = false;

    _logoutTimer?.cancel();

    log("Logged out → Redirecting LoginScreen");

    Get.offAll(() => const LoginScreen());

    if (showMessage) {
      safeSnack("Session expired", "Please login again.");
    }
  }
}
