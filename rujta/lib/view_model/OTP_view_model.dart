import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OtpViewModel extends ChangeNotifier {

  int _secondsRemaining = 120; //2 minutes
  Timer? _timer;
  bool _canResend = false;

  bool _isLoading = false;
  String _otpCode = "";

  int get secondsRemaining => _secondsRemaining;
  bool get canResend => _canResend;
  bool get isLoading => _isLoading;

  String get timerText {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void startTimer() {
    _secondsRemaining = 120;
    _canResend = false;
    _timer?.cancel(); 

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners(); 
      } else {
        _canResend = true;
        timer.cancel();
        notifyListeners(); 
      }
    });
  }

  Future<String?> verifyOtp(List<String> codeList) async {
    _otpCode = codeList.join(); 

    if (_otpCode.length < 4) return null;

    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse(
        'https://rujta-app-production.up.railway.app/api/v1/users/verify-reset-otp',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "otp": _otpCode,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final dynamic nestedData = data["data"];

        final String? token =
            data["token"]?.toString() ??
            data["resetToken"]?.toString() ??
            data["reset_token"]?.toString() ??
            (nestedData is Map<String, dynamic>
                ? nestedData["token"]?.toString() ??
                    nestedData["resetToken"]?.toString() ??
                    nestedData["reset_token"]?.toString()
                : null);

        return token;
      }

      return null;
    } catch (_) {
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resendCode() {
    if (_canResend) {
      print("A new code has been sent to your email");
      startTimer(); 
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); 
    super.dispose();
  }
}
