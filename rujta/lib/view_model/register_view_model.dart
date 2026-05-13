import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterViewModel {
  final TextEditingController nameController  = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController  = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool isValidPass(String pass) {
    return pass.length >= 8;
  }

  bool isValidPhone(String phone) {
    return RegExp(r'^01[0-9]{9}$').hasMatch(phone);
  }

  Future<void> registerApi(
    BuildContext context,
    String name,
    String email,
    String password,
    String phone,
  ) async {
    final url = Uri.parse(
      "https://rujta-app-production.up.railway.app/api/v1/users/signup",
    );
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name":            name,
          "email":           email,
          "password":        password,
          "confirmPassword": password,
          "phone":           phone,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        _showMessage(context, "Account created! Please verify your email.");
        Navigator.pushReplacementNamed(context, '/OtpVerification');
      } else {
        _showMessage(context, data["message"] ?? "Registration failed");
      }
    } catch (err) {
      _showMessage(context, "Something went wrong, check your connection");
      debugPrint('Register error: $err');
    }
  }

  Future<void> register(BuildContext context) async {
    String name  = nameController.text.trim();
    String email = emailController.text.trim();
    String pass  = passController.text.trim();
    String phone = phoneController.text.trim();

    if (name.isEmpty) {
      _showMessage(context, "Please enter your name");
      return;
    }
    if (email.isEmpty || !isValidEmail(email)) {
      _showMessage(context, "Please enter a valid email");
      return;
    }
    if (pass.isEmpty || !isValidPass(pass)) {
      _showMessage(context, "Password must be at least 8 characters");
      return;
    }
    if (phone.isEmpty || !isValidPhone(phone)) {
      _showMessage(context, "Please enter a valid Egyptian phone number");
      return;
    }
    await registerApi(context, name, email, pass, phone);
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passController.dispose();
    phoneController.dispose();
  }
}