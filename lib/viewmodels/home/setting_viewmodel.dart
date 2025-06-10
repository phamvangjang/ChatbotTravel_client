import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../services/auth/auth_service.dart';
import 'main_viewmodel.dart';

class SettingViewModel extends ChangeNotifier{
  final AuthService _authService = AuthService();
  bool _isLoggingOut = false;

  bool get isLoggingOut => _isLoggingOut;

  Future<void> logout(BuildContext context) async {
    if (_isLoggingOut) return;

    _isLoggingOut = true;
    notifyListeners();

    try {
      // 1. Logout từ service
      await _authService.logout();

      if (!context.mounted) return;

      // 2. Clear UserProvider
      Provider.of<UserProvider>(context, listen: false).clearUser();

      // 3. Reset MainViewModel
      Provider.of<MainViewModel>(context, listen: false).logout();

      if (!context.mounted) return;

      // 4. Navigate
      Navigator.of(context, rootNavigator: true)
          .pushNamedAndRemoveUntil('/login', (route) => false);

    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đăng xuất: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _isLoggingOut = false;
      notifyListeners();
    }
  }

  Future<bool> showLogoutConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    ) ?? false;
  }
}