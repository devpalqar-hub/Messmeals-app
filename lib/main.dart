import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/Screens/Utils/routes.dart';
import 'package:mess/dashbaord_binding.dart';

String baseUrl = "https://staging-api.messmeals.com";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authController = Get.put(AuthController());
  // await authController.checkLoginStatus();

  runApp(
    DevicePreview(enabled: false, builder: (context) => const MessMeals()),
  );
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
          initialBinding: AppBindings(),
          initialRoute:
              Get.find<AuthController>().isLoggedIn
                  ? AppRoutes.dashboard
                  : AppRoutes.login,
          getPages: AppRoutes.routes,
        );
      },
    );
  }
}
