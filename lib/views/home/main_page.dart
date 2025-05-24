import 'package:flutter/material.dart';
import 'package:mobilev2/views/home/drawer_view.dart';

void main() => runApp(const MainPage());

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

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // String today = DateFormat('EEEE, dd MMMM yyyy', 'vi_VN').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Travel Assistant - HCM City", style: TextStyle(color: Colors.black)),
        elevation: 1,
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.edit_note, color: Colors.grey),
          ),
        ],
        // leading: const Icon(Icons.menu, color: Colors.grey),
      ),
      drawer: const DrawerView(),
      backgroundColor: const Color(0xFFF7F7F8),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // User Message
                Align(
                  alignment: Alignment.centerRight,
                  child: ChatBubble(
                    message: "xin chào",
                    isUser: true,
                  ),
                ),
                const SizedBox(height: 8),

                // GPT Response
                Align(
                  alignment: Alignment.centerLeft,
                  child: ChatBubble(
                    message: "Xin chào! Mình có thể giúp gì cho bạn hôm nay?",
                    isUser: false,
                  ),
                ),
                const SizedBox(height: 8),
                // User Message
                Align(
                  alignment: Alignment.centerRight,
                  child: ChatBubble(
                    message: "hôm nay là ngày nào?",
                    isUser: true,
                  ),
                ),
                const SizedBox(height: 8),
                // GPT Response with formatted date
                Align(
                  alignment: Alignment.centerLeft,
                  child: ChatBubble(
                    message:
                    "Hôm nay là **thứ Bảy, ngày 17 tháng 5 năm 2025**. Bạn cần mình hỗ trợ gì thêm không?",
                    isUser: false,
                    showActions: true,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ChatInput(),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final bool showActions;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.showActions = false,
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
              fontWeight: message.contains("**") ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        if (showActions)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              children: const [
                Icon(Icons.thumb_up_off_alt, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Icon(Icons.thumb_down_off_alt, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Icon(Icons.refresh, size: 16, color: Colors.grey),
              ],
            ),
          ),
      ],
    );
  }
}

class ChatInput extends StatelessWidget {
  const ChatInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding:
      const EdgeInsets.symmetric(horizontal: 12.0).copyWith(bottom: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.mic_none_outlined),
            onPressed: () {},
          ),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Ask anything",
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              // Navigator.pushNamed(context, '/home');
            },
          ),
        ],
      ),
    );
  }
}
