import 'package:flutter/material.dart';
import 'package:g4_academie/theme/theme.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: width/22, vertical: width/18),
        children: [
          ListTile(
            contentPadding: const EdgeInsets.only(left: 0),
            leading: CircleAvatar(
              radius: width/10,
              backgroundColor: lightColorScheme.primary,
              child: const Icon(Icons.person, color: Colors.white, size: 50),
            ),
            title: const Text(
              'Nom  Prénom',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        title: Text(title),
        trailing: Icon(Icons.arrow_forward_ios,color: lightColorScheme.primary.withOpacity(0.6),),
        onTap: () {
          // Handle navigation or actions here
        },
      ),
    );
  }
}
