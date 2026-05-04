import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';


class ApiService {
  static Future<http.Response> request(
    Future<http.Response> apiCall,
  ) async {
    final response = await apiCall;

    // 🔥 AUTO LOGOUT ON 401
    if (response.statusCode == 401) {
      final auth = Get.find<AuthController>();
      auth.logout();
    }

    return response;
  }
}