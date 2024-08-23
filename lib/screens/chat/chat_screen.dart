import 'package:flutter/material.dart';
import 'package:g4_academie/theme/theme.dart';


import '../../services/message_service/chat_params.dart';
import 'chat.dart';

class ChatScreen extends StatelessWidget {
  final ChatParams chatParams;

  const ChatScreen({Key? key, required this.chatParams}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightColorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
          backgroundColor: lightColorScheme.primary,
          elevation: 0.0,
          centerTitle: true,
          title: Text((chatParams.peer.firstName == 'admin' && chatParams.peer.lastName == 'admin' && chatParams.peer.address == 'admin')?'Assistance':'Discussion avec ${chatParams.peer.lastName}', style: const TextStyle(color: Colors.white),)
      ),
      body: Chat(chatParams: chatParams),
    );
  }
}
