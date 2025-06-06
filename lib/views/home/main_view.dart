import 'package:flutter/material.dart';
import 'package:mobilev2/viewmodels/home/main_viewmodel.dart';
import 'package:mobilev2/views/home/drawer_view.dart';
import 'package:provider/provider.dart';
import '../../models/message_model.dart';

void main() {
  runApp(const MainPage());
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MainViewModel mainViewModel = MainViewModel();
  late Future<List<Message>> futureMessages;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    futureMessages = mainViewModel.loadMessages();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "AI Agent Travel",
          style: TextStyle(color: Colors.black),
        ),
        elevation: 1,
        centerTitle: true,
        actions: [
          // Nút tạo cuộc trò chuyện mới
          IconButton(
            icon: const Icon(Icons.edit_note, color: Colors.grey),
            onPressed: () {
              mainViewModel.startNewConversation();
            },
          ),
          // Nút refresh
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.grey),
            onPressed: () {
              mainViewModel.refresh();
            },
          ),
        ],
      ),
      drawer: const DrawerView(),
      backgroundColor: const Color(0xFFF7F7F8),
      body: Consumer<MainViewModel>(
        builder: (context, mainViewModel, child) {
          return Column(
            children: [
              // Hiển thị error nếu có
              if (mainViewModel.error != null)
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
                          mainViewModel.error!,
                          style: TextStyle(color: Colors.red.shade800),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () => mainViewModel.clearError(),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              // Danh sách tin nhắn
              Expanded(
                child: _buildMessagesList(mainViewModel),
              ),
              const Divider(height: 1),
              ChatInput(
                onSendMessage: (message) {
                  mainViewModel.sendMessage(message);
                  // Scroll xuống cuối sau khi gửi tin nhắn
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });
                },
                onSendAudio: () {
                  mainViewModel.sendAudioMessage();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });
                },
                isEnabled: !mainViewModel.isSending,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessagesList(MainViewModel mainViewModel) {
    if (mainViewModel.isLoading) {
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

    if (mainViewModel.messages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "Chào mừng bạn đến với Travel Assistant!\nHãy bắt đầu cuộc trò chuyện.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount:
          mainViewModel.messages.length + (mainViewModel.isSending ? 1 : 0),
      itemBuilder: (context, index) {
        // Hiển thị loading indicator khi đang gửi
        if (index == mainViewModel.messages.length && mainViewModel.isSending) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(width: 40),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text("Đang trả lời...", style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        final msg = mainViewModel.messages[index];
        final isUser = msg.sender.toLowerCase() == 'user';

        return Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            ChatBubble(
              message:
                  msg.translatedText.isNotEmpty
                      ? msg.translatedText
                      : msg.messageText,
              isUser: isUser,
              showActions: !isUser,
              extraAction:
                  (!isUser &&
                          (msg.messageText.contains("Địa điểm:") ||
                              msg.translatedText.contains("Địa điểm:")))
                      ? IconButton(
                        icon: const Icon(
                          Icons.map,
                          color: Colors.blue,
                          size: 16,
                        ),
                        onPressed:
                            (msg.translatedText.isNotEmpty ||
                                    msg.messageText.isNotEmpty)
                                ? () => mainViewModel.openMapWithMessageText(
                                  context,
                                  msg.translatedText.isNotEmpty
                                      ? msg.translatedText
                                      : msg.messageText,
                                )
                                : null,
                      )
                      : null,
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final bool showActions;
  final Widget? extraAction;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.showActions = false,
    this.extraAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          constraints: const BoxConstraints(maxWidth: 300),
          decoration: BoxDecoration(
            color: isUser ? Colors.grey[200] : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.replaceAll("**", ""),
            style: TextStyle(
              fontSize: 15,
              fontWeight:
                  message.contains("**") ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        if (showActions)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              children: [
                Icon(Icons.thumb_up, size: 16, color: Colors.blue),
                SizedBox(width: 8),
                Icon(Icons.thumb_down, size: 16, color: Colors.orange),
                SizedBox(width: 8),
                Icon(Icons.refresh, size: 16, color: Colors.grey),
                if (extraAction != null) ...[extraAction!],
              ],
            ),
          ),
      ],
    );
  }
}

class ChatInput extends StatefulWidget {
  final Function(String message) onSendMessage;
  final Function() onSendAudio;
  final bool isEnabled;

  const ChatInput({
    super.key,
    required this.onSendMessage,
    required this.onSendAudio,
    required this.isEnabled,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12).copyWith(bottom: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.mic_none_outlined),
            onPressed: widget.isEnabled ? widget.onSendAudio : null,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: widget.isEnabled,
              decoration: const InputDecoration(
                hintText: "Ask anything",
                border: InputBorder.none,
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  widget.onSendMessage(value.trim());
                  _controller.clear();
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed:
                widget.isEnabled
                    ? () {
                      final text = _controller.text.trim();
                      if (text.isNotEmpty) {
                        widget.onSendMessage(text);
                        _controller.clear();
                      }
                    }
                    : null,
          ),
        ],
      ),
    );
  }
}
