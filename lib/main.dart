import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:g4_academie/app_UI.dart';
import 'package:g4_academie/screens/auth_screen/signin_screen.dart';
import 'package:g4_academie/screens/auth_screen/signup_screen.dart';
import 'package:g4_academie/screens/auth_screen/welcome_screen.dart';
import 'package:g4_academie/services/auth_services.dart';
import 'package:g4_academie/services/cache/cache_service.dart';
import 'package:g4_academie/theme/theme.dart';
import 'package:g4_academie/users.dart';

import 'constants.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message)async {
  print('Background message ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  /*await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.appAttest,
  );*/
  //FirebaseMessaging.onMessageOpenedApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}



class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool canConnect = false;
  bool isSignup = false;
  String uid = '';
  AppUser? appUser;

  Future<void> loadCache() async{
    Map<String, dynamic>? data = await SignUpDataManager().initSignDatabase();
    if(data!=null && data.isNotEmpty){
      isSignup = true;
      if(data['statut'] == 'canConnect'){
        canConnect = true;
        uid = data['uid'];
        if(uid != ''){
          appUser = await AuthService().getUserById(uid);
        }
      }
    }
  }


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: lightMode,
      home: /*const OTPVerificationPage(email: "joseadjovi67@gmail.com", phoneNumber: null,)*/FutureBuilder(future:loadCache() , builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting){
          return const WelcomeScreen();
        }else{
          if(isSignup && !canConnect){
            return const SignInScreen();
          }else
            if(isSignup && canConnect && appUser != null){
              return AppUI(appUser: appUser!);
            }else
              if(!isSignup){
                return const SignUpScreen();
              }
        }
        return const WelcomeScreen();
      },)//appUser!=null? AppUI(appUser: appUser!) :const WelcomeScreen(),
    );
  }
}
