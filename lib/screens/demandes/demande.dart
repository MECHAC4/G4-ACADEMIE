import 'package:flutter/material.dart';
import 'package:g4_academie/screens/demandes/demande_detail.dart';
import 'package:intl/intl.dart';

import '../../courses_notification.dart';
import '../../services/notification_service/courses_not_services.dart';
import '../../theme/theme.dart';
import '../../users.dart';

class DemandePage extends StatefulWidget {
  final AppUser appUser;
  final AppUser admin;
  const DemandePage({super.key, required this.appUser, required this.admin});

  @override
  State<DemandePage> createState() => _DemandePageState();
}

class _DemandePageState extends State<DemandePage> with SingleTickerProviderStateMixin {
  late CoursesNotificationService _notificationService;
  List<CoursesNotification> demandes = [];

  @override
  void initState() {
    super.initState();
    _notificationService = CoursesNotificationService();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    // Remplacez 'currentUserId' par l'ID de l'utilisateur actuellement connecté
    String currentUserId = widget.appUser.id;
    List<CoursesNotification> notifications =
    await _notificationService.getAskForUser(currentUserId);
      demandes = notifications;
      //demandes = notifications.where((element) => element.type == 0,).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: lightColorScheme.primary.withOpacity(1),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text("Demandes", style: TextStyle(color: Colors.white),),

      ),
      body:  _buildDemandeList(demandes),
    );
  }

  Widget _buildDemandeList(List<CoursesNotification> notifications) {
    return notifications.isNotEmpty? ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        CoursesNotification notification = notifications[index];
        switch (notification.type){
          case 0:
            return demandeType0Builder(notification);
          case 2:
            return demandeType2Builder(notification);
        }
        return null;
        //return demandeType0Builder(notification);
      },
    ): const Center(child: Text("Aucune demande"),);
  }


  Widget demandeType2Builder(CoursesNotification notification){
    return Card(
      elevation: 10,
      child: ListTile(
        title: Text("Vous avez postulé à un cours de maison en ${notification.matiere}"),
        subtitle: Text("Envoyé le: ${DateFormat('dd MMM kk:mm').format(notification.dateEnvoi)}"),
        onTap: () {
          _notificationService.marquerCommeVue(notification.id);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DemandeDetail(demande: notification, user : widget.appUser, admin: widget.admin,)),
          );
        },
      ),
    );
  }

  Widget demandeType0Builder(CoursesNotification notification){
    return Card(
      elevation: 10,
      child: ListTile(
        title: Text("Vous avez demandé un cours de maison en ${notification.matiere}"),
        subtitle: Text("Envoyé le: ${DateFormat('dd MMM kk:mm').format(notification.dateEnvoi)}"),
        onTap: () {
          _notificationService.marquerCommeVue(notification.id);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DemandeDetail(demande: notification, user : widget.appUser, admin: widget.admin,)),
          );
        },
      ),
    );
  }

  //Widget demande

}
