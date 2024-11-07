import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:g4_academie/profil_class.dart';
import 'package:g4_academie/screens/auth_screen/signin_screen.dart';
import 'package:g4_academie/screens/auth_screen/signup_screen.dart';
import 'package:g4_academie/screens/auth_screen/welcome_screen.dart';
import 'package:g4_academie/screens/dashboard_screens/builder/add_cours_builder.dart';
import 'package:g4_academie/services/auth_services.dart';
import 'package:g4_academie/services/cache/cache_service.dart';
import 'package:g4_academie/services/profil_services.dart';
import 'package:g4_academie/theme/theme.dart';
import 'package:g4_academie/users.dart';

import 'constants.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoading = true;
  bool canConnect = false;
  bool isSignup = false;
  String uid = '';
  AppUser? appUser;
  List<ProfilClass> profiles = [];

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    Map<String, dynamic>? data = await SignUpDataManager().initSignDatabase();
    if (data != null && data.isNotEmpty) {
      setState(() {
        isSignup = true;
      });
      if (data['statut'] == 'canConnect') {
        setState(() {
          canConnect = true;
          uid = data['uid'];
        });
        if (uid.isNotEmpty) {
          appUser = await AuthService().getUserById(uid);
          if (appUser != null) {
            profiles = await ProfilServices().fetchProfiles(appUser!.id);
            await createMainProfileIfNeeded(appUser!);
          }
        }
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> createMainProfileIfNeeded(AppUser appUser) async {
    bool mainProfilExist = await ProfilServices().profilExist(appUser.id);
    if (!mainProfilExist) {
      await ProfilServices().saveProfileToFirestore({
        'firstName': appUser.firstName,
        'lastName': appUser.lastName,
        'studentClass': appUser.studentClass ?? 'Particulière',
        'adresse': appUser.address,
      }, appUser.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: lightMode,
      home: isLoading
          ? const WelcomeScreen()
          : _getHomeScreen(),
    );
  }

  Widget _getHomeScreen() {
    if (isSignup && !canConnect) {
      return const SignInScreen();
    } else if (isSignup && canConnect && appUser != null) {
      return AddCourseDialog(appUser: appUser!, profiles: profiles);
    } else if (!isSignup) {
      return const SignUpScreen();
    } else {
      return const WelcomeScreen();
    }
  }
}
