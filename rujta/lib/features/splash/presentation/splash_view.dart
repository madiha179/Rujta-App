import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:Rujta/features/on_Boarding/presentation/on_boardin_view.dart';
import 'package:Rujta/core/utils/size_config.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  String displayedText = "";
  final String fullText = "Rujta";
  int index = 0;

  Timer? _typingTimer;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _startTyping();
    _startTimer();
  }

  void _startTyping() {
    _typingTimer = Timer.periodic(const Duration(milliseconds: 180), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (index < fullText.length) {
        setState(() {
          displayedText += fullText[index];
          index++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _startTimer() {
    _navigationTimer = Timer(const Duration(milliseconds: 4800), () {
      if (!mounted) return;
      // الانتقال مباشرة إلى OnBoardingView باستخدام GetX
      Get.off(() => const OnBoardingView(), transition: Transition.fade);
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "images/Logo.png",
              width: 80,
              height: 80,
            ),
            const SizedBox(height: 10),
            Stack(
              children: [
                Text(
                  displayedText,
                  style: const TextStyle(
                    fontSize: 37,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF69A03A),
                    letterSpacing: 2,
                  ),
                ),
                Positioned(
                  right: -2,
                  top: 0,
                  child: AnimatedOpacity(
                    opacity: index < fullText.length ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      width: 2,
                      height: 40,
                      color: const Color(0xFF69A03A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Color(0xFF69A03A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}