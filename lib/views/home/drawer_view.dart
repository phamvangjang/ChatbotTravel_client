import 'package:flutter/material.dart';
import 'package:mobilev2/views/home/setting_view.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class DrawerView extends StatelessWidget {
  const DrawerView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return Drawer(
      backgroundColor: const Color(0xFFF7F7F8),
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  children: const [
                    ListTile(title: Text("Chào hỏi trợ giúp")),
                    ListTile(title: Text("Dự báo thời tiết hôm nay")),
                    ListTile(title: Text("MVVM Flutter Project Setup")),
                    ListTile(title: Text("Dịch ghi âm và lọc")),
                    ListTile(title: Text("AudioFiles và SelectedRecording")),
                    ListTile(title: Text("XAML MVVM WPF Recorder")),
                    ListTile(title: Text("MVVM Flutter Folder Structure")),
                    ListTile(title: Text("Chạy FastAPI với Uvicorn")),
                    ListTile(title: Text("Ứng dụng ấn tượng cho Fullstack")),
                    ListTile(title: Text("Chào hỏi trợ giúp")),
                    ListTile(title: Text("Dự báo thời tiết hôm nay")),
                    ListTile(title: Text("MVVM Flutter Project Setup")),
                    ListTile(title: Text("Dịch ghi âm và lọc")),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                leading: CircleAvatar(child: Text(
                  (user?.username.substring(0, 2).toUpperCase() ?? ''),
                )),
                title: Text(user?.username ?? 'Invalid'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingView()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
