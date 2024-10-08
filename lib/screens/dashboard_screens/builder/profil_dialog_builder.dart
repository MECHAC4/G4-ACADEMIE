import 'package:flutter/material.dart';
import 'package:g4_academie/app_UI.dart';
import 'package:g4_academie/services/verification.dart';
import 'package:g4_academie/users.dart';

import '../../../profil_class.dart';
import '../../../services/profil_services.dart';

bool verifyExistentProfile(
    List<ProfilClass> profiles, String firstName, String lastName) {
  bool isExist = false;

  for (int i = 0; i < profiles.length; i++) {
    ProfilClass profil = profiles[i];
    if (profil.firstName.trim() == firstName.trim() &&
        profil.lastName.trim() == lastName.trim()) {
      isExist = true;
      break;
    } else if (profil.firstName.trim() == lastName.trim() &&
        profil.lastName.trim() == firstName.trim()) {
      isExist = true;
      break;
    }
  }

  return isExist;
}

void showProfileDialog(BuildContext context, String uid, String adresse,
    List<ProfilClass> profiles, AppUser appUser) async {
  if (profiles.isEmpty) {
    profiles = await ProfilServices().fetchProfiles(uid);
  }
  final formKey = GlobalKey<FormState>();
  bool isDelayed = false;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      //bool isGroup = false;
      String firstName = '';
      String lastName = '';
      String studentClass = '';

      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Créer un profil',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                      /*SwitchListTile(
                        title: const Text('Créer un groupe'),
                        value: isGroup,
                        onChanged: (bool value) {
                          setState(() {
                            isGroup = value;
                          });
                        },
                      ),*/
                      /*if (!isGroup) ...[*/

                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Entrez un nom";
                                }
                                return null;
                              },
                              decoration:
                              const InputDecoration(labelText: 'Nom'),
                              onChanged: (value) {
                                lastName = value;
                              },
                            ),
                            TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'Prénom'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Entrez un prénom";
                                }
                                return null;
                              },
                              onChanged: (value) {
                                firstName = value;
                              },
                            ),

                            TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Entrez une classe";
                                }
                                return null;
                              },
                              decoration:
                                  const InputDecoration(labelText: 'Classe'),
                              onChanged: (value) {
                                studentClass = value;
                              },
                            ),
                          ],
                        ),
                      ),
                      /* ] else ...[
                        TextField(
                          decoration: const InputDecoration(labelText: 'Nom du groupe'),
                          onChanged: (value) {
                          },
                        ),
                        TextField(
                          decoration: const InputDecoration(labelText: 'Nombre maximum de personnes'),
                          onChanged: (value) {
                          },
                        ),
                      ],*/
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            if (!verifyExistentProfile(
                                profiles, firstName, lastName)) {
                              await ProfilServices().saveProfileToFirestore({
                                //"isGroup": isGroup,
                                "firstName": firstName,
                                "lastName": lastName,
                                // "groupName": isGroup ? groupName : null,
                                "studentClass": studentClass,
                                //"studentCount": isGroup ? studentCount : null,
                                "adresse": adresse,
                              }, uid);
                              setState(() {
                                isDelayed = true;
                              });
                              Future.delayed(const Duration(seconds: 5));
                              Navigator.of(context).pop();
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => AppUI(appUser: appUser,index: 0,),));
                            } else {
                              showMessage(context,
                                  "Vous avez déjà un profil ayant le même nom");
                            }
                          } else {
                            showMessage(
                                context, "Veuillez bien remplir les champs");
                          }
                          /*ProfilClass profil = ProfilClass(
                            isGroup: isGroup,
                            firstName: isGroup ? null : firstName,
                            lastName: isGroup ? null : lastName,
                            groupName: isGroup ? groupName : null,
                            studentClass: studentClass,
                            studentCount: isGroup ? studentCount : null,
                            adresse: adresse,
                          );*/
                        },
                        child: isDelayed
                            ? const CircularProgressIndicator(color: Colors.white,)
                            : const Text('Enregistrer'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
