import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ResetPasswordViewModel extends ChangeNotifier {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;
  bool isSubmitting = false;

  void toggleNewPasswordVisibility() {
    obscureNewPassword = !obscureNewPassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword = !obscureConfirmPassword;
    notifyListeners();
  }

  bool _isPasswordStrong(String password) {
    return password.length >= 8;
  }

  Future<void> resetPassword(BuildContext context, String token) async {
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showMessage(context, "Please fill in all password fields");
      return;
    }

    if (!_isPasswordStrong(newPassword)) {
      _showMessage(context, "Password must be at least 8 characters");
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage(context, "Passwords do not match");
      return;
    }

    if (token.trim().isEmpty) {
      _showMessage(context, "Invalid reset token. Please request OTP again");
      return;
    }

    isSubmitting = true;
    notifyListeners();

    try {
      final url = Uri.parse(
        'https://rujta-app-production.up.railway.app/api/v1/users/reset-password/$token',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "password": newPassword,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showMessage(context, "Password reset successful");
        Navigator.pop(context);
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        _showMessage(
          context,
          data["message"]?.toString() ?? "Invalid or expired token",
        );
      } else {
        _showMessage(context, "Something went wrong. Please try again");
      }
    } catch (e) {
      _showMessage(context, "Something went wrong. Please try again");
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
