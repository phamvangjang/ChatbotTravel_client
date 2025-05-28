
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
                        'Sign Up to continue',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 32),

                      // Username field
                      TextField(
                        controller: viewModel.usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          suffix: Text(
                            'Edit',
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
                          labelText: 'Email address',
                          suffix: Text(
                            'Edit',
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
                          labelText: 'Password',
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
                              // Navigate to home on success
                              Navigator.pushReplacementNamed(
                                context,
                                '/verify_otp',
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
                              : const Text('Sign Up'),
                        ),
                      ),

                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account? "),
                          TextButton(
                            onPressed: () => viewModel.goToLogin(context),
                            child: const Text('Sign In'),
                          ),
                        ],
                      ),

                      const Divider(height: 32),
                      const Text("OR"),

                      const SizedBox(height: 16),

                      /// Google button
                      _buildOAuthButton(
                        "Continue with Google",
                        Icons.g_mobiledata,
                      ),
                      const SizedBox(height: 12),

                      // Microsoft button
                      _buildOAuthButton(
                        "Continue with Microsoft Account",
                        Icons.window,
                      ),

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        side: BorderSide.none,
      ),
    );
  }
}