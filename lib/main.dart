import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/Screens/Utils/routes.dart';
import 'package:mess/dashbaord_binding.dart';
import 'package:shared_preferences/shared_preferences.dart';

String baseUrl = "https://staging-api.messmeals.com";
String? login;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authController = Get.put(AuthController());
  SharedPreferences pref = await SharedPreferences.getInstance();
  bearerToken = "Bearer " + (pref.getString("token") ?? "");
  print('TOKEN: ${pref.getString("token")}');
  login = pref.getString("LOGIN");
  runApp(const MessMeals());
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
          initialRoute: login == "IN" ? AppRoutes.dashboard : AppRoutes.login,
          getPages: AppRoutes.routes,
          // BUG #2414 — stops keyboard from causing layout overflow on iPhone
          builder: (context, widget) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.noScaling),
              child: widget!,
            );
          },
        );
      },
    );
  }
}
