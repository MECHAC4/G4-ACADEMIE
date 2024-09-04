import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../cours.dart';
import '../../../users.dart';

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
        centerTitle: true,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(
                  Icons.person_4, 'Elève', widget.cours.studentFullName),
              _buildInfoRow(
                  Icons.person,
                  'Enseignant',
                  widget.cours.teacherFullName != null
                      ? widget.cours.teacherFullName!
                      : 'Non défini'),
              _buildInfoRow(Icons.location_on, 'Adresse', widget.cours.adresse),
              _buildInfoRow(
                  Icons.access_time,
                  'Heures par semaine',
                  (widget.cours.hoursPerWeek != null &&
                          widget.cours.hoursPerWeek!.isNotEmpty)
                      ? '${widget.cours.hoursPerWeek!} heures'
                      : 'Non spécifié'),
              _buildInfoRow(Icons.info, 'Statut', widget.cours.state),
              const SizedBox(height: 20),

              // Week Duration (if available)
              if (widget.cours.weekDuration != null &&
                  widget.cours.weekDuration!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Programme de la semaine:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...widget.cours.weekDuration!.map((session) {
                      String day = session['day'] ?? 'Jour inconnu';
                      String startTime = session['startTime'] ?? 'null';
                      String endTime = session['endTime'] ?? 'null';

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          '$day: $startTime à $endTime',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black54),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 24),
                  ],
                ),

              // Rating Section
              if(widget.appUser.userType == 'Enseignant' || widget.cours.teacherFullName != null)
              const SizedBox(height: 8),

              if(widget.appUser.userType == 'Enseignant' || widget.cours.teacherFullName != null)
                Center(
                child: _buildRatingBar(),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

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
                intRate != null ? '${stringRate[intRate!]} ': 'Aucune note',
                style: const TextStyle(fontSize: 16),
              ),
              if(intRate != null)
                emojiList[intRate!]
            ],
          ),
        ),
        if(intRate != null)
          TextButton(onPressed: ()async{
            await saveRateToFirestore(intRate!);
            intRate = null;
          }, child: const Text('Envoyez la note'))
      ],
    );
  }

  final List<Widget> emojiList = const [
    Text('😠', style: TextStyle(fontSize: 20)),
    Text('😕', style: TextStyle(fontSize: 20)),
    Text('😐', style: TextStyle(fontSize: 20)),
    Text('😊', style: TextStyle(fontSize: 20)),
    Text('😄', style: TextStyle(fontSize: 20)),// Très mécontent
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


  Future<void> saveRateToFirestore(int rate)async{
    await FirebaseFirestore.instance.collection('notes').doc(widget.cours.teacherID).set(
      {
        widget.appUser.id: rate
      }
    );
  }




}
