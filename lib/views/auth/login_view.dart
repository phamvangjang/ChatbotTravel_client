import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth/login_viewmodel.dart';

class LoginView extends StatefulWidget{
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Consumer<LoginViewModel>(
                builder: (context, viewModel, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Chatbot Travel Agents',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Authentication to continue',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 32),

                      // Email field
                      TextField(
                        controller: viewModel.emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email address',
                          suffix: Text('Edit', style: TextStyle(color: Colors.blue)),
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
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(viewModel.obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: viewModel.togglePasswordVisibility,
                          ),
                        ),
                      ),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text('Forgot password?'),
                        ),
                      ),
                      const SizedBox(height: 12),

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
                          onPressed: viewModel.canLogin && !viewModel.isLoading
                              ? () async {
                            final success = await viewModel.login();
                            if (success && context.mounted) {
                              // Navigate to home on success
                              Navigator.pushReplacementNamed(context, '/home');
                              // print("📁 Value of success: "+ success.toString());
                            }
                          }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: viewModel.canLogin
                                ? Colors.blue
                                : Colors.blue.withOpacity(0.5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            side: BorderSide.none,
                          ),
                          child: viewModel.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Login'),
                        ),
                      ),

                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? "),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Sign up'),
                          ),
                        ],
                      ),

                      const Divider(height: 32),
                      const Text("OR"),

                      const SizedBox(height: 16),

                      /// Google button
                      _buildOAuthButton("Continue with Google", Icons.g_mobiledata),
                      const SizedBox(height: 12),

                      // Microsoft button
                      _buildOAuthButton("Continue with Microsoft Account", Icons.window),

                      const SizedBox(height: 12),

                      // Apple button
                      _buildOAuthButton("Continue with Apple", Icons.apple),

                      const SizedBox(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('Terms of Use'),
                          SizedBox(width: 16),
                          Text('Privacy Policy'),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        side: BorderSide.none,
      ),
    );
  }
}
