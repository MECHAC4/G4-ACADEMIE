import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:g4_academie/constants.dart';
import 'package:g4_academie/screens/auth_screen/signin_screen.dart';
import 'package:g4_academie/screens/auth_screen/signup_screen.dart';
import 'package:g4_academie/theme/theme.dart';

import '../../widgets/custom_scaffold.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
              flex: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 40.0,
                ),
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: 'Bienvenue sur $appName!\n',
                            style: const TextStyle(
                              fontSize: 45.0,
                              fontWeight: FontWeight.w600,
                            )),
                        const TextSpan(
                            text:
                                '\nEntrer vos informations personnelles pour créer un compte ou se connecter',
                            style: TextStyle(
                              fontSize: 20,
                              // height: 0,
                            ))
                      ],
                    ),
                  ),
                ),
              )),
          Flexible(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              //alignment: Alignment.bottomRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                      onPressed: () =>
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const SignInScreen(),
                          )),
                      child: Row(
                        children: [
                         Text("Se connecter",
                            style: TextStyle(
                                color: lightColorScheme.primary.accent)),
                         Icon(
                          Icons.arrow_forward_ios_outlined,
                          color: lightColorScheme.primary.accent,
                        ),
                        ]
                      )),
                  TextButton(
                      onPressed: () =>
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const SignUpScreen(),
                          )),
                      child: Row(
                        children:[
                         Text("S'inscrire",
                            style: TextStyle(
                                color: lightColorScheme.primary.accent)),
                         Icon(
                          Icons.arrow_forward_ios_outlined,
                          color: lightColorScheme.primary.accent,
                        ),]
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
