import 'package:flutter/material.dart';
import 'package:mobilev2/viewmodels/home/main_viewmodel.dart';
import 'package:mobilev2/views/home/drawer_view.dart';
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

  @override
  void initState() {
    super.initState();
    futureMessages = mainViewModel.loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Travel Assistant - HCM City",
          style: TextStyle(color: Colors.black),
        ),
        elevation: 1,
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.edit_note, color: Colors.grey),
          ),
        ],
      ),
      drawer: const DrawerView(),
      backgroundColor: const Color(0xFFF7F7F8),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<Message>>(
              future: futureMessages,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Không có tin nhắn nào."));
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isUser = msg.sender.toLowerCase() == 'user';
                    return Column(
                      crossAxisAlignment:
                          isUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment:
                              isUser
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
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
                                          (msg.messageText.contains(
                                                "Địa điểm:",
                                              ) ||
                                              msg.translatedText.contains(
                                                "Địa điểm:",
                                              )))
                                      ? IconButton(
                                        icon: const Icon(
                                          Icons.map,
                                          color: Colors.blue,
                                          size: 16,
                                        ),
                                        onPressed:
                                            (msg.translatedText.isNotEmpty ||
                                                    msg.messageText.isNotEmpty)
                                                ? () => mainViewModel
                                                    .openMapWithMessageText(
                                                      context,
                                                      msg
                                                              .translatedText
                                                              .isNotEmpty
                                                          ? msg.translatedText
                                                          : msg.messageText,
                                                    )
                                                : null,
                                      )
                                      : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                );
              },
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
                if (extraAction != null) ...[
                  extraAction!,
                ],
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
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
      ).copyWith(bottom: 12),
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
