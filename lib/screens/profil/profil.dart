import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:g4_academie/screens/auth_screen/signin_screen.dart';
import 'package:g4_academie/screens/notification/courses_notification_screen.dart';
import 'package:g4_academie/screens/profil/about_us.dart';
import 'package:g4_academie/screens/profil/politiques.dart';
import 'package:g4_academie/screens/profil/user_profil.dart';
import 'package:g4_academie/services/auth_services.dart';
import 'package:g4_academie/theme/theme.dart';

import '../../services/cache/cache_service.dart';
import '../../users.dart';

class ProfileScreen extends StatefulWidget {
  final AppUser appUser;

  const ProfileScreen({super.key, required this.appUser});

  get admin => AppUser(
      id: 'rY33iKsQgGew8akQ4ILyULwrYSt2',
      firstName: '',
      lastName: '',
      address: '',
      userType: '',
      emailOrPhone: '',
      password: '');

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late AppUser _appUser;

  Future<bool> isProfilVerified() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('verification')
        .doc(widget.appUser.id)
        .get();
    return doc.exists;
  }

  bool isVerified = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _appUser = widget.appUser;
    verification();
    _load();
  }

  void _load() async {
    verificationData = await getVerificationData();
  }

  Future<Map<String, dynamic>?> getVerificationData() async {
    final doc = await FirebaseFirestore.instance
        .collection('verification')
        .doc(widget.appUser.id)
        .get();

    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  Map<String, dynamic>? verificationData = {};

  Widget _buildProfileImage(BuildContext context, String? imageUrl) {
    _load();
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          //height: 180,
          width: double.infinity,
          //color: Colors.blueAccent,
        ),
        GestureDetector(
            onTap: () {
              if (imageUrl != null) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => UserProfilePage(user: widget.appUser),
                ));
              }
            },
            child: ListTile(
              leading: CircleAvatar(
                //radius: 60,
                radius: MediaQuery.of(context).size.width / 10,
                backgroundColor: lightColorScheme.primary,
                backgroundImage:
                    imageUrl != null ? NetworkImage(imageUrl) : null,
                // backgroundColor: Colors.white,
                child: imageUrl == null
                    ? const Icon(Icons.person, color: Colors.blue, size: 50)
                    : null,
              ),
              title: Row(
                children: [
                  Flexible(
                    child: Text(
                      '${_appUser.firstName.toUpperCase()} ${_appUser.lastName.toUpperCase()}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  //Flexible(child: statut(context)),
                ],
              ),
            )),
      ],
    );
  }

  Future<String> checkStatut() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('verification')
        .doc(widget.appUser.id)
        .get();
    Map<String, dynamic> docMap = doc.data() as Map<String, dynamic>;
    return docMap['status']!;
  }

  void verification() async {
    isVerified = await isProfilVerified();
  }

  String state = '';

  void profilState() async {
    state = await checkStatut();
    setState(() {});
  }

  /*Widget statut(BuildContext context){
    setState(() {
      verification();
    });

    if(isVerified){
      setState(() {
        profilState();
      });
        return  Row(
          children: [
            Flexible(child: Text("($state)", style: const TextStyle(color: Colors.orange),)),
            if(state == 'Vérifié')
            const Flexible(child: Icon(Icons.verified, color: Colors.blue,))
          ],
        );
    }else{
      return const Text("(Profil non vérifié)", style: TextStyle(color: Colors.red),);
    }
  }*/

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: ListView(
        padding:
            EdgeInsets.symmetric(horizontal: width / 22, vertical: width / 18),
        children: [
          _buildProfileImage(context, verificationData?['profileImage']),
          const SizedBox(height: 20),
          buildMenuItem(context, 'Information de profil'),
          buildMenuItem(context, 'Notifications'),
          buildMenuItem(context, 'Paramètres'),
          buildMenuItem(context, 'A propos de nous'),
          buildMenuItem(context, 'Politiques et règles de confidentialité'),
          buildMenuItem(context, 'Déconnexion'),
        ],
      ),
    );
  }

  Widget buildMenuItem(BuildContext context, String title) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      color: lightColorScheme.surface,
      //elevation: 2,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        title: Text(title),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: lightColorScheme.primary.withOpacity(0.6),
        ),
        onTap: () {
          switch (title) {
            case "Déconnexion":
              AuthService().signOut();
              //Navigator.of(context).pop();
              /*Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const SignInScreen(),
              ));*/
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const SignInScreen(),
                ),
                (route) => false,
              );
              SignUpDataManager()
                  .saveSignUpInfo(widget.appUser.id, "canNotConnect");
              break;
            case 'Information de profil':
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => UserProfilePage(user: widget.appUser),
              ));
              break;
            case 'Notifications':
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => NotificationsPage(
                    appUser: widget.appUser, admin: widget.admin),
              ));
              break;
            case 'Politiques et règles de confidentialité':
          Navigator.of(context).pop();
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const PrivacyPolicyPage(),));
          break;
            case 'A propos de nous':
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AboutUsPage(),));

          }
          // Handle navigation or actions here
        },
      ),
    );
  }
}
