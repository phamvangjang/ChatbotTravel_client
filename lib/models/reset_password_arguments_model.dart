class ResetPasswordArguments {
  final String email;
  final String? resetToken;
  final String? verifiedOtp;

  ResetPasswordArguments({
    required this.email,
    this.resetToken,
    this.verifiedOtp,
});

  // Thêm method để tạo từ Map
  factory ResetPasswordArguments.fromMap(Map<String, dynamic> map) {
    return ResetPasswordArguments(
      email: map['email'] ?? '',
      resetToken: map['reset_token'],
      verifiedOtp: map['verified_otp'],
    );
  }

  // Thêm method để chuyển thành Map
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'reset_token': resetToken,
      'verified_otp': verifiedOtp,
    };
  }
}