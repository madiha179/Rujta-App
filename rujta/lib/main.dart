import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Rujta/view_model/otp_view_model.dart';
import 'package:Rujta/Screens/login_screen.dart';
import 'package:Rujta/Screens/user_profile_screen.dart';
import 'package:Rujta/Screens/Forget_password_screen.dart';
import 'package:Rujta/Screens/home.dart';

import 'package:get/get.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => OtpViewModel())],
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
      //  debugShowCheckedModeBanner: false,
    //  debugShowCheckedModeBanner: false, 
      title: 'Rujta App',
      home: LoginScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/Home': (context) => const HomePage(),
       // '/Drugstore': (context) => const HomePage(),
        '/UserProfileScreen': (context) => const UserProfileScreen(),
       '/ForgetPasswordScreen':(context)=>const ForgetPasswordScreen()
      },
      //home: const OtpScreen(),
    );
  }
}
