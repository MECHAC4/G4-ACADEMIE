import 'package:flutter/material.dart';
import 'package:g4_academie/users.dart';

import '../screens/dashboard_screens/builder/profil_dialog_builder.dart';

class CustomScaffold extends StatelessWidget {
  final bool? buttonExist;
  final AppUser? appUser;

  const CustomScaffold(
      {super.key, this.child, this.buttonExist, this.appUser});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        //leading: IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_ios)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Image.asset(
            'lib/Assets/bg1.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(
            bottom: false,
            minimum: const EdgeInsets.only(bottom: 0),
            child: child!,
          ),
        ],
      ),
      floatingActionButton: (buttonExist != null && buttonExist!)
          ? FloatingActionButton(
              onPressed: () {
                if(appUser?.userType == "Parent d'élève"){
                  showProfileDialog(context, appUser!.id, appUser!.address);
                }
              },
              child: Text(
                appUser?.userType == "Parent d'élève"
                    ? "Créer un profil"
                    : "Créer un groupe",
                textAlign: TextAlign.center,
              ) /*const Icon(Icons.add),*/)
          : null,
    );
  }
}
