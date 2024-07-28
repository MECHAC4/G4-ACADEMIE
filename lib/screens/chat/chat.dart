import 'package:flutter/material.dart';
import 'package:g4_academie/theme/theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, String>> messages = [
    {'role': 'assistant', 'text': 'Bonjour, comment puis-je vous aider ?'},
  ];

  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        messages.add({'role': 'user', 'text': _controller.text});
        _controller.clear();
        // Simulate assistant's response
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            messages.add({
              'role': 'assistant',
              'text':
                  'Merci pour votre message, je vais vous répondre sous peu.'
            });
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  messages = [
                    {
                      'role': 'assistant',
                      'text': 'Bonjour, comment puis-je vous aider ?'
                    },
                  ];
                });
              },
              icon: Icon(
                Icons.add,
                color: lightColorScheme.surface,
              ))
        ],
        leading: Icon(
          Icons.chat,
          color: lightColorScheme.surface,
        ),
        title: Text(
          "Assistant",
          style: TextStyle(color: lightColorScheme.surface),
        ),
        backgroundColor: lightColorScheme.primary,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message['role'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5.0),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 14.0),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(message['text']!),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    maxLines: null,
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Tapez votre message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: lightColorScheme.primary,
                  ),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
