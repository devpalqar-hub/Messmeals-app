import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mess/Screens/HomeScreen/HomeView.dart';
import 'package:mess/Screens/LoginScreen/LoginScreen.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';

String baseUrl = "https://staging-api.messmeals.com";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the controller
  final authController = Get.put(AuthController());

  // Check status before running the app
  await authController.checkLoginStatus();

  runApp(DevicePreview(builder: (value) => const MessMeals(), enabled: false));
}

class MessMeals extends StatelessWidget {
  const MessMeals({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 840),
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Mess Meals",
          // Replaced Obx with GetBuilder
          home: GetBuilder<AuthController>(
            builder: (auth) {
              return auth.isLoggedIn
                  ? const DashboardScreen()
                  :  LoginScreen();
            },
          ),
        );
      },
    );
  }
}