import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g4_academie/screens/dashboard_screens/builder/cours_details_builder.dart';
import 'package:g4_academie/users.dart';

import '../../../cours.dart';
import '../../../profil_class.dart';

class CoursBuilder extends StatefulWidget {
  final String userId;
  final ProfilClass? selectedProfile;
  final AppUser appUser;

  const CoursBuilder(
      {super.key,
      required this.userId,
      this.selectedProfile,
      required this.appUser});

  @override
  State<CoursBuilder> createState() => _CoursBuilderState();
}

class _CoursBuilderState extends State<CoursBuilder> {
  late Stream<List<Cours>> _coursStream;

  @override
  void initState() {
    super.initState();
    _updateCoursesStream();
    loading();
  }

  void loading() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('profil')
        .doc(widget.userId)
        .get();
    //print("données récupérées : ${data.exists}");
  }

  @override
  void didUpdateWidget(covariant CoursBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedProfile != oldWidget.selectedProfile) {
      _updateCoursesStream();
    }
  }

  void _updateCoursesStream() {
    if (widget.selectedProfile == null ||
        widget.selectedProfile?.id == widget.userId) {
      _coursStream = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('profil')
          .snapshots()
          .asyncMap((profilSnapshot) async {
        List<DocumentSnapshot> profiles = profilSnapshot.docs;
        List<Cours> allCourses = [];

        for (var profile in profiles) {
          var coursesSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .collection('profil')
              .doc(profile.id)
              .collection('courses')
              .get();

          allCourses.addAll(
              coursesSnapshot.docs.map((doc) => Cours.fromMap(doc.data())));
        }

        return allCourses;
      });
    } else {
      _coursStream = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('profil')
          .doc(widget.selectedProfile!.id)
          .collection('courses')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return Cours.fromMap(doc.data());
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Cours>>(
      stream: _coursStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Aucun cours"));
        }

        List<Cours> coursList = snapshot.data!;

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 20, mainAxisSpacing: 20),
          itemCount: coursList.length,
          itemBuilder: (context, index) {
            Cours cours = coursList[index];

            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                  return CourseDetailsPage(cours: cours, appUser: widget.appUser);
                },));
              },
              child: Card(

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.book, color: Colors.blueAccent),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              cours.subject,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.person, color: Colors.greenAccent),
                          const SizedBox(width: 10),
                          Flexible(
                            child: widget.appUser.userType != 'Enseignant'
                                ? Text(
                                    cours.teacherFullName != null
                                        ? 'Mr ${cours.teacherFullName}'
                                        : 'Indéfini',
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : Text(
                                    cours.studentFullName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              color: Colors.orangeAccent),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              cours.hoursPerWeek != null
                                  ? '${cours.hoursPerWeek}h par semaine'
                                  : 'Indéfinie',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.redAccent),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              cours.state,
                              style: TextStyle(
                                fontSize: 14,
                                color: _getStatusColor(cours.state),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String state) {
    switch (state) {
      case 'En cours de traitement':
        return Colors.lightBlue;
      case 'Suspendu':
        return Colors.yellowAccent;
      case 'Actif':
        return Colors.green;
      case 'Rejeté':
        return Colors.red;
      case 'Traité':
        return Colors.lightGreenAccent;
      default:
        return Colors.grey;
    }
  }
}
