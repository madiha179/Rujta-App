import 'package:flutter/material.dart';
import 'package:Rujta/view_model/register_view_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  static const Color _green = Color(0xFF4CAF50);
  final RegisterViewModel viewModel = RegisterViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.chevron_left,
                    size: 28,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              const Text(
                'Sign up now',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Please fill the details and create account',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black45),
              ),

              const SizedBox(height: 40),

              // ── Name ──────────────────────────────────────────────────
              TextFormField(
                controller: viewModel.nameController,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Full Name',
                  hintStyle: TextStyle(color: Colors.black54, fontSize: 15),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFDDDDDD), width: 1.2),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: _green, width: 1.5),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),

              const SizedBox(height: 24),

              // ── Email ─────────────────────────────────────────────────
              TextFormField(
                controller: viewModel.emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Email Address',
                  hintStyle: TextStyle(color: Colors.black54, fontSize: 15),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFDDDDDD), width: 1.2),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: _green, width: 1.5),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),

              const SizedBox(height: 24),

              // ── Phone ─────────────────────────────────────────────────
              TextFormField(
                controller: viewModel.phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Phone Number (e.g. 01012345678)',
                  hintStyle: TextStyle(color: Colors.black54, fontSize: 15),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFDDDDDD), width: 1.2),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: _green, width: 1.5),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),

              const SizedBox(height: 24),

              // ── Password ──────────────────────────────────────────────
              TextFormField(
                controller: viewModel.passController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: '••••••••••',
                  hintStyle: const TextStyle(
                    color: Colors.black54,
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.black38,
                      size: 20,
                    ),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFDDDDDD), width: 1.2),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: _green, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),

              const SizedBox(height: 6),
              const Text(
                'Password must be 8 characters',
                style: TextStyle(color: Colors.black38, fontSize: 12),
              ),

              const SizedBox(height: 32),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => viewModel.register(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        color: _green,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }
}