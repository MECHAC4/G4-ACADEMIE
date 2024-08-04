import 'package:flutter/material.dart';
import 'package:g4_academie/screens/auth_screen/signin_screen.dart';
import 'package:g4_academie/services/auth_services.dart';
import 'package:g4_academie/theme/theme.dart';

import '../../users.dart';

class ProfileScreen extends StatefulWidget {
  final AppUser appUser;

  const ProfileScreen({super.key, required this.appUser});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late AppUser _appUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _appUser = widget.appUser;
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: ListView(
        padding:
            EdgeInsets.symmetric(horizontal: width / 22, vertical: width / 18),
        children: [
          ListTile(
            contentPadding: const EdgeInsets.only(left: 0),
            leading: CircleAvatar(
              radius: width / 10,
              backgroundColor: lightColorScheme.primary,
              child: const Icon(Icons.person, color: Colors.white, size: 50),
            ),
            title: Text(
              '${_appUser.firstName.toUpperCase()} ${_appUser.lastName.toUpperCase()}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          buildMenuItem(context, 'Information de profil'),
          buildMenuItem(context, 'Notification'),
          buildMenuItem(context, 'Paramètres'),
          buildMenuItem(context, 'A propos'),
          buildMenuItem(context, 'Politiques et règles'),
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
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const SignInScreen(),
              ));
          }
          // Handle navigation or actions here
        },
      ),
    );
  }
}
