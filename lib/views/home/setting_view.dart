import 'package:flutter/material.dart';
// import 'package:mobilev2/viewmodels/home/setting_viewmodel.dart';
// import 'package:provider/provider.dart';

class SettingView extends StatefulWidget{
  const SettingView({super.key});

  @override
  State<SettingView> createState() => _SettingView();
}

class _SettingView extends State<SettingView> {
  @override
  Widget build(BuildContext context){
    // final viewmodel = Provider.of<SettingViewModel>(context);

    final List<Map<String, dynamic>> settings = [
      {
        'icon': Icons.email,
        'title': 'Email',
        'subtitle': 'giangphamvan48@gmail.com',
      },
      {
        'icon': Icons.phone,
        'title': 'Số điện thoại',
        'subtitle': '+918103090813',
      },
      {
        'icon': Icons.workspace_premium_outlined,
        'title': 'Nâng cấp lên Plus',
      },
      {
        'icon': Icons.person_outline,
        'title': 'Cá nhân hóa',
      },
      {
        'icon': Icons.settings_input_component_outlined,
        'title': 'Kiểm soát dữ liệu',
      },
      {
        'icon': Icons.call,
        'title': 'Thoại',
      },
      {
        'icon': Icons.security,
        'title': 'Bảo mật',
      },
      {
        'icon': Icons.info_outline,
        'title': 'Về',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Setting')),
      body: ListView(
        children: [
          const ListTile(
            leading: CircleAvatar(
              child: Text('GI'),
            ),
            title: Text(
              'nguyen quang',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          ...settings.map((item) => ListTile(
            leading: Icon(item['icon']),
            title: Text(item['title']),
            subtitle:
            item.containsKey('subtitle') ? Text(item['subtitle']) : null,
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Xử lý khi nhấn
            },
          )),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              // Xử lý đăng xuất
            },
          )
        ],
      ),
    );
  }
}