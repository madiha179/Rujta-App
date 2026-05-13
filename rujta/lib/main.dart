import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:Rujta/features/splash/presentation/splash_view.dart';
import 'package:Rujta/Screens/Forget_password_screen.dart';
import 'package:Rujta/Screens/login_screen.dart';
import 'package:Rujta/Screens/main_shell_screen.dart';
import 'package:Rujta/Screens/user_profile_screen.dart';
import 'package:Rujta/view_model/cart_controller.dart';

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
        '/login': (context) => LoginScreen(),
        '/Home': (context) => const MainShellScreen(),
        '/UserProfileScreen': (context) => const UserProfileScreen(),
        '/ForgetPasswordScreen': (context) => const ForgetPasswordScreen(),
      },
    );
  }
}
