import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../viewmodels/home/setting_viewmodel.dart';

class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<SettingView> createState() => _SettingView();
}

class _SettingView extends State<SettingView> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    final List<Map<String, dynamic>> settings = [
      {
        'icon': Icons.email,
        'title': 'Email',
        'subtitle': user?.email ?? 'invalid',
      },
      {
        'icon': Icons.person_outline,
        'title': 'Tên người dùng',
        'subtitle': user?.username ?? 'invalid',
      },
      {'icon': Icons.workspace_premium_outlined, 'title': 'Nâng cấp lên Plus'},
      {'icon': Icons.person_outline, 'title': 'Cá nhân hóa'},
      {
        'icon': Icons.settings_input_component_outlined,
        'title': 'Kiểm soát dữ liệu',
      },
      {'icon': Icons.call, 'title': 'Thoại'},
      {'icon': Icons.security, 'title': 'Bảo mật'},
      {'icon': Icons.info_outline, 'title': 'Về'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Setting')),
      backgroundColor: const Color(0xFFF7F7F8),
      body: ListView(
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(
              user?.username ?? 'Chưa đăng nhập',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(user?.email ?? ''),
          ),
          const Divider(),
          ...settings.map(
            (item) => ListTile(
              leading: Icon(item['icon']),
              title: Text(item['title']),
              subtitle:
                  item.containsKey('subtitle') ? Text(item['subtitle']) : null,
              onTap: () {
                // Xử lý khi nhấn
              },
            ),
          ),
          const Divider(),
          Consumer<SettingViewModel>(
            builder: (context, settingViewModel, child) {
              return ListTile(
                leading:
                    settingViewModel.isLoggingOut
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.logout, color: Colors.red),
                title: Text(
                  settingViewModel.isLoggingOut
                      ? 'Đang đăng xuất...'
                      : 'Đăng xuất',
                  style: TextStyle(
                    color:
                        settingViewModel.isLoggingOut
                            ? Colors.grey
                            : Colors.red,
                  ),
                ),
                enabled: !settingViewModel.isLoggingOut,
                onTap:
                    settingViewModel.isLoggingOut
                        ? null
                        : () async {
                          final shouldLogout = await settingViewModel
                              .showLogoutConfirmation(context);
                          if (shouldLogout) {
                            await settingViewModel.logout(context);
                          }
                        },
              );
            },
          ),
        ],
      ),
    );
  }
}
