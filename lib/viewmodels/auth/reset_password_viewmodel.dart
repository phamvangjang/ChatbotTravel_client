import 'package:flutter/material.dart';
import 'package:mobilev2/services/auth/auth_service.dart';

class ResetPasswordViewModel extends ChangeNotifier{
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController newPasswordConfirmController = TextEditingController();

  bool _obscureResetPassword = true;
  bool _obscureResetConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _verifiedOtp;

  bool get obscureResetPassword => _obscureResetPassword;
  bool get obscureResetConfirmPassword => _obscureResetConfirmPassword;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get canResetPassword => _validateInputs();
  String? get verifiedOtp => _verifiedOtp;

  ResetPasswordViewModel(){
    newPasswordController.addListener(_onTextChanged);
    newPasswordConfirmController.addListener(_onTextChanged);
  }

  // Thiết lập dữ liệu từ arguments
  void setResetData({
    required String email,
    String? resetToken,
    String? verifiedOtp, // Thêm parameter
  }) {
    emailController.text = email;
    _verifiedOtp = verifiedOtp;
    notifyListeners();
  }

  bool _validateInputs() {
    final newPassword = newPasswordController.text.trim();
    final newPasswordConfirm = newPasswordConfirmController.text.trim();

    _errorMessage = null;

    // Kiểm tra mật khẩu mới
    if (newPassword.isEmpty) {
      _errorMessage = 'Vui lòng nhập mật khẩu mới';
      return false;
    }

    if (newPassword.length < 6) {
      _errorMessage = 'Mật khẩu phải có ít nhất 6 ký tự';
      return false;
    }

    // Kiểm tra xác nhận mật khẩu
    if (newPasswordConfirm.isEmpty) {
      _errorMessage = 'Vui lòng xác nhận mật khẩu';
      return false;
    }

    if (newPassword != newPasswordConfirm) {
      _errorMessage = 'Mật khẩu xác nhận không khớp';
      return false;
    }

    // Kiểm tra email
    if (emailController.text.trim().isEmpty) {
      _errorMessage = 'Thiếu thông tin email';
      return false;
    }

    // Kiểm tra OTP đã xác nhận
    if (_verifiedOtp == null || _verifiedOtp!.isEmpty) {
      _errorMessage = 'Thiếu thông tin xác thực OTP';
      return false;
    }

    _errorMessage = null;
    return true;
  }

  void toggleNewPasswordVisibility(){
    _obscureResetPassword = !_obscureResetPassword;
    notifyListeners();
  }

  void toggleNewConfirmPasswordVisibility(){
    _obscureResetConfirmPassword = !_obscureResetConfirmPassword;
    notifyListeners();
  }

  void _onTextChanged() {
    notifyListeners();
  }

  Future<bool> resetPassword(BuildContext context) async{
    if (!canResetPassword) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try{
      final result = await _authService.resetPassword(
          emailController.text.trim(),
          _verifiedOtp!,
          newPasswordController.text.trim());

      if (!(result['success'] as bool)) {
        print(result);
        _errorMessage = result['message'] ?? 'Có lỗi xảy ra, vui lòng thử lại';
      }

      // Hiển thị thông báo thành công
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đặt lại mật khẩu thành công!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Chuyển về trang login
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
              (route) => false,
        );
      }

      return result['success'] as bool;
    }catch (e){
      _errorMessage = 'Error occurred: $e';
      return false;
    }finally{
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    newPasswordController.dispose();
    newPasswordConfirmController.dispose();
    super.dispose();
  }
}