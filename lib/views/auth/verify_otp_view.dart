import 'package:flutter/material.dart';
import 'package:mobilev2/viewmodels/auth/verify_otp_viewmodel.dart';
import 'package:provider/provider.dart';

class VerifyOtpView extends StatefulWidget {
  const VerifyOtpView({super.key});

  @override
  State<VerifyOtpView> createState() => _VerifyOtpViewState();
}

class _VerifyOtpViewState extends State<VerifyOtpView>{
  final List<TextEditingController> controllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final emailArg = ModalRoute.of(context)?.settings.arguments as String?;
      if (emailArg != null) {
        final viewModel = Provider.of<VerifyOtpViewModel>(context, listen: false);
        viewModel.emailController.text = emailArg;
      }
    });
  }

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
    for (final node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    final viewModel = Provider.of<VerifyOtpViewModel>(context, listen: false);
    if (value.isNotEmpty && RegExp(r'\d').hasMatch(value)) {
      controllers[index].text = value;
      if (index < 5) {
        FocusScope.of(context).requestFocus(focusNodes[index + 1]);
      } else {
        FocusScope.of(context).unfocus();
      }
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(focusNodes[index - 1]);
    }

    // Cập nhật ViewModel sau mỗi thay đổi
    final otpDigits =
    controllers.map((controller) => controller.text.trim().isEmpty ? ' ' : controller.text).toList();
    viewModel.updateOtp(otpDigits);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<VerifyOtpViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Xác minh OTP')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text('Nhập mã OTP gồm 6 chữ số', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 48,
                  height: 60,
                  child: TextField(
                    controller: controllers[index],
                    focusNode: focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    decoration: const InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _onChanged(index, value),
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),
            if (viewModel.errorMessage.isNotEmpty)
              Text(
                viewModel.errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: viewModel.canVerify && !viewModel.isLoading
                    ? () async {
                  final success = await viewModel.verifyOtp();
                  if (success && context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: viewModel.canVerify
                      ? Colors.blue
                      : Colors.blue.withOpacity(0.5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: viewModel.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Xác nhận'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
