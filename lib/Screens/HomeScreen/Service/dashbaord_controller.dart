import 'package:get/get.dart';

class DashboardController extends GetxController {
  var selectedIndex = 0.obs;

  final List<String> routes = [
    '/home',
    '/customers',
    '/partner',
    '/deliveries',
    '/plans',
  ];

  void changeTab(int index) {
    selectedIndex.value = index;
    Get.offNamed(routes[index], id: 1);
  }
}