import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:mess/Screens/HomeScreen/Service/HomeScreenController.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/main.dart';

class SubscriptionControllrer extends GetxController {
  HomeScreenController hctrl = Get.find();
  FetchSubcription() async {
    final response = await get(
      Uri.parse(baseUrl + "/billing/tiers"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': bearerToken,
      },
    );
    print(response.body);

    if (response.statusCode == 200) {}
  }

  FetchMessInvoice() async {
    final responase = await get(
      Uri.parse(
        baseUrl +
            "/billing/mess/${hctrl.authController.selectedMessId}/invoice",
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': bearerToken,
      },
    );

    print(responase.body);
  }

  FetchSubcriptionStatus() async {
    final responase = await get(
      Uri.parse(
        baseUrl + "/billing/mess/${hctrl.authController.selectedMessId}/status",
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': bearerToken,
      },
    );

    print(responase.body);
  }

  MakePayment() async {
    final Response = await post(
      Uri.parse(
        baseUrl +
            "/billing/mess/${hctrl.authController.selectedMessId}/invoice/pay",
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': bearerToken,
      },
    );
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    FetchSubcription();
    FetchMessInvoice();
    FetchSubcriptionStatus();
  }
}
