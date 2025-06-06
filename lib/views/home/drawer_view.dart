import 'package:flutter/material.dart';
import 'package:mobilev2/viewmodels/home/drawer_viewmodel.dart';
import 'package:mobilev2/views/home/setting_view.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class DrawerView extends StatelessWidget {
  const DrawerView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    if (user == null) {
      return const Center(child: Text('Người dùng chưa đăng nhập'));
    }

    return ChangeNotifierProvider(
      create: (_) => DrawerViewModel(user.id),
      child: const _DrawerContent(), // Đặt UI chính ở widget con
    );
  }
}

class _DrawerContent extends StatelessWidget {
  const _DrawerContent({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DrawerViewModel>(context);
    final conversations = viewModel.conversations;
    final isLoading = viewModel.isLoading;
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
                child:
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                          itemCount: conversations.length,
                          itemBuilder: (context, index) {
                            final convo = conversations[index];
                            return ListTile(
                              title: Text(
                                "Cuộc trò chuyện ${convo.conversationId}",
                              ),
                              subtitle: Text(
                                "Ngôn ngữ: ${convo.sourceLanguage}",
                              ),
                            );
                          },
                        ),
              ),
              const Divider(),
              ListTile(
                leading: CircleAvatar(
                  child: Text(
                    (user?.username.substring(0, 2).toUpperCase() ?? ''),
                  ),
                ),
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
