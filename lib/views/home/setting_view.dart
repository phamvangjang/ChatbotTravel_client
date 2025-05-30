import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/auth/auth_service.dart';

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
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await AuthService().logout();
              Provider.of<UserProvider>(context, listen: false).clearUser();
              Navigator.pop(context);
              Navigator.of(context, rootNavigator: true)
                  .pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
