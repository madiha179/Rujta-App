import 'package:Rujta/Screens/ResetPasswordScreen.dart';
import 'package:flutter/material.dart';
import 'package:Rujta/core/constants.dart';
import 'package:flutter/services.dart';
import '../view_model/OTP_view_model.dart';
import 'package:provider/provider.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OtpViewModel>(context, listen: false).startTimer();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<OtpViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView( 
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text("OTP Verification", 
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 10),
            const Text(
              "Please check your email www.uihut@example.com to see the verification code",
              textAlign: TextAlign.center,
              style: TextStyle(color: subtitleColor, fontSize: 14),
            ),
            const SizedBox(height: 40),
            const Align(
                alignment: Alignment.centerLeft, 
                child: Text("OTP Code", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildOtpBox(context, index: 0, first: true, last: false),
                _buildOtpBox(context, index: 1, first: false, last: false),
                _buildOtpBox(context, index: 2, first: false, last: false),
                _buildOtpBox(context, index: 3, first: false, last: true),
              ],
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: vm.isLoading ? null : () async {
                  List<String> code = _controllers.map((e) => e.text).toList();
                  String? token = await vm.verifyOtp(code);
                  if (token != null && token.isNotEmpty) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResetPasswordScreen(token: token),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Invalid OTP code or expired token, please try again"),
                          backgroundColor: Colors.red,
                        ),
                      );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kMainColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: vm.isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Verify", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            
            const SizedBox(height: 20),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: vm.canResend ? () => vm.resendCode() : null,
                  child: Text(
                    "Resend code to",
                    style: TextStyle(
                      color: vm.canResend ? kMainColor : subtitleColor,
                      fontWeight: vm.canResend ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                Text(
                  vm.timerText,
                  style: const TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOtpBox(BuildContext context, {required int index, required bool first, required bool last}) {
    return Container(
      height: 70,
      width: 65, 
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300), 
      ),
      child: TextField(
        controller: _controllers[index],
        autofocus: first, 
        onChanged: (value) {
          if (value.length == 1 && last == false) {
            FocusScope.of(context).nextFocus();
          }
          if (value.isEmpty && first == false) {
            FocusScope.of(context).previousFocus();
          }
        },
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }
}