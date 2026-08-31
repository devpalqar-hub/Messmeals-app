import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/Screens/OnboardingScreen/Service/onboarding_controller.dart';
import 'package:mess/Screens/Utils/AppColors.dart';
import 'package:mess/Screens/Utils/routes.dart';
import 'package:mess/dashbaord_binding.dart';
import 'package:shared_preferences/shared_preferences.dart';

String baseUrl = "https://api.messmeals.com";
//String baseUrl = "https://staging-api.messmeals.com";
String? login;
bool onboardingSeen = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put(AuthController());
  SharedPreferences pref = await SharedPreferences.getInstance();
  bearerToken = "Bearer " + (pref.getString("token") ?? "");
  print('TOKEN: ${pref.getString("token")}');
  login = pref.getString("LOGIN");
  onboardingSeen = pref.getBool(onboardingSeenKey) ?? false;
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
          initialRoute: AppRoutes.splash,
          getPages: AppRoutes.routes,
          theme: ThemeData(
            useMaterial3: false,
            scaffoldBackgroundColor: Colors.white,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
              secondary: AppColors.secondary,
            ),
            primaryColor: AppColors.primary,
            // Any loader left without an explicit color (Center(child: CircularProgressIndicator()))
            // now renders in the brand green instead of Flutter's default blue.
            progressIndicatorTheme: const ProgressIndicatorThemeData(
              color: AppColors.primary,
            ),
            switchTheme: SwitchThemeData(
              thumbColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? AppColors.primary
                    : null,
              ),
              trackColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? AppColors.primary.withOpacity(0.4)
                    : null,
              ),
            ),
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? AppColors.primary
                    : null,
              ),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF111827),
              elevation: 0,
            ),
          ),
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
