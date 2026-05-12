import 'package:Rujta/Screens/OTP_verification.dart';
import 'package:Rujta/view_model/OTP_view_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

class ForgetPasswordViewModel {
  final TextEditingController emailController = TextEditingController();

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void resetPassword(BuildContext context) async {
    String email = emailController.text.trim();

    if (email.isEmpty) {
      _showMessage(context, "Please enter your email");
    } else if (!isValidEmail(email)) {
      _showMessage(context, "Please enter a valid email");
    } else {
      try {
        final url = Uri.parse(
          'https://rujta-app-production.up.railway.app/api/v1/users/forgot-password',
        );
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "email": email,
          }),
        );
        if (!context.mounted) return;
        if (response.statusCode == 200) {
          // Route subtree must own OtpViewModel — GetMaterialApp overlays
          // often sit outside the root MultiProvider lookup path.
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ChangeNotifierProvider<OtpViewModel>(
                create: (_) => OtpViewModel(),
                child: OtpScreen(email: email),
              ),
            ),
          );
        } else if (response.statusCode == 404) {
          _showMessage(context, "No account found with this email");
        } else {
          _showMessage(context, "Something went wrong");
        }
      } catch (e) {
        if (!context.mounted) return;
        _showMessage(context, "Error: ${e.toString()}");
      }
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
