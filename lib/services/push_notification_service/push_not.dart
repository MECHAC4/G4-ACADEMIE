import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

class PushNotificationService{

  static void initialize(){
    FirebaseMessaging.instance.requestPermission();

    FirebaseMessaging.onMessage.listen((event) {
      debugPrint("Nouveau message push");
    },);

    FirebaseMessaging.onMessageOpenedApp.listen((event) {

    },);

  }

  static Future<String?> getToken() async{
    return FirebaseMessaging.instance.getToken();
  }

}
