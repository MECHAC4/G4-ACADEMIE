import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/message_service/chat_params.dart';
import '../../services/message_service/message.dart';
import '../../services/message_service/message_database.dart';
import 'message_item.dart';

class Chat extends StatefulWidget {
  final ChatParams chatParams;
  const Chat({super.key, required this.chatParams});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final MessageDatabaseService messageService = MessageDatabaseService();

  //_ChatState(this.chatParams);

  late ChatParams chatParams;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();

  int _nbElement = 20;
  static const int paginationIncrement = 20;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    chatParams = widget.chatParams;
    listScrollController.addListener(_scrollListener);
  }

  _scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _nbElement += paginationIncrement;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [buildListMessage(), buildInput()],
        ),
        isLoading ? const CircularProgressIndicator() : Container()
      ],
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: StreamBuilder<List<Message>>(
        stream:
            messageService.getMessage(chatParams.getChatGroupId(), _nbElement),
        builder: (BuildContext context, AsyncSnapshot<List<Message>> snapshot) {
          if (snapshot.hasData) {
            List<Message> listMessage = snapshot.data ?? List.from([]);
            return ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemBuilder: (context, index) => MessageItem(
                  message: listMessage[index],
                  userId: chatParams.userUid,
                  isLastMessage: isLastMessage(index, listMessage)),
              itemCount: listMessage.length,
              reverse: true,
              controller: listScrollController,
            );
          } else {
            return const Center(child:  CircularProgressIndicator());
          }
        },
      ),
    );
  }

  bool isLastMessage(int index, List<Message> listMessage) {
    if (index == 0) return true;
    if (listMessage[index].idFrom != listMessage[index - 1].idFrom) return true;
    return false;
  }

  Widget buildInput() {
    return Container(
      width: double.infinity,
      height: 75.0,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration:  BoxDecoration(
          border: Border.all(color: Colors.black26),
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          color: Colors.white),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: const Icon(Icons.image),
                onPressed: getImage,
                color: Colors.blueGrey,
              ),
            ),
          ),
          Flexible(
            child: TextField(
              onSubmitted: (value) {
                onSendMessage(textEditingController.text, 0);
              },
              style: const TextStyle(color: Colors.blueGrey, fontSize: 15.0),
              controller: textEditingController,
              decoration: const InputDecoration.collapsed(
                hintText: 'Votre message...',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          // Button send message
          Material(
            color: Colors.white,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: Colors.blueGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadFile(pickedFile);
    }
  }

  Future uploadFile(XFile file) async {
    String fileName =
        "${DateTime.now().millisecondsSinceEpoch}.jpeg";
    try {
      Reference reference = FirebaseStorage.instance.ref().child(fileName);
      final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'picked-file-path': file.path});
      TaskSnapshot snapshot;
      if (kIsWeb) {
        snapshot = await reference.putData(await file.readAsBytes(), metadata);
      } else {
        snapshot = await reference.putFile(File(file.path), metadata);
      }

      String imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    } on Exception {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "Une erreur s'est produite; Veillez reessayer!");
    }
  }

  void onSendMessage(String content, int type) {
    if (content.trim() != '') {
      messageService.onSendMessage(
          chatParams.getChatGroupId(),
          Message(
              idFrom: chatParams.userUid,
              idTo: chatParams.peer.id,
              timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
              content: content,
              type: type));
      listScrollController.animateTo(0.0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      textEditingController.clear();
    } else {
      Fluttertoast.showToast(
          msg: 'Saisissez un message à envoyer',
          backgroundColor: Colors.red,
          textColor: Colors.white);
    }
  }
}
