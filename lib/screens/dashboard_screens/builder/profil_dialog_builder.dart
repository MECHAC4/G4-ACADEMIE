

import 'package:flutter/material.dart';

import '../../../services/profil_services.dart';

void showProfileDialog(BuildContext context, String uid, String adresse) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      bool isGroup = false;
      String firstName = '';
      String lastName = '';
      String groupName = '';
      String studentClass = '';
      String studentCount = '';

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
                      SwitchListTile(
                        title: const Text('Créer un groupe'),
                        value: isGroup,
                        onChanged: (bool value) {
                          setState(() {
                            isGroup = value;
                          });
                        },
                      ),
                      if (!isGroup) ...[
                        TextField(
                          decoration: const InputDecoration(labelText: 'Prénom'),
                          onChanged: (value) {
                            firstName = value;
                          },
                        ),
                        TextField(
                          decoration: const InputDecoration(labelText: 'Nom'),
                          onChanged: (value) {
                            lastName = value;
                          },
                        ),
                        TextField(
                          decoration: const InputDecoration(labelText: 'Classe'),
                          onChanged: (value) {
                            studentClass = value;
                          },
                        ),
                      ] else ...[
                        TextField(
                          decoration: const InputDecoration(labelText: 'Nom du groupe'),
                          onChanged: (value) {
                            groupName = value;
                          },
                        ),
                        TextField(
                          decoration: const InputDecoration(labelText: 'Nombre maximum de personnes'),
                          onChanged: (value) {
                            studentCount = value;
                          },
                        ),
                      ],
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          ProfilServices().saveProfileToFirestore({
                            "isGroup": isGroup,
                            "firstName": isGroup ? null : firstName,
                            "lastName": isGroup ? null : lastName,
                            "groupName": isGroup ? groupName : null,
                            "studentClass": studentClass,
                            "studentCount": isGroup ? studentCount : null,
                            "adresse": adresse,
                          },uid);
                          Navigator.of(context).pop();
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
                        child: const Text('Enregistrer'),
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