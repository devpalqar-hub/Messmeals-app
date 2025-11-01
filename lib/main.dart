import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mess/Screens/HomeScreen/HomeView.dart';
import 'package:mess/Screens/LoginScreen/LoginScreen.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';

String baseUrl = "http://31.97.237.63/supermeals"; // Global base URL

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Put AuthController first (no async call before GetMaterialApp)
  Get.put(AuthController());

  runApp(const MessMeals());
}

class MessMeals extends StatelessWidget {
  const MessMeals({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 850),
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
        );
      },
    );
  }
}

/// ✅ Splash screen to handle navigation after app launch
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // wait 1.5s before checking login (for smoother UX)
    await Future.delayed(const Duration(milliseconds: 1500));
    await _authController.checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
