import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:g4_academie/theme/theme.dart';

class WeekProgramBuilder extends StatefulWidget {
  const WeekProgramBuilder({super.key});

  @override
  State<WeekProgramBuilder> createState() => _WeekProgramBuilderState();
}

class _WeekProgramBuilderState extends State<WeekProgramBuilder> {
  final EventController _eventController = EventController();

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: height, // Définissez une hauteur appropriée pour WeekView
            child: CalendarControllerProvider(
              controller: _eventController,
              child: WeekView(
                startHour: -18,
                endHour: 2,
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
                      return ''; // Par défaut, retourner une chaîne vide ou gérer d'autres cas si nécessaire
                  }
                },
                weekNumberBuilder: (firstDayOfWeek) {
                  return const Text("");
                },
                headerStyle: HeaderStyle(
                    decoration: const BoxDecoration(color: Colors.white),
                    leftIcon: Icon(
                      Icons.arrow_back_ios,
                      color: lightColorScheme.primary,
                    ), rightIcon: Icon(
                  Icons.arrow_forward_ios,
                  color: lightColorScheme.primary,
                )),
                headerStringBuilder: (date, {secondaryDate}) {
                  return "Semaine du ${date.day}/${date.month}/${date.year}";
                },
                timeLineStringBuilder: (date, {secondaryDate}) {
                  debugPrint("**************************${date.hour}");
                  switch (date.hour) {
                    case 0:
                      return "Oh";
                    case 1:
                      return "1h";
                    case 2:
                      return "2h";
                    case 3:
                      return "3h";
                    case 4:
                      return "4h";
                    case 5:
                      return "5h";
                    case 6:
                      return "6h";
                    case 7:
                      return "7h";
                    case 8:
                      return "8h";
                    case 9:
                      return "9h";
                    case 10:
                      return "10h";
                    case 11:
                      return "11h";
                    case 12:
                      return "12h";
                    case 13:
                      return "13h";
                    case 14:
                      return "14h";
                    case 15:
                      return "15h";
                    case 16:
                      return "16h";
                    case 17:
                      return "17h";
                    case 18:
                      return "18h";
                    case 19:
                      return "19h";
                    case 20:
                      return "20h";
                    case 21:
                      return "21h";
                    case 22:
                      return "22h";
                    case 23:
                      return "23h";
                    case 24:
                      return "24h";
                    default:
                      return "Suis bête";
                  }
                },
                //width: 200, // Définissez une largeur si nécessaire
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
