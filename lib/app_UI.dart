import 'package:flutter/material.dart';
import 'package:g4_academie/screens/chat/chat_screen.dart';

import 'package:g4_academie/screens/dashboard_screens/home_screnn.dart';
import 'package:g4_academie/screens/demandes/demande.dart';
import 'package:g4_academie/screens/payment/payment_manager_screen.dart';
import 'package:g4_academie/screens/payment/teacher_payment_manager.dart';
import 'package:g4_academie/screens/profil/profil.dart';

import 'package:g4_academie/services/message_service/chat_params.dart';
import 'package:g4_academie/services/push_notification_service/push_not.dart';
import 'package:g4_academie/theme/theme.dart';
import 'package:g4_academie/users.dart';

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
      endDrawer: Drawer(
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
        DemandePage(appUser: widget.appUser,admin: admin),
      ][_currentIndex],
        Padding(
          padding: const EdgeInsets.only(top: 35.0),
          child: Align(
            alignment: Alignment.topRight,
            //top: 10, // Positionne selon ton design
            //left: 10, // Positionne selon ton design
            child: Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white,), // Icône du Drawer
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                );
              }
            ),
          ),
        ),]),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: "Tableau de bord"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Discussions"),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Payement"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_late), label: "Demandes"),
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
