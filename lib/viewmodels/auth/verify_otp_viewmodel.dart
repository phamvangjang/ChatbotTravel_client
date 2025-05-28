import 'package:flutter/material.dart';

class VerifyOtpViewModel extends ChangeNotifier{
  String otpCode = '';
  bool isLoading = false;
  String errorMessage = '';

  bool get canVerify => otpCode.length == 6 && !otpCode.contains(' ');

  void updateOtp(List<String> digits) {
    otpCode = digits.join();
    errorMessage = '';
    notifyListeners();
  }

  Future<bool> verifyOtp() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2)); // giả lập API

      if (otpCode == '123456') {
        return true;
      } else {
        errorMessage = 'Mã OTP không đúng. Vui lòng thử lại.';
        return false;
      }
    } catch (e) {
      errorMessage = 'Đã xảy ra lỗi. Vui lòng thử lại.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}