import 'package:flutter/material.dart';
import 'package:g4_academie/app_UI.dart';
import 'package:intl/intl.dart';

import '../../courses_notification.dart';
import '../../services/notification_service/courses_not_services.dart';
import '../../theme/theme.dart';
import '../../users.dart';
import 'courses_notifications_details.dart';

class NotificationsPage extends StatefulWidget {
  final AppUser appUser;
  final AppUser admin;
  const NotificationsPage({super.key, required this.appUser, required this.admin});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CoursesNotificationService _notificationService;
  List<CoursesNotification> _nonVues = [];
  List<CoursesNotification> _vues = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _notificationService = CoursesNotificationService();
    _loadNotifications();
  }



  Future<void> _loadNotifications() async {
    // Remplacez 'currentUserId' par l'ID de l'utilisateur actuellement connecté
    String currentUserId = widget.appUser.id;
    List<CoursesNotification> notifications =
    await _notificationService.getNotificationsForUser(currentUserId);

    setState(() {
      _nonVues = notifications.where((n) => (!n.estVue && (n.type == 1 || n.type == 3 || n.type == 4 || n.type == 33 || n.type == 11))).toList();
      _vues = notifications.where((n) => n.estVue).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: lightColorScheme.primary.withOpacity(1),
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(onPressed: (){
          Navigator.of(context).pop();
        }, icon: const Icon(Icons.arrow_back_ios, color: Colors.white,)),
        title: const Text("Notifications", style: TextStyle(color: Colors.white),),
        bottom: TabBar(
          controller: _tabController,
          indicatorPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 3,
          tabs:  const [
            Tab(child: Text("Non vues",style: TextStyle(color: Colors.white),),),
            Tab(child: Text("Vues",style: TextStyle(color: Colors.white),),),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationList(_nonVues),
          _buildNotificationList(_vues),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<CoursesNotification> notifications) {
    return notifications.isNotEmpty? ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        CoursesNotification notification = notifications[index];

        switch(notification.type){
          case 1:
            return notificationType1Builder(notification);
          case 3 :
            return notificationType3Builder(notification);
          case 4 :
            return notificationType4Builder(notification);
          case 33 :
            return notificationType33Builder(notification);
          case 11 :
            return notificationType11Builder(notification);
          case 5:
            return notificationType5Builder(notification);
          case 6:
            return notificationType6Builder(notification);
          case 66:
            return notificationType66Builder(notification);
        }
        return null;

      },
    ): const Center(child: Text("Aucune notification"),);
  }



  Widget notificationType5Builder(CoursesNotification notification){
    return Card(
      elevation: 10,
      child: ListTile(
        leading: const Icon(Icons.monetization_on, color: Colors.orange,size: 40,),
        trailing: const Icon(Icons.arrow_forward_ios),
        title: const Text("Un nouveau paiement est requis pour un de vos cours"),
        subtitle: Text("Envoyé le: ${DateFormat('dd MMM kk:mm').format(notification.dateEnvoi)}"),
        onTap: () {
          _notificationService.marquerCommeVue(notification.id);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AppUI(appUser: widget.appUser, index: 2,)),
          );
        },
      ),
    );
  }


  Widget notificationType6Builder(CoursesNotification notification){
    return Card(
      elevation: 10,
      child: ListTile(
        leading: const Icon(Icons.monetization_on, color: Colors.green,size: 40,),
        trailing: const Icon(Icons.arrow_forward_ios),
        title: const Text("Votre demande de paiement paiement a été approuvée"),
        subtitle: Text("Envoyé le: ${DateFormat('dd MMM kk:mm').format(notification.dateEnvoi)}"),
        onTap: () {
          _notificationService.marquerCommeVue(notification.id);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AppUI(appUser: widget.appUser, index: 2,)),
          );
        },
      ),
    );
  }

  Widget notificationType66Builder(CoursesNotification notification){
    return Card(
      elevation: 10,
      child: ListTile(
        leading: const Icon(Icons.monetization_on, color: Colors.red,size: 40,),
        trailing: const Icon(Icons.arrow_forward_ios),
        title: const Text("Votre demande de paiement paiement a été rejettée.\nVeuillez nous contacter pour plus de détails."),
        subtitle: Text("Envoyé le: ${DateFormat('dd MMM kk:mm').format(notification.dateEnvoi)}"),
        onTap: () {
          _notificationService.marquerCommeVue(notification.id);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AppUI(appUser: widget.appUser, index: 2,)),
          );
        },
      ),
    );
  }


  Widget notificationType1Builder(CoursesNotification notification){
    return Card(
      elevation: 10,
      child: ListTile(
        title: Text("Vous avez un nouvel offre de cours de maison en ${notification.matiere}"),
        subtitle: Text("Envoyé le: ${DateFormat('dd MMM kk:mm').format(notification.dateEnvoi)}"),
        onTap: () {
          _notificationService.marquerCommeVue(notification.id);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NotificationDetailsPage(type: 1,notification: notification, user : widget.appUser, admin: widget.admin,)),
          );
        },
      ),
    );
  }


  Widget notificationType3Builder(CoursesNotification notification){
    return Card(
      elevation: 10,
      child: ListTile(
        title: Text("Votre candidature pour le cours de maison en ${notification.matiere} à ${notification.adresse} est acceptée"),
        subtitle: Text("Envoyé le: ${DateFormat('dd MMM kk:mm').format(notification.dateEnvoi)}"),
        trailing: const Icon(Icons.check_box, color: Colors.green,),
        onTap: () {
          _notificationService.marquerCommeVue(notification.id);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NotificationDetailsPage(type: 3,notification: notification, user : widget.appUser, admin: widget.admin,)),
          );
        },
      ),
    );
  }


  Widget notificationType33Builder(CoursesNotification notification){
    return Card(
      elevation: 10,
      child: ListTile(
        title: Text("Votre candidature pour le cours de maison en ${notification.matiere} à ${notification.adresse} est rejetée"),
        subtitle: Text("Envoyé le: ${DateFormat('dd MMM kk:mm').format(notification.dateEnvoi)}"),
        trailing: const Icon(Icons.close, color: Colors.red,),
        onTap: () {
          _notificationService.marquerCommeVue(notification.id);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NotificationDetailsPage(type: 33,notification: notification, user : widget.appUser, admin: widget.admin,)),
          );
        },
      ),
    );
  }


  Widget notificationType11Builder(CoursesNotification notification){
    return Card(
      elevation: 10,
      child: ListTile(
        title: Text("Votre demande de cours de maison en ${notification.matiere} est rejetée"),
        subtitle: Text("Envoyé le: ${DateFormat('dd MMM kk:mm').format(notification.dateEnvoi)}"),
        trailing: const Icon(Icons.close, color: Colors.red,),
        onTap: () {
          _notificationService.marquerCommeVue(notification.id);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NotificationDetailsPage(type: 33,notification: notification, user : widget.appUser, admin: widget.admin,)),
          );
        },
      ),
    );
  }


  Widget notificationType4Builder(CoursesNotification notification){
    return Card(
      elevation: 10,
      child: ListTile(
        title: Text("Nous vous avons trouvé un enseignant qualifié avec un profil vérifié pour votre demande de cours de maison en ${notification.matiere}"),
        subtitle: Text("Envoyé le: ${DateFormat('dd MMM kk:mm').format(notification.dateEnvoi)}"),
        onTap: () {
          _notificationService.marquerCommeVue(notification.id);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NotificationDetailsPage(type: 4,notification: notification, user : widget.appUser, admin: widget.admin,)),
          );
        },
      ),
    );
  }
}

