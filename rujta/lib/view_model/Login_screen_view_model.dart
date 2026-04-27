import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreenViewModel {
  final _storage = const FlutterSecureStorage();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool isValidPass(String pass) {
    return RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$',
    ).hasMatch(pass);
  }

  Future<void> loginApi(
    BuildContext context,
    String email,
    String password,
  ) async {
    final url = Uri.parse(
      "https://rujta-app-production.up.railway.app/api/v1/users/login",
    );
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        String token = data["token"] ?? data["data"]["token"];
        await _storage.write(key: 'auth_token', value: token);
        Navigator.pushReplacementNamed(context, '/UserProfileScreen');
      } else {
        _showMessage(context, data["message"]);
      }
    } catch (err) {
      _showMessage(context, "Something went wrong");
      print(err);
    }
  }

  Future login(BuildContext context) async {
    String email = emailController.text.trim();
    String pass = passController.text.trim();
    if (email.isEmpty) {
      _showMessage(context, "Please enter your email");
    }
    if (!isValidEmail(email)) {
      _showMessage(context, "Please enter vaild email");
    }
    if (pass.isEmpty) {
      _showMessage(context, "Please enter your password");
    }
    if (!isValidPass(pass)) {
      _showMessage(context, "Please enter vaild password");
    }
    await loginApi(context, email, pass);
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
