import 'dart:async';
import 'package:flutter/material.dart';

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

  Future<bool> verifyOtp(List<String> codeList) async {
    _otpCode = codeList.join(); 

    if (_otpCode.length < 4) return false;

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _isLoading = false;
    notifyListeners();

    if (_otpCode == "1234") { // مثال لحد ما نعمل كونكت بالداتا بيز 
      return true; 
    } else {
      return false; 
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
