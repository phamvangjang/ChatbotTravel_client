import 'package:flutter/material.dart';
import 'package:mobilev2/viewmodels/home/main_viewmodel.dart';
import 'package:mobilev2/views/home/drawer_view.dart';
import 'package:mobilev2/views/home/map_view.dart';
import 'package:mobilev2/views/widgets/chat_input.dart';
import 'package:provider/provider.dart';
import '../../models/message_model.dart';
import '../widgets/chat_bubble.dart';

class MainView extends StatefulWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  late MainViewModel mainViewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Khởi tạo dữ liệu khi widget được tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MainViewModel>().initialize();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Kiểm tra xem tin nhắn có chứa thông tin địa điểm không
  bool _containsLocationInfo(String message) {
    final locationKeywords = [
      'địa điểm',
      'location',
      'đi đến',
      'visit',
      'tham quan',
      'du lịch',
      'lịch trình',
      'itinerary',
      'bản đồ',
      'map',
      'tọa độ',
      'coordinates',
      'bến thành',
      'nhà thờ đức bà',
      'dinh độc lập',
      'landmark',
      'bitexco',
    ];

    final lowerMessage = message.toLowerCase();
    return locationKeywords.any((keyword) => lowerMessage.contains(keyword));
  }

  // Hiển thị popup với các tùy chọn cho tin nhắn du lịch
  void _showTravelOptionsPopup(BuildContext context, Message message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.travel_explore, color: Colors.blue.shade600),
                      const SizedBox(width: 12),
                      const Text(
                        'Tùy chọn du lịch',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Options
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.map, color: Colors.blue.shade600),
                  ),
                  title: const Text('Xem trên bản đồ'),
                  subtitle: const Text('Hiển thị địa điểm và lịch trình'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToMapView(context, message);
                  },
                ),

                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.route, color: Colors.green.shade600),
                  ),
                  title: const Text('Lập lịch trình'),
                  subtitle: const Text('Tạo kế hoạch chi tiết'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pop(context);
                    _createItinerary(context, message);
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  // Chuyển đến MapView
  void _navigateToMapView(BuildContext context, Message message) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => MapView(
              messageContent: message.messageText,
              conversationId: message.conversationId,
            ),
      ),
    );
  }

  // Tạo lịch trình
  void _createItinerary(BuildContext context, Message message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Lập lịch trình'),
            content: const Text(
              'Tính năng lập lịch trình đang được phát triển.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Consumer<MainViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                const Text(
                  "AI Agent Travel",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (viewModel.currentConversation != null)
                  Text(
                    "ID: ${viewModel.currentConversation!.conversationId}",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
              ],
            );
          },
        ),
        elevation: 1,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note, color: Colors.grey),
            onPressed: () {
              context.read<MainViewModel>().startNewConversation();
            },
            tooltip: 'Cuộc trò chuyện mới',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.grey),
            onPressed: () {
              context.read<MainViewModel>().refresh();
            },
            tooltip: 'Làm mới',
          ),
        ],
      ),
      drawer: const DrawerView(),
      backgroundColor: const Color(0xFFF7F7F8),
      body: Consumer<MainViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              // Hiển thị error nếu có
              if (viewModel.error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  color: Colors.red.shade100,
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red.shade800, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          viewModel.error!,
                          style: TextStyle(color: Colors.red.shade800),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () => viewModel.clearError(),
                      ),
                    ],
                  ),
                ),

              // Hiển thị thông tin cuộc trò chuyện hiện tại
              if (viewModel.currentConversation != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: Colors.blue.shade50,
                  child: Row(
                    children: [
                      Icon(Icons.chat, color: Colors.blue.shade600, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cuộc trò chuyện • ${viewModel.messages.length} tin nhắn',
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        viewModel.currentConversation!.sourceLanguage == 'vi'
                            ? 'Tiếng Việt'
                            : 'English',
                        style: TextStyle(
                          color: Colors.blue.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // Danh sách tin nhắn
              Expanded(child: _buildMessagesList(viewModel)),

              const Divider(height: 1),

              // Chat input
              ChatInput(
                onSendMessage: (message) {
                  viewModel.sendMessage(message);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });
                },
                isEnabled: !viewModel.isSending,
              ),
            ],
          );
        },
      ),
    );
  }

  // Method _buildMessagesList được định nghĩa ở đây
  Widget _buildMessagesList(MainViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Đang tải cuộc trò chuyện..."),
          ],
        ),
      );
    }

    if (viewModel.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.travel_explore,
                size: 64,
                color: Colors.blue.shade600,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Chào mừng bạn đến với AI Travel Assistant!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Hãy hỏi tôi về địa điểm du lịch, lịch trình\nhoặc bất kỳ thông tin nào về chuyến đi của bạn!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.messages.length + (viewModel.isSending ? 1 : 0),
      itemBuilder: (context, index) {
        // Hiển thị loading indicator khi đang gửi
        if (index == viewModel.messages.length && viewModel.isSending) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.smart_toy, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue.shade600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "AI đang suy nghĩ...",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        final msg = viewModel.messages[index];
        final isUser = msg.sender.toLowerCase() == 'user';
        final messageContent = msg.messageText;
        final hasLocationInfo = _containsLocationInfo(messageContent);

        return Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
                  isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isUser) ...[
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.smart_toy,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Column(
                    crossAxisAlignment:
                        isUser
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                    children: [
                      ChatBubble(
                        message: messageContent,
                        isUser: isUser,
                        showActions: !isUser,
                        messageType: msg.messageType ?? 'text',
                        voiceUrl: msg.voiceUrl,
                      ),

                      // Travel action buttons cho tin nhắn bot
                      if (!isUser && hasLocationInfo)
                        Container(
                          margin: const EdgeInsets.only(top: 8, left: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Nút xem bản đồ
                              ElevatedButton.icon(
                                onPressed:
                                    () => _navigateToMapView(context, msg),
                                icon: const Icon(Icons.map, size: 16),
                                label: const Text('Bản đồ'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Nút tùy chọn khác
                              OutlinedButton.icon(
                                onPressed:
                                    () => _showTravelOptionsPopup(context, msg),
                                icon: const Icon(Icons.more_horiz, size: 16),
                                label: const Text('Thêm'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.blue.shade600,
                                  side: BorderSide(color: Colors.blue.shade600),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                if (isUser) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      color: Colors.grey.shade600,
                      size: 18,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
