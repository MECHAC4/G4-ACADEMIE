import 'package:flutter/material.dart';
import 'package:g4_academie/screens/chat/chat.dart';
import 'package:g4_academie/screens/dashboard_screens/home_screnn.dart';
import 'package:g4_academie/screens/payment/payment.dart';
import 'package:g4_academie/screens/profil/profil.dart';
import 'package:g4_academie/theme/theme.dart';

class AppUI extends StatefulWidget {
  const AppUI({super.key});

  @override
  State<AppUI> createState() => _AppUIState();
}

class _AppUIState extends State<AppUI> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
        const DashboardPage(),
        const ChatScreen(),
        const PaymentScreen(),
        const ProfileScreen(),
      ][_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: "Tableau de bord"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Discussions"),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Payement"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
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