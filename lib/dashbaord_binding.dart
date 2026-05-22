import 'package:get/get.dart';

import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/Screens/PlanScreen/Service/PlanController.dart';
import 'package:mess/Screens/PartnerScreen/Service/PartnerController.dart';
import 'package:mess/Screens/CustomerScreen/Service/CustomerController.dart';
import 'package:mess/Screens/HomeScreen/Service/HomeScreenController.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController(),);

    Get.lazyPut<HomeScreenController>(() => HomeScreenController());
    Get.lazyPut<PlanController>(() => PlanController());
    Get.lazyPut<PartnerController>(() => PartnerController());
    Get.lazyPut<CustomerController>(() => CustomerController());
  }
}