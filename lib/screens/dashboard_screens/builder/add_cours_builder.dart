
import 'package:flutter/material.dart';
import 'package:g4_academie/profil_class.dart';
import 'package:g4_academie/services/cours_services.dart';
import 'package:g4_academie/services/verification.dart';

import '../../../theme/theme.dart';

class AddCourseDialog extends StatefulWidget {
  final String userId;
  final List<ProfilClass> profiles;

  const AddCourseDialog({super.key, required this.userId, required this.profiles});

  @override
  State<AddCourseDialog> createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends State<AddCourseDialog> {
  final _formKey = GlobalKey<FormState>();

  String subject = '';
  String studentFullName = '';
  String studentID = '';
  String state = 'Actif';

  List<Map<String, String>> weekDuration = [];
  String? hoursPerWeek;
  bool isProgramFixed = true;

  // Controllers for week duration inputs
  final List<TextEditingController> _dayControllers = [TextEditingController()];
  final List<TextEditingController> _startHourControllers = [TextEditingController()];
  final List<TextEditingController> _startMinuteControllers = [TextEditingController()];
  final List<TextEditingController> _endHourControllers = [TextEditingController()];
  final List<TextEditingController> _endMinuteControllers = [TextEditingController()];

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

  /*void _addWeekDurationField() {
    setState(() {
      _dayControllers.add(TextEditingController());
      _startHourControllers.add(TextEditingController());
      _startMinuteControllers.add(TextEditingController());
      _endHourControllers.add(TextEditingController());
      _endMinuteControllers.add(TextEditingController());
    });
  }*/

  void _clearFields() {
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
  }

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
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: lightColorScheme.surface),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 10,),
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
                          : selectedProfile!.isGroup
                          ? '${selectedProfile?.groupName}'
                          : '${selectedProfile?.firstName} ${selectedProfile?.lastName}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<ProfilClass>(
                      underline: const SizedBox(),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        //color: lightColorScheme.surface,
                      ),
                      hint: Text(
                        'Choisir un profil',
                        style: TextStyle(
                          color: lightColorScheme.primary,
                        ),
                      ),
                      onChanged: (ProfilClass? newProfile) {
                        setState(() {
                          selectedProfile = newProfile;
                        });
                      },
                      items: widget.profiles.map((ProfilClass profile) {
                        return DropdownMenuItem<ProfilClass>(
                          value: profile,
                          child: Text(profile.isGroup
                              ? profile.groupName ?? 'Groupe'
                              : profile.firstName ?? 'Individuel'),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10,),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Matière",
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une matière';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        subject = value!;
                      },
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    SwitchListTile(
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
                      for (int index = 0; index < _dayControllers.length; index++)
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
                                    value: _startHourControllers[index].text.isEmpty
                                        ? null
                                        : _startHourControllers[index].text,
                                    items: List.generate(24, (hour) => hour.toString().padLeft(2, '0'))
                                        .map((hour) => DropdownMenuItem(
                                      value: hour,
                                      child: Text(hour),
                                    ))
                                        .toList(),
                                    decoration: InputDecoration(
                                      labelText: "Heure",
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
                                        _startHourControllers[index].text = value!;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _startMinuteControllers[index].text.isEmpty
                                        ? null
                                        : _startMinuteControllers[index].text,
                                    items: List.generate(60, (minute) => minute.toString().padLeft(2, '0'))
                                        .map((minute) => DropdownMenuItem(
                                      value: minute,
                                      child: Text(minute),
                                    ))
                                        .toList(),
                                    decoration: InputDecoration(
                                      labelText: "Minute",
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
                                        _startMinuteControllers[index].text = value!;
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
                                    value: _endHourControllers[index].text.isEmpty
                                        ? null
                                        : _endHourControllers[index].text,
                                    items: List.generate(24, (hour) => hour.toString().padLeft(2, '0'))
                                        .map((hour) => DropdownMenuItem(
                                      value: hour,
                                      child: Text(hour),
                                    ))
                                        .toList(),
                                    decoration: InputDecoration(
                                      labelText: "Heure",
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
                                        _endHourControllers[index].text = value!;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _endMinuteControllers[index].text.isEmpty
                                        ? null
                                        : _endMinuteControllers[index].text,
                                    items: List.generate(60, (minute) => minute.toString().padLeft(2, '0'))
                                        .map((minute) => DropdownMenuItem(
                                      value: minute,
                                      child: Text(minute),
                                    ))
                                        .toList(),
                                    decoration: InputDecoration(
                                      labelText: "Minute",
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
                                        _endMinuteControllers[index].text = value!;
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
                                  weekDuration.add({
                                    'day': _dayControllers[index].text,
                                    'startTime':
                                    '${_startHourControllers[index].text}:${_startMinuteControllers[index].text}',
                                    'endTime':
                                    '${_endHourControllers[index].text}:${_endMinuteControllers[index].text}',
                                  });
                                  _clearFields();
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
                          trailing: IconButton(onPressed: (){
                            setState(() {
                              weekDuration.removeAt(weekDuration.indexOf(schedule));
                            });
                          }, icon: const Icon(Icons.delete)),
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
                    ],
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
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();

                              // Collect weekDuration data if program is fixed
                              if (selectedProfile != null) {
                                // Stocker les informations dans Firestore
                                CoursServices().saveCoursToFirestore({
                                  'adresse': selectedProfile!.adresse,
                                  'appUserId': widget.userId,
                                  'profilId': selectedProfile!.id,
                                  'subject': subject,
                                  'studentFullName': selectedProfile!.isGroup
                                      ? selectedProfile!.groupName
                                      : '${selectedProfile!.firstName} ${selectedProfile!.lastName}',
                                  'studentID': selectedProfile!.id,
                                  'state': "Demande",
                                  'weekDuration': weekDuration,
                                  'hoursPerWeek': hoursPerWeek,
                                });
                                Navigator.of(context).pop();
                              } else {
                                showMessage(context, "Veillez choisir un profil ou créez en un");
                              }
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
}

