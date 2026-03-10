import 'dart:async';
import 'package:flutter/material.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final String text = "Rujta";
  String displayedText = "";
  int index = 0;

  @override
  void initState() {
    super.initState();
    startTyping();
    startTimer();
  }

  void startTyping() {
    Timer.periodic(const Duration(milliseconds: 180), (timer) {
      if (index < text.length) {
        setState(() {
          displayedText += text[index];
          index++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void startTimer() {
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("images/Logo.png", width: 170, height: 170),
            const SizedBox(height: 40),
            Text(
              displayedText,
              style: const TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.bold,
                color: Colors.green,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              strokeWidth: 4,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}