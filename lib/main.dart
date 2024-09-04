import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:g4_academie/screens/auth_screen/welcome_screen.dart';
import 'package:g4_academie/theme/theme.dart';
//import 'package:webview_flutter/webview_flutter.dart';

import 'constants.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Demander la permission de recevoir des notifications
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Gérer les messages en arrière-plan
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Gérer les messages en premier plan
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Message reçu en premier plan : ${message.messageId}');
    // Afficher la notification ici
  });




  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: lightMode,
      home: const WelcomeScreen(),
    );
  }
}
