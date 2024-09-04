import 'package:calendar_view/calendar_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:g4_academie/profil_class.dart';
import 'package:g4_academie/theme/theme.dart';

import '../../../cours.dart';
import '../../../users.dart';





class WeekProgramBuilder extends StatefulWidget {
  //final List<List<Map<String, String>>> weekDurations; // Liste des weekDurations pour chaque cours
  //final List<Color> courseColors; // Liste des couleurs pour chaque cours
  final ProfilClass? profil;
  final AppUser appUser;
  const WeekProgramBuilder({
    super.key,
    required this.profil,
    required this.appUser,
    //required this.weekDurations,
    //required this.courseColors,
  });

  @override
  State<WeekProgramBuilder> createState() => _WeekProgramBuilderState();
}

class _WeekProgramBuilderState extends State<WeekProgramBuilder> {
  final EventController _eventController = EventController();

  @override
  void initState() {
    super.initState();
    //_loadCourses();
    _loadWeekEvents();

  }





  List<Cours> coursList = [];







  Future<List<Cours>> _updateCoursesList() async {
    List<Cours> allCourses = [];

    if (widget.profil == null) {
      // Récupérer tous les profils
      var profilSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.appUser.id)
          .collection('profil')
          .get();

      List<DocumentSnapshot> profiles = profilSnapshot.docs;

      // Parcourir chaque profil pour récupérer les cours associés
      for (var profile in profiles) {
        var coursesSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.appUser.id)
            .collection('profil')
            .doc(profile.id)
            .collection('courses')
            .get();

        // Ajouter tous les cours à la liste allCourses
        allCourses.addAll(coursesSnapshot.docs.map((doc) => Cours.fromMap(doc.data())).toList());
      }
    } else {
      // Récupérer uniquement les cours pour le profil sélectionné
      var coursesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.appUser.id)
          .collection('profil')
          .doc(widget.profil!.id)
          .collection('courses')
          .get();

      allCourses = coursesSnapshot.docs.map((doc) => Cours.fromMap(doc.data())).toList();
    }

    print("***********************\n\n**************************source taille: ${allCourses.length}");

    return allCourses;
  }



  List<Cours> coursFiltre = [];

  void _loadWeekEvents() async {
    coursList = await _updateCoursesList();
    List<List<Map<String, dynamic>>> weekDurations = [];

    // Filtrage des cours actifs et avec des weekDurations définis
    for (int i = 0; i < coursList.length; i++) {
      if ((coursList[i].state == 'Traité' || coursList[i].state == 'Actif') && coursList[i].weekDuration != null && coursList[i].weekDuration!.isNotEmpty) {
        weekDurations.add(coursList[i].weekDuration!.cast<Map<String, dynamic>>());
       coursFiltre.add(coursList[i]);
      }
    }

    // Génération des couleurs pour les cours
    List<Color> courseColors = List.generate(weekDurations.length, (index) {
      switch (index % 5) {
        case 0:
          return Colors.blue;
        case 1:
          return Colors.green;
        case 2:
          return Colors.brown;
        case 3:
          return Colors.yellowAccent;
        default:
          return Colors.orange;
      }
    }).toList();

    // Remplissage du calendrier avec les événements
    for (int i = 0; i < weekDurations.length; i++) {
      var courseWeekDuration = weekDurations[i];
      Color courseColor = courseColors[i];

      for (var schedule in courseWeekDuration) {
        final dayIndex = _getDayIndex(schedule['day']!); // Obtenir l'index du jour
        final startTimeOfDay = _getTime(schedule['startTime']!);
        final endTimeOfDay = _getTime(schedule['endTime']!);

        // Trouver le prochain jour correspondant au jour de la semaine (ex. : prochain lundi, mardi, etc.)
        DateTime currentWeekDay = _findNextWeekday(dayIndex);

        // Convertir les heures de début et de fin en DateTime
        final startTime = _convertTimeOfDayToDateTime(startTimeOfDay, currentWeekDay);
        final endTime = _convertTimeOfDayToDateTime(endTimeOfDay, currentWeekDay);

        // Ajouter l'événement au contrôleur des événements
        Cours cours = coursFiltre[weekDurations.indexOf(courseWeekDuration)];
        _eventController.add(
          CalendarEventData(
            titleStyle: const TextStyle(fontSize: 10,color: Colors.white,),

            date: currentWeekDay,
            startTime: startTime,
            endTime: endTime,
            title: cours.subject,
            //description: "Cours de l'élève",
            event: "Cours",
            color: courseColor,
          ),
        );
      }
    }
  }

  DateTime _findNextWeekday(int weekdayIndex) {
    DateTime now = DateTime.now();
    int currentWeekday = now.weekday;

    // Si le jour de l'événement est dans le futur cette semaine, calcule la différence
    if (weekdayIndex >= currentWeekday) {
      return now.add(Duration(days: weekdayIndex - currentWeekday));
    } else {
      // Si le jour est dans le passé, calcule la date pour la semaine prochaine
      return now.add(Duration(days: 7 - (currentWeekday - weekdayIndex)));
    }
  }

  int _getDayIndex(String day) {
    // Convertir le nom du jour en index (Lun -> 1, Mar -> 2, etc.)
    switch (day) {
      case 'Lundi':
        return 1;
      case 'Mardi':
        return 2;
      case 'Mercredi':
        return 3;
      case 'Jeudi':
        return 4;
      case 'Vendredi':
        return 5;
      case 'Samedi':
        return 6;
      case 'Dimanche':
        return 7;
      default:
        return 1; // Valeur par défaut
    }
  }

  TimeOfDay _getTime(String time) {
    // Convertir une chaîne 'HH:mm' en TimeOfDay
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  DateTime _convertTimeOfDayToDateTime(TimeOfDay timeOfDay, DateTime date) {
    return DateTime(date.year, date.month, date.day, timeOfDay.hour, timeOfDay.minute);
  }



  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: height,
            child: CalendarControllerProvider(
              controller: _eventController,
              child: WeekView(
                startHour: 0,
                endHour: 24,
                weekDayStringBuilder: (day) {
                  switch (day) {
                    case 0:
                      return 'Lun';
                    case 1:
                      return 'Mar';
                    case 2:
                      return 'Mer';
                    case 3:
                      return 'Jeu';
                    case 4:
                      return 'Ven';
                    case 5:
                      return 'Sa';
                    case 6:
                      return 'Di';
                    default:
                      return '';
                  }
                },
                headerStyle: HeaderStyle(
                  decoration: const BoxDecoration(color: Colors.white),
                  leftIcon: Icon(
                    Icons.arrow_back_ios,
                    color: lightColorScheme.primary,
                  ),
                  rightIcon: Icon(
                    Icons.arrow_forward_ios,
                    color: lightColorScheme.primary,
                  ),
                ),
                headerStringBuilder: (date, {secondaryDate}) {
                  return "Semaine du ${date.day}/${date.month}/${date.year}";
                },
                timeLineStringBuilder: (date, {secondaryDate}) {
                  return "${date.hour}h";
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }
}


