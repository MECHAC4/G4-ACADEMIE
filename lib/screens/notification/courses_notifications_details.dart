import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:g4_academie/screens/verification/verification.dart';
import 'package:g4_academie/services/notification_service/courses_not_services.dart';
import 'package:intl/intl.dart';

import '../../constants.dart';
import '../../courses_notification.dart';
import '../../users.dart';

class NotificationDetailsPage extends StatefulWidget {
  final CoursesNotification notification;
  final AppUser? user;
  final AppUser admin;
  final int type;

  const NotificationDetailsPage(
      {super.key,required this.type, required this.notification, this.user, required this.admin});

  @override
  State<NotificationDetailsPage> createState() => _NotificationDetailsPageState();
}

class _NotificationDetailsPageState extends State<NotificationDetailsPage> {
  @override
  Widget build(BuildContext context) {
    switch(widget.type){
      case 1:
        return buildNotificationType1();
      case 3:
        return buildNotificationType3();
      case 4:
        return buildNotificationType4();

    }
    return const Scaffold();
  }



  List<Widget> emploi(List<Map<String, dynamic>> weekDuration) {
    return weekDuration
        .map((schedule) => Text(
              ' ${schedule['day']} de ${schedule['startTime']} à ${schedule['endTime']}',
              style: const TextStyle(fontSize: 20),
            ))
        .toList();
  }

  Future<bool> isProfilVerified() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('verification')
        .doc(widget.user!.id)
        .get();
    return doc.exists;
  }

  Widget buildNotificationType1(){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(onPressed: (){
          Navigator.of(context).pop();
        }, icon: const Icon(Icons.arrow_back_ios, color: Colors.white,)),
        title: const Text('Détails du Job'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
              "$appName vous invite à encadrer l'élève suivant en ${widget.notification.matiere}:",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text("Nom: ${widget.notification.nom} ${widget.notification.prenom}",
              style: const TextStyle(fontSize: 20)),
          Text("Adresse: ${widget.notification.adresse}",
              style: const TextStyle(fontSize: 20)),
          Text("Classe: ${widget.notification.classe}",
              style: const TextStyle(fontSize: 20)),
          if (widget.notification.nombreHeuresParSemaine.isNotEmpty)
            Text(
                "Nombre d'heures par semaine: ${widget.notification.nombreHeuresParSemaine}",
                style: const TextStyle(fontSize: 20)),
          Row(
            children: [
              const Text("Emploi du temps:", style: TextStyle(fontSize: 20)),
              Column(
                children: emploi(widget.notification.emploiDuTemps),
              )
            ],
          ),
          Text(
              "Envoyé le: ${DateFormat('dd MMM kk:mm').format(widget.notification.dateEnvoi)}",
              style: const TextStyle(fontSize: 20)),
        ],
      ),
      floatingActionButton: TextButton(
          onPressed: () async {
            bool isVerified = await isProfilVerified();
            if (isVerified) {
              CoursesNotificationService().envoyerNotification(
                  CoursesNotification(
                      type: 2,
                      id: widget.user!.id,
                      nom: widget.user!.firstName,
                      prenom: widget.user!.lastName,
                      adresse: widget.user!.address,
                      classe: widget.notification.classe,
                      matiere: widget.notification.matiere,
                      nombreHeuresParSemaine:
                      widget.notification.nombreHeuresParSemaine,
                      emploiDuTemps: widget.notification.emploiDuTemps,
                      eleveId: widget.user!.id,
                      compteId: widget.admin.id,
                      dateEnvoi: DateTime.now()));
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => VerificationStepPage(
                  user: widget.user,
                ),
              ));
            }
          },
          child: const Text(
            "Postuler",
            style: TextStyle(fontSize: 20),
          )),
    );
  }

  Widget buildNotificationType3(){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(onPressed: (){
          Navigator.of(context).pop();
        }, icon: const Icon(Icons.arrow_back_ios, color: Colors.white,)),
        title: const Text('Statut de la candidature'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Votre candidature pour encadrer l'élève ${widget.notification.nom + widget.notification.nom} a été accepté ou rejetté pour cause : cause"),
          Text("Envoyé le: ${widget.notification.dateEnvoi.day}/${widget.notification.dateEnvoi.month}/${widget.notification.dateEnvoi.year} à ${widget.notification.dateEnvoi.hour}:${widget.notification.dateEnvoi.minute}"),
        ],
      ),
    );
  }

  Widget buildNotificationType4(){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(onPressed: (){
          Navigator.of(context).pop();
        }, icon: const Icon(Icons.arrow_back_ios, color: Colors.white,)),
        title: const Text('Statut de la demande'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Nous vous avons trouvé un enseignant vérifié avec un profil correspondant à celui que vous cherchez pour votre cours de maison en ${widget.notification.matiere}"),
          Text("Envoyé le: ${widget.notification.dateEnvoi.day}/${widget.notification.dateEnvoi.month}/${widget.notification.dateEnvoi.year} à ${widget.notification.dateEnvoi.hour}:${widget.notification.dateEnvoi.minute}"),

        ],
      ),
    );
  }


}
