import 'package:flutter/material.dart';
import 'package:g4_academie/screens/chat/chat_screen.dart';

import 'package:g4_academie/screens/dashboard_screens/home_screnn.dart';
//import 'package:g4_academie/screens/demandes/demande.dart';
import 'package:g4_academie/screens/payment/payment_manager_screen.dart';
import 'package:g4_academie/screens/payment/teacher_payment_manager.dart';
import 'package:g4_academie/screens/profil/profil.dart';
import 'package:g4_academie/screens/school_mouv/school_screen.dart';

import 'package:g4_academie/services/message_service/chat_params.dart';
import 'package:g4_academie/services/message_service/message_database.dart';
import 'package:g4_academie/services/notification_service/courses_not_services.dart';
import 'package:g4_academie/services/push_notification_service/push_not.dart';
import 'package:g4_academie/theme/theme.dart';
import 'package:g4_academie/users.dart';
import 'package:g4_academie/widgets/icon_with_badge.dart';

class AppUI extends StatefulWidget {
  final AppUser appUser;
  final int? index;

  const AppUI({super.key, required this.appUser, this.index});

  @override
  State<AppUI> createState() => _AppUIState();
}

class _AppUIState extends State<AppUI> {
  int _currentIndex = 0;
  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    admin = AppUser(
        id: 'rY33iKsQgGew8akQ4ILyULwrYSt2',
        firstName: 'admin',
        lastName: 'admin',
        address: 'admin',
        userType: 'admin',
        emailOrPhone: 'a',
        password: 'a');
    if (widget.index != null) {
      _currentIndex = widget.index!;
    }
    setState(() {
    });
  }

  late AppUser admin;

  @override
  Widget build(BuildContext context) {
    PushNotificationService.initialize();
    return Scaffold(
      drawer: Drawer(
        child: ProfileScreen(appUser: widget.appUser),
      ),
      body: Stack(children:[
        [
        DashboardPage(
          appUser: widget.appUser,
          admin: admin,
        ),
        ChatScreen(
          chatParams: ChatParams(widget.appUser.id, admin),
        ),
         widget.appUser.userType == 'Enseignant' ? TeacherPaymentManager(appUser: widget.appUser,):PaymentManagerScreen(appUser: widget.appUser,),
        //const PaymentScreen(),
        //DemandePage(appUser: widget.appUser,admin: admin),
          //CoursPage()
          HomePage2()
      ][_currentIndex],
        Padding(
          padding: const EdgeInsets.only(top: 35.0),
          child: Align(
            alignment: Alignment.topLeft,
            //top: 10, // Positionne selon ton design
            //left: 10, // Positionne selon ton design
            child: Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white,), // Icône du Drawer
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              }
            ),
          ),
        ),]),
      bottomNavigationBar: BottomNavigationBar(
        items:  [
          BottomNavigationBarItem(
              icon: StreamBuilder(stream: CoursesNotificationService().getNotificationsForUser(widget.appUser.id).asStream(), builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting){
                  return const Icon(Icons.dashboard, size: 25,);
                }else{
                  if (snapshot.data == null || snapshot.data!.isEmpty){
                    return const Icon(Icons.dashboard, size: 25,);
                  }
                }
                return IconWithBadge(icon: Icons.dashboard, badgeCount: snapshot.data!.where((element) => element.estVue == false,).toList().length, iconSize: 25,);

              },)/*Icon(Icons.dashboard)*/, label: "Tableau de bord"),
          BottomNavigationBarItem(icon: StreamBuilder(stream: MessageDatabaseService().getMessage(ChatParams(widget.appUser.id, admin).getChatGroupId(), 20), builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting){
              return const Icon(Icons.chat, size: 25,);
            }else
              if(snapshot.data == null || snapshot.data!.isEmpty || snapshot.data!.first.idFrom == widget.appUser.id){
                return const Icon(Icons.chat, size: 25,);
              }
              int n = 0;
              for (int i=0; i<snapshot.data!.length; i++){
                if(!(snapshot.data![i].idFrom == widget.appUser.id)){
                  n = n+1;
                }else{
                  break;
                }
              }
              return  IconWithBadge(icon: Icons.chat, badgeCount: n, iconSize: 25,);
          },),
            label: "Discussions",),
          const BottomNavigationBarItem(icon: IconWithBadge(icon: Icons.payment, badgeCount: 1, iconSize: 26,), label: "Payement"),
          const BottomNavigationBarItem(icon: Icon(Icons.assignment_late, size: 25,), label: "Demandes"),
        ],
        onTap: (value) => setState(() {
          _currentIndex = value;
        }),
        currentIndex: _currentIndex,
        selectedItemColor: lightColorScheme.primary,
        type: BottomNavigationBarType.shifting,
        unselectedItemColor: lightColorScheme.tertiary,
      ),
    );
  }
}
