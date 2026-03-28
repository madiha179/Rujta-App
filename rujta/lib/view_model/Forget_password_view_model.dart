import 'package:Rujta/core/widgets/email_dialogue.dart';
import 'package:flutter/material.dart';

class ForgetPasswordViewModel {
  final TextEditingController emailController = TextEditingController();

 
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(email);
  }

 
  void resetPassword(BuildContext context) {
    String email = emailController.text.trim();

    if (email.isEmpty) {
      _showMessage(context, "Please enter your email");
    } else if (!isValidEmail(email)) {
      _showMessage(context, "Please enter a valid email");
    } else {
showDialog(
  context: context,
  builder: (context) => email_dialog(),
);

    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

