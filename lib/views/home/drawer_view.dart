import 'package:flutter/material.dart';
import 'package:mobilev2/viewmodels/home/drawer_viewmodel.dart';
import 'package:mobilev2/views/home/setting_view.dart';
import 'package:provider/provider.dart';
import '../../models/conversation.dart';
import '../../providers/user_provider.dart';
import '../../viewmodels/home/main_viewmodel.dart';

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

class _DrawerContent extends StatefulWidget {
  const _DrawerContent({super.key});

  @override
  State<_DrawerContent> createState() => _DrawerContentState();
}

class _DrawerContentState extends State<_DrawerContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Hôm qua';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} ngày trước';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  String _getConversationTitle(Conversation conversation) {
    final formattedTime = _formatDateTime(conversation.startedAt);
    return 'Cuộc trò chuyện $formattedTime';
  }

  String _getConversationSubtitle(Conversation conversation) {
    final language =
        conversation.sourceLanguage == 'vi' ? 'Tiếng Việt' : 'English';
    final startTime =
        '${conversation.startedAt.hour.toString().padLeft(2, '0')}:${conversation.startedAt.minute.toString().padLeft(2, '0')}';
    return '$language • $startTime';
  }

  List<Conversation> _getFilteredConversations(
    List<Conversation> conversations,
  ) {
    if (_searchQuery.isEmpty) {
      return conversations;
    }

    return conversations.where((conversation) {
      final title = _getConversationTitle(conversation).toLowerCase();
      final subtitle = _getConversationSubtitle(conversation).toLowerCase();
      final query = _searchQuery.toLowerCase();

      return title.contains(query) || subtitle.contains(query);
    }).toList();
  }

  void _onConversationTap(
    BuildContext context,
    Conversation conversation,
  ) async {
    final mainViewModel = context.read<MainViewModel>();

    // Đóng drawer trước
    Navigator.of(context).pop();

    // Hiển thị loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text('Đang tải cuộc trò chuyện...'),
          ],
        ),
        duration: Duration(seconds: 1),
      ),
    );

    // Tải cuộc trò chuyện
    try {
      await mainViewModel.loadConversation(conversation.conversationId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải cuộc trò chuyện: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showNewConversationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cuộc trò chuyện mới'),
            content: const Text(
              'Bạn có muốn bắt đầu cuộc trò chuyện mới không?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context); // Đóng dialog
                  Navigator.pop(context); // Đóng drawer

                  final mainViewModel = context.read<MainViewModel>();
                  await mainViewModel.startNewConversation();

                  // Refresh drawer conversations
                  final drawerViewModel = context.read<DrawerViewModel>();
                  await drawerViewModel.loadConversations();
                },
                child: const Text('Tạo mới'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<DrawerViewModel, MainViewModel>(
      builder: (context, drawerViewModel, mainViewModel, child) {
        final conversations = drawerViewModel.conversations;
        final isLoading = drawerViewModel.isLoading;
        final user = Provider.of<UserProvider>(context).user;
        final filteredConversations = _getFilteredConversations(conversations);

        return Drawer(
          backgroundColor: const Color(0xFFF7F7F8),
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: Column(
                children: [
                  // Header với nút tạo cuộc trò chuyện mới
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.chat,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Cuộc trò chuyện',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed:
                                  () => _showNewConversationDialog(context),
                              icon: const Icon(Icons.add, color: Colors.white),
                              tooltip: 'Tạo cuộc trò chuyện mới',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${conversations.length} cuộc trò chuyện',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Thanh tìm kiếm
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm cuộc trò chuyện...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon:
                            _searchQuery.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                                : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),

                  // Danh sách cuộc trò chuyện
                  Expanded(
                    child:
                        isLoading
                            ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text('Đang tải cuộc trò chuyện...'),
                                ],
                              ),
                            )
                            : filteredConversations.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _searchQuery.isNotEmpty
                                        ? Icons.search_off
                                        : Icons.chat_bubble_outline,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchQuery.isNotEmpty
                                        ? 'Không tìm thấy cuộc trò chuyện'
                                        : 'Chưa có cuộc trò chuyện nào',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (_searchQuery.isEmpty) ...[
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Nhấn nút + để tạo mới',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              itemCount: filteredConversations.length,
                              itemBuilder: (context, index) {
                                final conversation =
                                    filteredConversations[index];
                                final isSelected =
                                    mainViewModel
                                        .currentConversation
                                        ?.conversationId ==
                                    conversation.conversationId;

                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? Colors.blue.shade50
                                            : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        isSelected
                                            ? Border.all(
                                              color: Colors.blue.shade300,
                                              width: 2,
                                            )
                                            : Border.all(
                                              color: Colors.grey.shade200,
                                              width: 1,
                                            ),
                                    boxShadow:
                                        isSelected
                                            ? [
                                              BoxShadow(
                                                color: Colors.blue.shade100,
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                            : null,
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          isSelected
                                              ? Colors.blue.shade600
                                              : Colors.grey.shade300,
                                      child: Icon(
                                        Icons.chat_bubble,
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : Colors.grey.shade600,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      _getConversationTitle(conversation),
                                      style: TextStyle(
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                        color:
                                            isSelected
                                                ? Colors.blue.shade800
                                                : Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    subtitle: Text(
                                      _getConversationSubtitle(conversation),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            isSelected
                                                ? Colors.blue.shade600
                                                : Colors.grey.shade600,
                                      ),
                                    ),
                                    trailing:
                                        isSelected
                                            ? Icon(
                                              Icons.check_circle,
                                              color: Colors.blue.shade600,
                                              size: 20,
                                            )
                                            : const Icon(
                                              Icons.arrow_forward_ios,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                    onTap:
                                        () => _onConversationTap(
                                          context,
                                          conversation,
                                        ),
                                  ),
                                );
                              },
                            ),
                  ),

                  // Divider
                  const Divider(height: 1),

                  // User profile section
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          (user?.username.substring(0, 2).toUpperCase() ?? 'U'),
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        user?.username ?? 'Invalid',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: const Text(
                        'Xem cài đặt',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(
                        Icons.settings,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingView(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
