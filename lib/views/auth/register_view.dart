import 'package:flutter/material.dart';
import 'package:mobilev2/viewmodels/auth/register_viewmodel.dart';
import 'package:provider/provider.dart';

class RegisterView extends StatefulWidget{
  const RegisterView({super.key});
  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Consumer<RegisterViewModel>(
                builder: (context, viewModel, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Chatbot Travel Agents',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Đăng kí để tiếp tục',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 32),

                      // Username field
                      TextField(
                        controller: viewModel.usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên người dùng',
                          suffix: Text(
                            'Sửa',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Email field
                      TextField(
                        controller: viewModel.emailController,
                        decoration: const InputDecoration(
                          labelText: 'Địa chỉ email',
                          suffix: Text(
                            'Sửa',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Password field
                      TextField(
                        controller: viewModel.passwordController,
                        obscureText: viewModel.obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          suffixIcon: IconButton(
                            icon: Icon(
                              viewModel.obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: viewModel.togglePasswordVisibility,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Thêm hiển thị lỗi
                      if (viewModel.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            viewModel.errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),

                      // Continue button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                          viewModel.canRegister && !viewModel.isLoading
                              ? () async {
                            final success = await viewModel.register();
                            if (success && context.mounted) {
                              Navigator.pushReplacementNamed(
                                context,
                                '/verify_otp',
                                arguments: {
                                  'email': viewModel.emailController.text.trim(),
                                  'otp_type': 'register',
                                },
                              );
                            }
                          }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            viewModel.canRegister
                                ? Colors.blue
                                : Colors.blue.withOpacity(0.5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            side: BorderSide.none,
                          ),
                          child:
                          viewModel.isLoading
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : const Text('Đăng ký'),
                        ),
                      ),

                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Bạn đã có tài khoản? "),
                          TextButton(
                            onPressed: () => viewModel.goToLogin(context),
                            child: const Text('Đăng nhập'),
                          ),
                        ],
                      ),

                      const Divider(height: 32),
                      const Text("hoặc"),

                      const SizedBox(height: 16),

                      /// Google button
                      _buildOAuthButton(
                        "Tiếp tục với Google",
                        Icons.g_mobiledata,
                      ),
                      const SizedBox(height: 12),

                      // Microsoft button
                      _buildOAuthButton(
                        "Tiếp tục với Microsoft Account",
                        Icons.window,
                      ),

                      const SizedBox(height: 12),

                      // Apple button
                      _buildOAuthButton("Tiếp tục với Apple", Icons.apple),

                      const SizedBox(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('Điều khoản sử dụng'),
                          SizedBox(width: 16),
                          Text('Chính sách bảo mật'),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOAuthButton(String text, IconData icon) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon),
      label: Text(text),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 48),
        alignment: Alignment.centerLeft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        side: BorderSide.none,
      ),
    );
  }
}