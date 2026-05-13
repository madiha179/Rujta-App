import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:Rujta/features/splash/presentation/splash_view.dart';
import 'package:Rujta/Screens/login_screen.dart';
import 'package:Rujta/Screens/register_screen.dart';
import 'package:Rujta/Screens/user_profile_screen.dart';
import 'package:Rujta/Screens/Forget_password_screen.dart';
import 'package:Rujta/Screens/inventory_management_screen.dart';
import 'package:Rujta/Screens/main_shell_screen.dart';
import 'package:Rujta/Screens/OTP_verification.dart';
import 'package:Rujta/view_model/cart_controller.dart';
import 'package:Rujta/Screens/admin_profile_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartController()),
      ],
      child: const Rujta(),
    ),
  );
}

class Rujta extends StatelessWidget {
  const Rujta({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rujta App',
      home: const SplashView(),
      routes: {
        '/login':                (context) => const LoginScreen(),
        '/register':             (context) => const RegisterScreen(),
        '/UserProfileScreen':    (context) => const UserProfileScreen(),
        '/ForgetPasswordScreen': (context) => const ForgetPasswordScreen(),
        '/OtpVerification':      (context) => const OtpScreen(),
        '/Home':                 (context) => const MainShellScreen(),
        '/InventoryManagement':  (context) => const InventoryManagementScreen(),
        '/AdminProfile':        (context) => const AdminProfileScreen(),
      },
    );
  }
}