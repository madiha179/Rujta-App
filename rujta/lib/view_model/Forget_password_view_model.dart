import 'package:Rujta/core/widgets/email_dialogue.dart';
import 'package:flutter/material.dart';
import 'package:Rujta/core/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgetPasswordViewModel {
  final TextEditingController emailController = TextEditingController();

 
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(email);
  }

 
  void resetPassword(BuildContext context) async{
    String email = emailController.text.trim();

    if (email.isEmpty) {
      _showMessage(context, "Please enter your email");
    } else if (!isValidEmail(email)) {
      _showMessage(context, "Please enter a valid email");
    } else {
try{
final url = Uri.parse(
        'https://respectable-adelind-rujta-app-580bd658.koyeb.app/api/v1/users/forgot-password',
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
      if (response.statusCode == 200) {
         _showMessage(context, "OTP sent to your email");

        showDialog(
          context: context,
          builder: (context) => email_dialog(),
        );

      } else if (response.statusCode == 404) {
        _showMessage(context, "No account found with this email");
      } else {
        _showMessage(context, "Something went wrong");
      }

    } catch (e) {
      _showMessage(context, "Error: ${e.toString()}");
    }
  }
}


    }
  

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }


