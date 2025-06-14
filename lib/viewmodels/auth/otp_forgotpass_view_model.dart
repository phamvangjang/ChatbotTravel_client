import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobilev2/services/auth/auth_service.dart';
import 'package:mobilev2/views/auth/reset_password_view.dart';

class VerifyOtpForgotPassViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  String email;

  // OTP Controllers and Focus Nodes
  late List<TextEditingController> otpControllers;
  late List<FocusNode> focusNodes;

  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  int _focusedIndex = 0;

  // Resend timer
  Timer? _resendTimer;
  int _resendCountdown = 0;
  bool _canResend = true;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get focusedIndex => _focusedIndex;
  int get resendCountdown => _resendCountdown;
  bool get canResend => _canResend;

  bool get canConfirm {
    return otpControllers.every((controller) => controller.text.isNotEmpty);
  }

  String get otpCode {
    return otpControllers.map((controller) => controller.text).join();
  }

  VerifyOtpForgotPassViewModel({this.email=''}) {
    _initializeControllers();
  }

  // Phương thức để cập nhật email sau khi khởi tạo
  void updateEmail(String newEmail) {
    email = newEmail;
  }

  void _initializeControllers() {
    otpControllers = List.generate(6, (index) => TextEditingController());
    focusNodes = List.generate(6, (index) => FocusNode());

    // Add listeners to focus nodes
    for (int i = 0; i < focusNodes.length; i++) {
      focusNodes[i].addListener(() {
        if (focusNodes[i].hasFocus) {
          _focusedIndex = i;
          notifyListeners();
        }
      });
    }
  }

  void onOtpChanged(String value, int index) {
    _errorMessage = null;

    if (value.isNotEmpty) {
      // Move to next field if not the last one
      if (index < 5) {
        focusNodes[index + 1].requestFocus();
      } else {
        // If it's the last field, unfocus
        focusNodes[index].unfocus();
      }
    }

    notifyListeners();
  }

  void onFieldTapped(int index) {
    _focusedIndex = index;

    // Clear the field and all fields after it when tapped
    for (int i = index; i < otpControllers.length; i++) {
      otpControllers[i].clear();
    }

    notifyListeners();
  }

  Future<void> verifyOtp(BuildContext context) async {
    if (!canConfirm) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.verifyForgotPasswordOtp(email, otpCode);

      if (result['success'] as bool) {
        if (context.mounted) {
          // Navigate to reset password screen
          /*
          Navigator.pushReplacementNamed(
            context,
            '/reset_password',
            arguments: {
              'email': email,
              'verified_otp': otpCode,
            },
          );
           */
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPasswordView(
                email: email,
                otp: otpCode,
              ),
            ),
          );

        }
      } else {
        _errorMessage = result['message'] ?? 'Mã OTP không đúng';
        _shakeAnimation();
      }
    } catch (e) {
      _errorMessage = 'Lỗi xác thực OTP: $e';
      _shakeAnimation();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resendOtp() async {
    if (!_canResend) return;

    try {
      final result = await _authService.forgotPassword(email);

      if (result['success'] as bool) {
        _startResendTimer();
        _clearOtpFields();
        _errorMessage = null;
      } else {
        _errorMessage = result['message'] ?? 'Không thể gửi lại mã OTP';
      }
    } catch (e) {
      _errorMessage = 'Lỗi khi gửi lại mã OTP: $e';
    }

    notifyListeners();
  }

  void _startResendTimer() {
    _canResend = false;
    _resendCountdown = 60; // 60 seconds countdown

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _resendCountdown--;

      if (_resendCountdown <= 0) {
        _canResend = true;
        timer.cancel();
      }

      notifyListeners();
    });
  }

  void _clearOtpFields() {
    for (var controller in otpControllers) {
      controller.clear();
    }
    focusNodes[0].requestFocus();
    _focusedIndex = 0;
  }

  void _shakeAnimation() {
    // Clear all fields and focus on first field for re-entry
    _clearOtpFields();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();

    for (var controller in otpControllers) {
      controller.dispose();
    }

    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }

    super.dispose();
  }
}
