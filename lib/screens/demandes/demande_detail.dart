import 'package:flutter/material.dart';
import 'package:g4_academie/constants.dart';
import 'package:g4_academie/courses_notification.dart';
import 'package:g4_academie/users.dart';

import '../../theme/theme.dart';

class DemandeDetail extends StatelessWidget {
  final CoursesNotification demande;
  final AppUser? user;
  final AppUser? admin;

  const DemandeDetail(
      {super.key, required this.demande, this.admin, this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: lightColorScheme.primary,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        title: const Text("Détails de la demande",
            style: const TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:demande.type ==2? demandeType2Detail(): demandeType0Detail(),
      ),
    );
  }

  Widget demandeType2Detail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Demande de cours adressée à $appName :",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Text("\n"),
        Text(
          "Matière: ${demande.matiere}",
          style: const TextStyle(fontSize: 20),
        ),
        const Text("\n"),
        Text(
          "Date de la demande: ${demande.dateEnvoi.day}/${demande.dateEnvoi.month}/${demande.dateEnvoi.year} à ${demande.dateEnvoi.hour}:${demande.dateEnvoi.minute}",
          style: const TextStyle(fontSize: 20),
        ),
        const Text("\n"),
        const Text(
          "Statut:  En cours de traitement",
          style: const TextStyle(fontSize: 20),
        ),
      ],
    );
  }

  Widget demandeType0Detail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Postulation pour un cours de maison adressée à $appName :",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Text("\n"),
        Text(
          "Matière: ${demande.matiere}",
          style: const TextStyle(fontSize: 20),
        ),
        const Text("\n"),
        Text(
          "Date de la demande: ${demande.dateEnvoi.day}/${demande.dateEnvoi.month}/${demande.dateEnvoi.year} à ${demande.dateEnvoi.hour}:${demande.dateEnvoi.minute}",
          style: const TextStyle(fontSize: 20),
        ),
        const Text("\n"),
        const Text(
          "Statut:  En cours de traitement",
          style: const TextStyle(fontSize: 20),
        ),
      ],
    );
  }



}
