import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Rujta/view_model/otp_view_model.dart'; 
import 'package:Rujta/screens/OTP_verification.dart'; 
import 'features/splash/presentation/splash_view.dart';
import 'package:Rujta/Screens/login_screen.dart';
import 'package:get/get.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OtpViewModel()),
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
      debugShowCheckedModeBanner: false, 
      title: 'Rujta App',
      home: SplashView(),
      //home: const OtpScreen(), 
    );
  }
}