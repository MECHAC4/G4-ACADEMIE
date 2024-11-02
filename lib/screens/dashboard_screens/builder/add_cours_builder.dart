import 'package:flutter/material.dart';
import 'package:g4_academie/courses_notification.dart';
import 'package:g4_academie/profil_class.dart';
import 'package:g4_academie/screens/dashboard_screens/builder/profil_dialog_builder.dart';
import 'package:g4_academie/services/cours_services.dart';
import 'package:g4_academie/services/notification_service/courses_not_services.dart';
import 'package:g4_academie/services/verification.dart';
import 'package:g4_academie/users.dart';

import '../../../app_UI.dart';
import '../../../theme/theme.dart';

class AddCourseDialog extends StatefulWidget {
  final AppUser appUser;
  final List<ProfilClass> profiles;
  final ProfilClass? selected;
  final String? matiere;
  final String? frequence;

  const AddCourseDialog(
      {super.key,
      this.frequence,
      this.matiere,
      required this.appUser,
      required this.profiles,
      this.selected});

  @override
  State<AddCourseDialog> createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends State<AddCourseDialog> {
  final _formKey = GlobalKey<FormState>();

  //String subject = '';
  String studentFullName = '';
  String studentID = '';
  String state = 'Actif';

  List<Map<String, String>> weekDuration = [];
  String? hoursPerWeek;
  bool isProgramFixed = true;

  // Controllers for week duration inputs
  final List<TextEditingController> _dayControllers = [TextEditingController()];
  final List<TextEditingController> _startHourControllers = [
    TextEditingController()
  ];
  final List<TextEditingController> _startMinuteControllers = [
    TextEditingController()
  ];
  final List<TextEditingController> _endHourControllers = [
    TextEditingController()
  ];
  final List<TextEditingController> _endMinuteControllers = [
    TextEditingController()
  ];

  @override
  void dispose() {
    // Dispose the controllers when the widget is disposed
    for (var controller in _dayControllers) {
      controller.dispose();
    }
    for (var controller in _startHourControllers) {
      controller.dispose();
    }
    for (var controller in _startMinuteControllers) {
      controller.dispose();
    }
    for (var controller in _endHourControllers) {
      controller.dispose();
    }
    for (var controller in _endMinuteControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _openSubjectsDialog(BuildContext context) async {
    final ans = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const SubjectsDialog();
      },
    );
    setState(() {
      matiere = ans.toString();
    });
    print("mitiere_selectionné: $matiere");
  }

  /*void _addWeekDurationField() {
    setState(() {
      _dayControllers.add(TextEditingController());
      _startHourControllers.add(TextEditingController());
      _startMinuteControllers.add(TextEditingController());
      _endHourControllers.add(TextEditingController());
      _endMinuteControllers.add(TextEditingController());
    });
  }*/
  late String uid;
  String? matiere;
  String frequence = "Cours hebdomadaires";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uid = widget.appUser.id;
    selectedProfile = widget.selected;
    if (widget.matiere != null) {
      matiere = widget.matiere;
    }
    if (widget.frequence != null) {
      frequence = widget.frequence!;
    }
    final lastProfile = widget.profiles.last;
    if (!(lastProfile.firstName == 'n' &&
        lastProfile.lastName == 'n' &&
        lastProfile.studentClass == '' &&
        lastProfile.adresse == '')) {
      widget.profiles.add(ProfilClass(
          id: '',
          firstName: 'n',
          lastName: 'n',
          studentClass: '',
          adresse: ''));
    }
  }

  /*void _clearFields() {
    for (var controller in _dayControllers) {
      controller.clear();
    }
    for (var controller in _startHourControllers) {
      controller.clear();
    }
    for (var controller in _startMinuteControllers) {
      controller.clear();
    }
    for (var controller in _endHourControllers) {
      controller.clear();
    }
    for (var controller in _endMinuteControllers) {
      controller.clear();
    }
  }*/

  ProfilClass? selectedProfile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: lightColorScheme.primary,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios_new, color: lightColorScheme.surface),
        ),
        title: Text(
          "Ajouter un cours",
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: lightColorScheme.surface),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(
                height: 10,
              ),
              if (widget.appUser.userType == "Parent d'élève")
                Container(
                  height: 65,
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedProfile == null
                            ? 'Aucun profil sélectionné'
                            : '  ${selectedProfile?.firstName} ${selectedProfile?.lastName}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      DropdownButton<ProfilClass>(
                        underline: const SizedBox(),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          //color: lightColorScheme.surface,
                        ),
                        hint: selectedProfile == null
                            ? Text(
                                'Choisir un profil',
                                style: TextStyle(
                                  color: lightColorScheme.primary,
                                ),
                              )
                            : null,
                        onChanged: (ProfilClass? newProfile) {
                          setState(() {
                            selectedProfile = newProfile;
                          });
                        },
                        items: widget.profiles.map((ProfilClass profile) {
                          return DropdownMenuItem<ProfilClass>(
                            value: profile,
                            child: profile.firstName != 'n' &&
                                    profile.lastName != 'n'
                                ? Text('  ${profile.firstName} ${profile.lastName}'
                                            .trim() ==
                                        '${widget.appUser.firstName} ${widget.appUser.lastName}'
                                    ? 'Profil principal'
                                    : '  ${profile.firstName} ${profile.lastName}')
                                : TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      showProfileDialog(
                                          context,
                                          uid,
                                          widget.appUser.address,
                                          widget.profiles,
                                          widget.appUser,
                                          frequence: frequence,
                                          isAnormal: true,
                                          matiere: matiere);
                                    },
                                    child: const Text("Nouveau profil")),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              const SizedBox(
                height: 10,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      items: const [
                        DropdownMenuItem(
                          value: "Cours hebdomadaires",
                          child: Text("Cours hebdomadaires"),
                        ),
                        DropdownMenuItem(
                          value: "Cours intensifs",
                          child: Text("Cours intensifs"),
                        )
                      ],
                      onChanged: (value) {
                        setState(() {
                          if (value != null) {
                            frequence = value;
                          }
                        });
                      },
                      value: frequence,
                      hint: const Text("Fréquence"),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    Container(
                        decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          title: Text(matiere == null
                              ? "Choisir une matière"
                              : matiere!),
                          onTap: () => _openSubjectsDialog(context),
                          trailing:
                              const Icon(Icons.keyboard_arrow_down_outlined),
                        )),
                    /*TextFormField(
                      decoration: InputDecoration(
                        labelText: "Matière",
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une matière';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        subject = value!;
                      },
                    ),*/
                    const SizedBox(
                      height: 25.0,
                    ),
                    /*SwitchListTile(
                      //dense: true,
                      visualDensity: VisualDensity.comfortable,
                      title: const Text("Définir le programme du cours"),
                      value: isProgramFixed,
                      onChanged: (bool value) {
                        setState(() {
                          isProgramFixed = value;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    if (isProgramFixed) ...[
                      for (int index = 0;
                          index < _dayControllers.length;
                          index++)
                        Column(
                          children: [
                            DropdownButtonFormField<String>(
                              value: _dayControllers[index].text.isEmpty
                                  ? null
                                  : _dayControllers[index].text,
                              items: [
                                'Lundi',
                                'Mardi',
                                'Mercredi',
                                'Jeudi',
                                'Vendredi',
                                'Samedi',
                                'Dimanche'
                              ]
                                  .map((day) => DropdownMenuItem(
                                        value: day,
                                        child: Text(day),
                                      ))
                                  .toList(),
                              decoration: InputDecoration(
                                labelText: "Jour",
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
                              onChanged: (value) {
                                setState(() {
                                  _dayControllers[index].text = value!;
                                });
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Divider(
                                    thickness: 0.7,
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 0,
                                    horizontal: 10,
                                  ),
                                  child: Text(
                                    'Heure du début',
                                    style: TextStyle(
                                      color: Colors.black45,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    thickness: 0.7,
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _startHourControllers[index]
                                            .text
                                            .isEmpty
                                        ? null
                                        : _startHourControllers[index].text,
                                    items: List.generate(
                                            24,
                                            (hour) =>
                                                hour.toString().padLeft(2, '0'))
                                        .map((hour) => DropdownMenuItem(
                                              value: hour,
                                              child: Text(hour),
                                            ))
                                        .toList(),
                                    decoration: InputDecoration(
                                      labelText: "Heure",
                                      border: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors
                                              .black12, // Default border color
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors
                                              .black12, // Default border color
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _startHourControllers[index].text =
                                            value!;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _startMinuteControllers[index]
                                            .text
                                            .isEmpty
                                        ? null
                                        : _startMinuteControllers[index].text,
                                    items: List.generate(
                                            60,
                                            (minute) => minute
                                                .toString()
                                                .padLeft(2, '0'))
                                        .map((minute) => DropdownMenuItem(
                                              value: minute,
                                              child: Text(minute),
                                            ))
                                        .toList(),
                                    decoration: InputDecoration(
                                      labelText: "Minute",
                                      border: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors
                                              .black12, // Default border color
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors
                                              .black12, // Default border color
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _startMinuteControllers[index].text =
                                            value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Divider(
                                    thickness: 0.7,
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 0,
                                    horizontal: 10,
                                  ),
                                  child: Text(
                                    'Heure de fin',
                                    style: TextStyle(
                                      color: Colors.black45,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    thickness: 0.7,
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value:
                                        _endHourControllers[index].text.isEmpty
                                            ? null
                                            : _endHourControllers[index].text,
                                    items: List.generate(
                                            24,
                                            (hour) =>
                                                hour.toString().padLeft(2, '0'))
                                        .map((hour) => DropdownMenuItem(
                                              value: hour,
                                              child: Text(hour),
                                            ))
                                        .toList(),
                                    decoration: InputDecoration(
                                      labelText: "Heure",
                                      border: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors
                                              .black12, // Default border color
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors
                                              .black12, // Default border color
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _endHourControllers[index].text =
                                            value!;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _endMinuteControllers[index]
                                            .text
                                            .isEmpty
                                        ? null
                                        : _endMinuteControllers[index].text,
                                    items: List.generate(
                                            60,
                                            (minute) => minute
                                                .toString()
                                                .padLeft(2, '0'))
                                        .map((minute) => DropdownMenuItem(
                                              value: minute,
                                              child: Text(minute),
                                            ))
                                        .toList(),
                                    decoration: InputDecoration(
                                      labelText: "Minute",
                                      border: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors
                                              .black12, // Default border color
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors
                                              .black12, // Default border color
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _endMinuteControllers[index].text =
                                            value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  if (_dayControllers[index].text.isNotEmpty &&
                                      _startHourControllers[index]
                                          .text
                                          .isNotEmpty &&
                                      _endHourControllers[index]
                                          .text
                                          .isNotEmpty &&
                                      _endMinuteControllers[index]
                                          .text
                                          .isNotEmpty) {
                                    weekDuration.add({
                                      'day': _dayControllers[index].text,
                                      'startTime':
                                          '${_startHourControllers[index].text}:${_startMinuteControllers[index].text}',
                                      'endTime':
                                          '${_endHourControllers[index].text}:${_endMinuteControllers[index].text}',
                                    });
                                    _clearFields();
                                  }
                                });
                              },
                              child: const Text("Ajouter au programme"),
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),
                      ExpansionTile(
                        title: const Text("Programme du cours"),
                        children: weekDuration
                            .map((schedule) => ListTile(
                                  trailing: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          weekDuration.removeAt(
                                              weekDuration.indexOf(schedule));
                                        });
                                      },
                                      icon: const Icon(Icons.delete)),
                                  title: Text(
                                      '${schedule['day']} de ${schedule['startTime']} à ${schedule['endTime']}'),
                                ))
                            .toList(),
                      ),
                    ] else ...[
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Nombre d'heures par semaine",
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le nombre d\'heures par semaine';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          hoursPerWeek = value;
                        },
                      ),
                    ],*/
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Annuler"),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (matiere != null && selectedProfile != null) {
                              //_formKey.currentState!.save();
                              // Collect weekDuration data if program is fixed
                              if ((widget.appUser.userType ==
                                          "Parent d'élève" &&
                                      selectedProfile != null) ||
                                  (widget.appUser.userType == "Elève")) {
                                /*if (hoursPerWeek == null) {
                                  setState(() {
                                    hoursPerWeek =
                                        '${calculateTotalHours(weekDuration)}';
                                  });
                                }*/
                                if (frequence == "Cours hebdomadaires") {
                                  hoursPerWeek = "4";
                                } else {
                                  hoursPerWeek = "6";
                                }
                                // Stocker les informations dans Firestore
                                String courseId =
                                    await CoursServices().saveCoursToFirestore({
                                  'adresse': widget.appUser.userType == "Elève"
                                      ? widget.appUser.address
                                      : selectedProfile!.adresse,
                                  'appUserId': uid,
                                  'profilId': widget.appUser.userType == "Elève"
                                      ? widget.appUser.id
                                      : selectedProfile!.id,
                                  'subject': matiere,
                                  'studentFullName': widget.appUser.userType ==
                                          "Elève"
                                      ? "${widget.appUser.firstName} ${widget.appUser.lastName}"
                                      : '${selectedProfile!.firstName} ${selectedProfile!.lastName}',
                                  'studentID':
                                      widget.appUser.userType == "Elève"
                                          ? widget.appUser.id
                                          : selectedProfile!.id,
                                  'state': "En cours de traitement",
                                  'weekDuration': weekDuration,
                                  'hoursPerWeek': hoursPerWeek,
                                });
                                CoursesNotificationService()
                                    .envoyerNotification(CoursesNotification(
                                        type: 0,
                                        id: '',
                                        coursePath: widget.appUser.userType ==
                                                "Elève"
                                            ? '${widget.appUser.id}/${widget.appUser.id}/$courseId'
                                            : '${widget.appUser.id}/${selectedProfile!.id}/$courseId',
                                        nom: widget.appUser.userType == "Elève"
                                            ? widget.appUser.firstName
                                            : selectedProfile!.firstName,
                                        prenom:
                                            widget.appUser.userType == "Elève"
                                                ? " ${widget.appUser.lastName}"
                                                : selectedProfile!.lastName,
                                        adresse:
                                            widget.appUser.userType == "Elève"
                                                ? widget.appUser.address
                                                : selectedProfile!.adresse,
                                        classe: widget.appUser.userType ==
                                                "Elève"
                                            ? '${widget.appUser.studentClass}'
                                            : selectedProfile!.studentClass,
                                        matiere: matiere!,
                                        nombreHeuresParSemaine: '$hoursPerWeek',
                                        emploiDuTemps: weekDuration,
                                        idFrom: widget.appUser.id,
                                        idTo: 'rY33iKsQgGew8akQ4ILyULwrYSt2',
                                        //'rY33iKsQgGew8akQ4ILyULwrYSt2',
                                        dateEnvoi: DateTime.now()));
                                Navigator.of(context).pop();
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      AppUI(appUser: widget.appUser, index: 0),
                                ));
                              }
                            } else if (matiere == null) {
                              showMessage(
                                  context, "Veillez choisir une matière");
                            } else {
                              showMessage(context,
                                  "Veillez choisir un profil ou créez en un");
                            }
                          },
                          child: const Text("Demander le cours"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

/*int calculateTotalHours(List<Map<String, String>> weekDuration) {
    int totalMinutes = 0;

    for (var schedule in weekDuration) {
      // Récupération de l'heure de début et de fin
      String startTime = schedule['startTime']!;
      String endTime = schedule['endTime']!;

      // Conversion des heures et minutes en valeurs entières
      int startHour = int.parse(startTime.split(':')[0]);
      int startMinute = int.parse(startTime.split(':')[1]);

      int endHour = int.parse(endTime.split(':')[0]);
      int endMinute = int.parse(endTime.split(':')[1]);

      // Calcul du nombre de minutes écoulées entre l'heure de début et de fin
      int startTotalMinutes = (startHour * 60) + startMinute;
      int endTotalMinutes = (endHour * 60) + endMinute;

      // Si l'heure de fin est avant l'heure de début (programme sur deux jours), ajuster la différence
      if (endTotalMinutes < startTotalMinutes) {
        endTotalMinutes += 24 * 60; // Ajouter 24 heures en minutes
      }

      // Additionner la différence au total
      totalMinutes += (endTotalMinutes - startTotalMinutes);
    }

    // Conversion des minutes totales en heures
    int totalHours = totalMinutes ~/ 60;
    return totalHours;
  }*/
}

class SubjectsDialog extends StatefulWidget {
  const SubjectsDialog({super.key});

  @override
  State<SubjectsDialog> createState() => _SubjectsDialogState();
}

class _SubjectsDialogState extends State<SubjectsDialog> {
  final Map<String, List<String>> subjects = {
    'Sciences': ['Maths', 'PCT', 'SVT'],
    'Sciences humaines': ['Histoire-géo', 'Philosophie'],
    'Langues': ['Allemand', 'Anglais', 'Espagnol', 'Français'],
    'Primaire': ['Aide aux devoirs'],
    //'Sports': ['Arts Martiaux', 'Athlétisme', 'Cyclisme', 'Danse', 'Fitness', 'Musculation', 'Yoga'],
    //'Musique': ['Guitare', 'Piano', 'Violon'],
    'Autres': ['Informatique'],
  };

  String searchQuery = '';
  List<String> filteredSubjects = [];

  @override
  void initState() {
    super.initState();
    _updateFilteredSubjects();
  }

  void _updateFilteredSubjects() {
    setState(() {
      filteredSubjects = [];
      subjects.forEach((category, items) {
        filteredSubjects.add(category);
        filteredSubjects.addAll(
          items.where((subject) =>
              subject.toLowerCase().contains(searchQuery.toLowerCase())),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choisissez une matière'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Rechercher',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                  _updateFilteredSubjects();
                });
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredSubjects.length,
                itemBuilder: (context, index) {
                  String item = filteredSubjects[index];
                  bool isCategory = subjects.containsKey(item);

                  if (isCategory) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        item,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent),
                      ),
                    );
                  }
                  return ListTile(
                    title: Text(item),
                    onTap: () {
                      Navigator.of(context)
                          .pop(item); // Retourne la matière sélectionnée
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context)
                .pop(); // Ferme la boîte de dialogue sans sélection
          },
          child: const Text('Annuler'),
        ),
      ],
    );
  }
}
