import 'package:flutter/material.dart';
import '../../services/auth/auth_service.dart';

class VerifyOtpViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();

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
      final result = await _authService.verifyRegisterOtp(
        emailController.text.trim(),
        otpCode,
      );
      if (!(result['success'] as bool)) {
        print(result);
        errorMessage = result['message'];
      }
      return result['success'] as bool;
    } catch (e) {
      errorMessage = 'Somethings went wrong, please try later again';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
