import 'package:flutter/material.dart';
import 'package:g4_academie/app_UI.dart';
import 'package:g4_academie/screens/dashboard_screens/builder/add_cours_builder.dart';
import 'package:g4_academie/services/verification.dart';
import 'package:g4_academie/users.dart';

import '../../../constants.dart';
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
    List<ProfilClass> profiles, AppUser appUser,
    {bool isAnormal = false, String? frequence, String? matiere}) async {
  if (profiles.isEmpty) {
    profiles = await ProfilServices().fetchProfiles(uid);
  }
  final formKey = GlobalKey<FormState>();
  bool isDelayed = false;
  String firstName1 = '';
  String lastName1 = '';
  String studentClass1 = '';

  showDialog(
    context: context,
    builder: (BuildContext context) {
      //bool isGroup = false;
      String firstName = '';
      String lastName = '';
      String? studentClass;

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
                          Text(
                            isAnormal
                                ? "Informations sur l'élève"
                                : 'Créer un profil',
                            style: const TextStyle(
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
                                  return "Entrez un  nom";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                  labelText: 'Nom de l\'élève',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              onChanged: (value) {
                                lastName = value;
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                  labelText: 'Prénom de l\'élève',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10))),
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
                            const SizedBox(
                              height: 20,
                            ),
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Sélectionner une classe',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              //hint: const Text("Sélectionner une classe"),
                              value: studentClass,
                              onChanged: (String? newValue) {
                                setState(() {
                                  if (newValue != null) {
                                    studentClass = newValue;
                                  }
                                });
                              },
                              items: classes.map((String className) {
                                return DropdownMenuItem<String>(
                                  value: className,
                                  child: Text(className),
                                );
                              }).toList(),
                            ),

                            /*TextFormField(
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
                            ),*/
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
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate() && studentClass!=null) {
                              if (!verifyExistentProfile(
                                  profiles, firstName, lastName)) {
                                firstName1 = firstName;
                                lastName1 = lastName;
                                studentClass1 = studentClass!;
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
                                if (!isAnormal) {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => AppUI(
                                      appUser: appUser,
                                      index: 0,
                                    ),
                                  ));
                                }else{
                                  final pro = ProfilClass(id: '', firstName: firstName1, lastName: lastName1, studentClass: studentClass1, adresse: adresse);
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddCourseDialog(appUser: appUser, profiles: profiles,frequence: frequence,matiere: matiere,selected: pro,),));
                                }
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
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(isAnormal ? "Demander le cours" : 'Créer'),
                        ),
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
