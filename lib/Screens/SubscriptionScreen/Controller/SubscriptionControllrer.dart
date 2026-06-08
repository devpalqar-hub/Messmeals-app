import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:mess/Screens/HomeScreen/Service/HomeScreenController.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/Screens/SubscriptionScreen/Model/BillingModel.dart';
import 'package:mess/Screens/SubscriptionScreen/Model/InvoiceModel.dart';
import 'package:mess/Screens/SubscriptionScreen/Model/TierModel.dart';
import 'package:mess/main.dart';

class SubscriptionControllrer extends GetxController {
  InvoiceModel? invoice;
  bool isTrail = false;
  BillingModel? billingModel;
  List<TierModel> billingTier = [];

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

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      for (var tier in data) {
        billingTier.add(TierModel.fromJson(tier));
      }
    }
  }

  FetchMessInvoice() async {
    final responase = await get(
      Uri.parse(baseUrl + "/billing/mess/${hctrl.selectedMessId}/invoice"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': bearerToken,
      },
    );
    if (responase.statusCode == 200) {
      invoice = InvoiceModel.fromJson(json.decode(responase.body));
    }
    update();
  }

  FetchSubcriptionStatus() async {
    final responase = await get(
      Uri.parse(baseUrl + "/billing/mess/${hctrl.selectedMessId}/status"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': bearerToken,
      },
    );
    if (responase.statusCode == 200) {
      var body = json.decode(responase.body);
      print(body);
      billingModel = BillingModel.fromJson(body);
      isTrail = body["trial"] ?? false;
    }
    update();
  }

  MakePayment() async {
    final Response = await post(
      Uri.parse(baseUrl + "/billing/mess/${hctrl.selectedMessId}/invoice/pay"),
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
