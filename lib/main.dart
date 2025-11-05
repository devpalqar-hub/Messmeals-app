import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mess/Screens/HomeScreen/HomeView.dart';
import 'package:mess/Screens/LoginScreen/LoginScreen.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';

String baseUrl = "http://31.97.237.63/supermeals"; // 🌐 Global base URL

Future<void> main() async {
  // 🧩 Ensures Flutter engine is ready before async calls
  WidgetsFlutterBinding.ensureInitialized();

  // 🧠 Initialize the AuthController before app runs
  final authController = Get.put(AuthController());

  // 🔐 Check login status before loading UI
  await authController.checkLoginStatus();

  // 🚀 Run the app after setup
  runApp(const MessMeals());
}

class MessMeals extends StatelessWidget {
  const MessMeals({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Use the same controller instance initialized in main()
    final auth = Get.find<AuthController>();

    return ScreenUtilInit(
      designSize: const Size(390, 850),
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Mess Meals",
          home: Obx(() {
            // 🧭 Dynamically show screen based on login status
            return auth.isLoggedIn.value
                ? const DashboardScreen()
                : const LoginScreen();
          }),
        );
      },
    );
  }
}
