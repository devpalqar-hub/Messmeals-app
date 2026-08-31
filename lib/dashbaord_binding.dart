import 'package:get/get.dart';

import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/Screens/PlanScreen/Service/PlanController.dart';
import 'package:mess/Screens/MenuScreen/Service/MenuController.dart';
import 'package:mess/Screens/PartnerScreen/Service/PartnerController.dart';
import 'package:mess/Screens/CustomerScreen/Service/CustomerController.dart';
import 'package:mess/Screens/HomeScreen/Service/HomeScreenController.dart';
import 'package:mess/Screens/ExpenseScreen/Service/ExpenseController.dart';
import 'package:mess/Screens/ExpenseCategoryScreen/Service/ExpenseCategoryController.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController(),);

    Get.lazyPut<HomeScreenController>(() => HomeScreenController());
    Get.lazyPut<PlanController>(() => PlanController());
    Get.lazyPut<MessMenuController>(() => MessMenuController());
    Get.lazyPut<PartnerController>(() => PartnerController());
    Get.lazyPut<CustomerController>(() => CustomerController());
    Get.lazyPut<ExpenseCategoryController>(() => ExpenseCategoryController());
    Get.lazyPut<ExpenseController>(() => ExpenseController());
  }
}