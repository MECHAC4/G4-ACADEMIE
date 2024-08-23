import 'package:flutter/material.dart';
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
      _nonVues = notifications.where((n) => !n.estVue).toList();
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
        }
        return null;

      },
    ): const Center(child: Text("Aucune notification"),);
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
        title: Text("Votre candidature pour le cours de maison en ${notification.matiere} à ${notification.adresse} est rejeté/Accepté"),
        subtitle: Text("Envoyé le: ${DateFormat('dd MMM kk:mm').format(notification.dateEnvoi)}"),
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

