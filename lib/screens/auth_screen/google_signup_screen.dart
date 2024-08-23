import 'package:flutter/material.dart';
import 'package:g4_academie/app_UI.dart';
import 'package:g4_academie/constants.dart';
import 'package:g4_academie/screens/auth_screen/signin_screen.dart';
import 'package:g4_academie/services/auth_services.dart';

import '../../services/verification.dart';
import '../../theme/theme.dart';
import '../../users.dart';
import '../../widgets/custom_scaffold.dart';

class GoogleSignUp extends StatefulWidget {
  final String uid;

  const GoogleSignUp({super.key, required this.uid});

  @override
  State<GoogleSignUp> createState() => _GoogleSignUpState();
}

class _GoogleSignUpState extends State<GoogleSignUp> {
  final _formSignupKey = GlobalKey<FormState>();
  bool agreePersonalData = true;

  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController adresseController = TextEditingController();
  final TextEditingController studentClassController = TextEditingController();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery
        .of(context)
        .size
        .width;
    final double height = MediaQuery
        .of(context)
        .size
        .height;
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(
              height: 10,
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  width / 20, height / 30, width / 20, height / 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                // get started form
                child: Form(
                  key: _formSignupKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // get started text
                      Text(
                        'Pousuivre votre inscription sur $appName avec Google',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: height / 28,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      // full name
                      DefaultTabController(
                        length: 2,
                        initialIndex: 0,
                        animationDuration: const Duration(milliseconds: 300),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: nomController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Entrez votre nom';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                label: const Text('Nom'),
                                hintText: 'Entrer votre nom',
                                hintStyle: const TextStyle(
                                  color: Colors.black26,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color:
                                    Colors.black12, // Default border color
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color:
                                    Colors.black12, // Default border color
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 25.0,
                            ),
                            TextFormField(
                              controller: prenomController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Entrez votre/vos prénom(s)';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                label: const Text('Prénom(s)'),
                                hintText: 'Entrer votre/vos prénom(s)',
                                hintStyle: const TextStyle(
                                  color: Colors.black26,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color:
                                    Colors.black12, // Default border color
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color:
                                    Colors.black12, // Default border color
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 25.0,
                            ),
                            TextFormField(
                              controller: adresseController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Entrez votre adresse';
                                } else
                                if (!isValidAddress(adresseController.text)) {
                                  return "Format requis : ville ou village/Quartier";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                label: const Text('Adresse'),
                                hintText: 'Entrer votre adresse',
                                hintStyle: const TextStyle(
                                  color: Colors.black26,
                                ),
                                helperText:
                                "Format pour l'adresse : Ville ou Village/Quartier",
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color:
                                    Colors.black12, // Default border color
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color:
                                    Colors.black12, // Default border color
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 25.0,
                            ),
                            Container(
                              width: width,
                              padding: EdgeInsets.symmetric(
                                  vertical: height / 45,
                                  horizontal: width / 30),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.black12)),
                              child: DropdownButton(
                                underline: const SizedBox.shrink(),
                                isDense: true,
                                isExpanded: true,
                                value: _selectedUserType,
                                alignment: Alignment.centerLeft,
                                hint: const Text(
                                  "Type d'utilisateur",
                                  style: TextStyle(
                                    // color: Colors.black26,
                                  ),
                                ),
                                items: usersType.map((e) {
                                  return DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedUserType = value!;
                                  });
                                },
                              ),
                            ),
                            if (_selectedUserType == usersType[1])
                              const SizedBox(
                                height: 25.0,
                              ),
                            if (_selectedUserType == usersType[1])
                              Container(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                                width: width,
                                height: subject != [] && subject!.length < 2
                                    ? 60
                                    : 100,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black26),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                ),
                                child: GridView.builder(
                                  itemCount: subject!.length < 4
                                      ? subject!.length + 1
                                      : subject!.length,
                                  gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      childAspectRatio: 4,
                                      crossAxisCount: 2),
                                  itemBuilder: (context, index) {
                                    return index + 1 != subject!.length + 1
                                        ? Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${subject![index]}  ",
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            size: height / 45,
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              subject?.removeAt(index);
                                            });
                                          },
                                        ),
                                      ],
                                    )
                                        : TextButton(
                                        onPressed: () {
                                          setState(() {
                                            addSubject(context);
                                          });
                                        },
                                        child: const Text(
                                            "Ajouter une matière"));
                                  },
                                ),
                              ),
                            if(_selectedUserType == usersType[0])
                              const SizedBox(
                                height: 25,
                              ),
                            if(_selectedUserType == usersType[0])
                              TextFormField(
                                controller: studentClassController,
                                validator: (value) {
                                  if (_selectedUserType == usersType[0] && (value == null || value.isEmpty)) {
                                    return 'Entrez votre classe';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  label: const Text('Classe'),
                                  hintText: 'Entrer votre classe',
                                  hintStyle: const TextStyle(
                                    color: Colors.black26,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color:
                                      Colors.black12, // Default border color
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color:
                                      Colors.black12, // Default border color
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),









                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),


                      // i agree to the processing
                      Row(
                        children: [
                          Checkbox(
                            value: agreePersonalData,
                            onChanged: (bool? value) {
                              setState(() {
                                agreePersonalData = value!;
                              });
                            },
                            activeColor: lightColorScheme.primary,
                          ),
                          const Text(
                            'J\' la collecte de ',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          Text(
                            'Données personnelles',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: lightColorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // signup button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formSignupKey.currentState!.validate() &&
                                agreePersonalData) {
                              showMessage(context, "Traitement des données");
                              _appUser = await AuthService().registerWithPhone(
                                  context,
                                  widget.uid,
                                  "GOOGLE_USER",
                                  "GOOGLE_USER",
                                  nomController.text,
                                  prenomController.text,
                                  adresseController.text,
                                  _selectedUserType!,
                                  subject: subject,
                                studentClass: studentClassController.text,
                              );
                              _appUser != null ? Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) =>
                                      AppUI(appUser: _appUser!),)): showMessage(context, "Une erreur s'est produite.\nVeillez reessayer");
                            } else if (!agreePersonalData) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Veillez accepter la collecte de donnée personnelle')),
                              );
                            }
                          },
                          child: const Text('S\'inscrire'),
                        ),
                      ),

                      const SizedBox(
                        height: 25.0,
                      ),
                      // already have an account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Avez-vous déjà un compte ?',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => const SignInScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Se connecter',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> usersType = ["Elève", "Enseignant", "Parent d'élève"];
  String? _selectedUserType;
  List<String>? subject = [];
  final TextEditingController subjectController = TextEditingController();

  void addSubject(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height / 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: subjectController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veillez entrer une matière';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    label: const Text('Matière'),
                    hintText: 'Entrez une matière',
                    hintStyle: const TextStyle(
                      color: Colors.black26,
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Annuler")),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            subject?.add(subjectController.text);
                            subjectController.clear();
                          });
                        },
                        child: const Text("Ajouter"))
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  AppUser? _appUser;
}
