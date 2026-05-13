import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterViewModel {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
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
    // ✅ الـ endpoint الصح من الـ API docs
    final url = Uri.parse(
      "https://rujta-app-production.up.railway.app/api/v1/users/signup",
    );
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "confirmPassword": password, // ✅ مطلوب في الـ API
          "phone": phone,              // ✅ مطلوب في الـ API
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        _showMessage(context, "تم إنشاء الحساب! تحقق من إيميلك للـ OTP");
        // ✅ بعد التسجيل لازم يتحقق من الإيميل بالـ OTP
        Navigator.pushReplacementNamed(context, '/OtpVerification');
      } else {
        _showMessage(context, data["message"] ?? "فشل التسجيل");
      }
    } catch (err) {
      _showMessage(context, "حدث خطأ، تحقق من الاتصال");
      debugPrint('Register error: $err');
    }
  }

  Future<void> register(BuildContext context) async {
    String name  = nameController.text.trim();
    String email = emailController.text.trim();
    String pass  = passController.text.trim();
    String phone = phoneController.text.trim();

    if (name.isEmpty) {
      _showMessage(context, "من فضلك أدخل اسمك");
      return;
    }
    if (email.isEmpty || !isValidEmail(email)) {
      _showMessage(context, "من فضلك أدخل إيميل صحيح");
      return;
    }
    if (pass.isEmpty || !isValidPass(pass)) {
      _showMessage(context, "كلمة المرور لازم تكون 8 حروف على الأقل");
      return;
    }
    if (phone.isEmpty || !isValidPhone(phone)) {
      _showMessage(context, "من فضلك أدخل رقم هاتف مصري صحيح");
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