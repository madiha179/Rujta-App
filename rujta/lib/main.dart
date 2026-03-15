import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'features/splash/presentation/splash_view.dart';

void main() {
  runApp(const Rujta());
}

class Rujta extends StatelessWidget {
  const Rujta({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
  
      debugShowCheckedModeBanner: false,
      home: SplashView(),
    );
  }
}