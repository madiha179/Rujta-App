import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ResetPasswordViewModel extends ChangeNotifier {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

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

    final trimmedToken = token.trim();
    if (trimmedToken.isEmpty) {
      _showMessage(context, "Invalid reset token. Please request OTP again");
      return;
    }

    isSubmitting = true;
    notifyListeners();

    try {
      // Encode token so +, /, etc. in tokens are not mangled in the path.
      final url = Uri.parse(
        'https://rujta-app-production.up.railway.app/api/v1/users/reset-password/${Uri.encodeComponent(trimmedToken)}',
      );

      // Many backends expect `password` + `confirmPassword` on reset (not profile PATCH names).
      final body = jsonEncode({
        'password': newPassword,
        'confirmPassword': confirmPassword,
      });

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: body,
          )
          .timeout(
            const Duration(seconds: 25),
            onTimeout: () => throw TimeoutException('reset-password'),
          );

      if (!context.mounted) return;

      final ok = response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
      if (ok) {
        _showMessage(context, "Password reset successful");
        Navigator.pop(context);
        return;
      }

      _showMessage(context, _messageFromResponse(response));
    } on TimeoutException {
      if (!context.mounted) return;
      _showMessage(
        context,
        "Request timed out. Try again (Railway may be waking up).",
      );
    } catch (e) {
      if (!context.mounted) return;
      final isNetwork = e is http.ClientException ||
          e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup');
      _showMessage(
        context,
        isNetwork
            ? "Network error. Check your connection."
            : "Something went wrong. Please try again.",
      );
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

  String _messageFromResponse(http.Response response) {
    final body = response.body.trim();
    if (body.isEmpty) {
      return "Server returned ${response.statusCode}. Check API field names or token.";
    }
    try {
      final data = jsonDecode(body);
      if (data is Map) {
        final m = data['message'];
        if (m != null) return m.toString();
        // Some APIs return { "errors": { "password": ["..."] } }
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) return first.first.toString();
        }
      }
    } catch (_) {}
    return "Error ${response.statusCode}. Ask backend for reset-password JSON body schema.";
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
