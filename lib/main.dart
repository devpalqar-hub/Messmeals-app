import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mess/Screens/HomeScreen/HomeView.dart';
import 'package:mess/Screens/LoginScreen/LoginScreen.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';

String baseUrl = "https://api.messmeals.com"; 


Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

 
  final authController = Get.put(AuthController());

  
  await authController.checkLoginStatus();

  
  runApp(const MessMeals());
}

class MessMeals extends StatelessWidget {
  const MessMeals({super.key});

  @override
  Widget build(BuildContext context) {
  
    final auth = Get.find<AuthController>();

    return ScreenUtilInit(
      designSize: const Size(390, 850),
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Mess Meals",
          home: Obx(() {
          
            return auth.isLoggedIn.value
                ? const DashboardScreen()
                : const LoginScreen();
          }),
        );
      },
    );
  }
}
