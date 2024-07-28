import 'package:flutter/material.dart';
import 'package:g4_academie/theme/theme.dart';

class UnreadNotification extends StatefulWidget {
  const UnreadNotification({super.key});

  @override
  State<UnreadNotification> createState() => _UnreadNotificationState();
}

class _UnreadNotificationState extends State<UnreadNotification> {
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return SizedBox(
        height: 100,
        child: PageView(
          controller: PageController(viewportFraction: 0.8),
          scrollDirection: Axis.horizontal,
          children: List.generate(10, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              height: 20,
              decoration: BoxDecoration(
                  color: index.isEven ? lightColorScheme.primary : Colors.red,
                  borderRadius: BorderRadius.circular(20)),
              child: Center(
                  child: Text(
                      "Test de notification : notification $index affiché")),
            );
          }),
        ) /*SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 50,
              color: Colors.red,
              child: Center(child: Text('Fixed content 1')),
            ),
            Container(
              height: 50,
              color: Colors.green,
              child: Center(child: Text('Fixed content 2')),
            ),
            Container(
              height: 50,
              color: Colors.blue,
              child: Center(child: Text('Fixed content 3')),
            ),
            Container(
              height: 50,
              color: Colors.red,
              child: Center(child: Text('Fixed content 1')),
            ),
            Container(
              height: 50,
              color: Colors.green,
              child: Center(child: Text('Fixed content 2')),
            ),
            Container(
              height: 50,
              color: Colors.blue,
              child: Center(child: Text('Fixed content 3')),
            ),
          ],
        ),
      ),*/
        );
  }
}
