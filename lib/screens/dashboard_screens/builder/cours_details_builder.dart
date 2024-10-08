import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:g4_academie/app_UI.dart';
import 'package:g4_academie/screens/rapport_screnn/rapport_screnn.dart';

import '../../../cours.dart';
import '../../../users.dart';
import '../../rapport_screnn/rapport_form.dart';

class CourseDetailsPage extends StatefulWidget {
  final Cours cours;
  final AppUser appUser;

  const CourseDetailsPage(
      {super.key, required this.cours, required this.appUser});

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  List<String> stringRate = [
    'Très mauvais',
    'Mauvais',
    'Satisfait',
    'Bon',
    'Excellent'
  ];

  int? intRate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          widget.cours.subject,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                      Icons.person_4, 'Elève', widget.cours.studentFullName),
                  _buildInfoRow(
                      Icons.person,
                      'Enseignant',
                      widget.appUser.userType == 'Enseignant'
                          ? '${widget.appUser.firstName} ${widget.appUser.lastName}'
                          : widget.cours.teacherFullName ?? 'Non défini'),
                  _buildInfoRow(
                      Icons.location_on, 'Adresse', widget.cours.adresse),
                  _buildInfoRow(
                      Icons.access_time,
                      'Heures par semaine',
                      widget.cours.hoursPerWeek?.isNotEmpty == true
                          ? '${widget.cours.hoursPerWeek} heures'
                          : 'Non spécifié'),
                  _buildInfoRow(Icons.info, 'Statut', widget.cours.state),
                  if (widget.cours.price != null)
                    _buildInfoRow(
                        Icons.attach_money_rounded,
                        widget.appUser.userType == 'Enseignant'
                            ? 'Versement'
                            : "Prix",
                        '${widget.cours.price!} FCFA par mois'),
                  const SizedBox(height: 20),
                  if (widget.cours.weekDuration != null &&
                      widget.cours.weekDuration!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Programme de la semaine:',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...widget.cours.weekDuration!.map((session) {
                          String day = session['day'] ?? 'Jour inconnu';
                          String startTime = session['startTime'] ?? 'null';
                          String endTime = session['endTime'] ?? 'null';

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text('$day: $startTime à $endTime',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black54)),
                          );
                        }).toList(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  Center(
                      child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => AppUI(
                                appUser: widget.appUser,
                                index: 2,
                              ),
                            ));
                          },
                          child: const Text("Aller à la page de paiement"))),
                  if (widget.appUser.userType == 'Enseignant' ||
                      widget.cours.teacherFullName != null)
                    Center(child: _buildRatingBar()),
                  const SizedBox(height: 16),
                  if (widget.cours.state == 'Traité' ||
                          widget.cours.state == 'Actif')
                    Row(
                      mainAxisAlignment: widget.appUser.userType == "Enseignant" ?MainAxisAlignment.spaceBetween: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => RapportScrenn(
                                    cours: widget.cours,
                                    appUser: widget.appUser),
                              ));
                            },
                            child: const Text(
                              "Rapports de cours",
                              style: TextStyle(color: Colors.white),
                            )),
                        if (widget.appUser.userType == "Enseignant")
                        ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ReportFormPage(
                                    course: widget.cours,
                                    appUser: widget.appUser),
                              ));
                            },
                            child: const Text("Faire un rapport")),
                      ],
                    )
                ],
              ),
            ),
          ),
          //const Center(child: Text("Rapports de cours")),
        ],
      ),
    );
  }

  /*List<Widget> _buildRapportList(List<Rapport>? rapports, bool isValid) {
    if (rapports != null || rapports!.isEmpty) {
      return const [Center(
        child: Text("Aucun rapport"),
      )];
    } else {

      return rapports.map((rapport) {
        return ListTile(
          leading: isValid
              ? const Icon(
            Icons.check,
            color: Colors.green,
          )
              : const Icon(
            Icons.close,
            color: Colors.red,
          ),
          trailing: TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) {
                    return PdfPreviewPage(
                        canSend: false,
                        canValid:
                        !(widget.appUser.userType == 'Enseignant') &&
                            rapport.type == 0,
                        appUser: widget.appUser,
                        date: rapport.content['date'],
                        studentName: rapport.content['studentName'],
                        level: rapport.content['level'],
                        subject: rapport.content['subject'],
                        theme: rapport.content['theme'],
                        content: rapport.content['content'],
                        participation: rapport.content['participation'],
                        difficulties: rapport.content['difficulties'],
                        improvement: rapport.content['improvement'],
                        nextCourse: rapport.content['nextCourse'],
                        homework: rapport.content['homework'],
                        parentNote: rapport.content['parentNote'],
                        course: widget.cours);
                  },
                ));
              },
              child: const Text("voir le rapport")),
          title: Text("Rapport du ${rapport.content['date']}"),
        );
      },).toList();
    }
  }*/

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 16),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          widget.appUser.userType == 'Enseignant'
              ? 'Noter l\'élève'
              : 'Noter l\'enseignant',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        // Example of a 5-star rating system
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
                onPressed: () {
                  setState(() {
                    intRate = index;
                  });
                },
                icon: (intRate != null && intRate! >= index)
                    ? Icon(
                        Icons.star,
                        color: ratingColors[intRate!],
                        size: 34,
                      )
                    : const Icon(
                        Icons.star_border,
                        color: Colors.blue,
                        size: 34,
                      ));
          }),
        ),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                intRate != null ? '${stringRate[intRate!]} ' : 'Aucune note',
                style: const TextStyle(fontSize: 16),
              ),
              if (intRate != null) emojiList[intRate!]
            ],
          ),
        ),
        if (intRate != null)
          TextButton(
              onPressed: () async {
                await saveRateToFirestore(intRate!);
                intRate = null;
              },
              child: const Text('Envoyez la note'))
      ],
    );
  }

  final List<Widget> emojiList = const [
    Text('😠', style: TextStyle(fontSize: 20)),
    Text('😕', style: TextStyle(fontSize: 20)),
    Text('😐', style: TextStyle(fontSize: 20)),
    Text('😊', style: TextStyle(fontSize: 20)),
    Text('😄', style: TextStyle(fontSize: 20)), // Très mécontent
  ];

  List<Color> ratingColors = [
    const Color(0xFFFF0000).withOpacity(1),
    // 1 étoile - Très mauvais (Rouge vif)
    const Color(0xFFFF6347).withOpacity(0.5),
    // 2 étoiles - Mauvais (Tomate)
    const Color(0xFFFFA500),
    // 3 étoiles - Moyen (Orange)
    const Color(0xFF3CB371),
    // 4 étoiles - Bon (Vert moyen)
    const Color(0xFF228B22)
    // 5 étoiles - Excellent (Vert forêt)
  ];

  Future<void> saveRateToFirestore(int rate) async {
    await FirebaseFirestore.instance
        .collection('notes')
        .doc(widget.cours.teacherID)
        .set({widget.appUser.id: rate});
  }
}
