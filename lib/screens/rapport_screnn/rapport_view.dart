import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:g4_academie/screens/dashboard_screens/builder/cours_details_builder.dart';
import 'package:g4_academie/screens/rapport_screnn/rapport_screnn.dart';
import 'package:g4_academie/services/rapport_service/rapport_params.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../constants.dart';
import '../../cours.dart';
import '../../rapport_class.dart';
import '../../services/rapport_service/rapport.dart';
import '../../services/rapport_service/rapport_database.dart';
import '../../users.dart';

class PdfPreviewPage extends StatefulWidget {
  final Rapport? rapport;
  final String date;
  final String studentName;
  final String level;
  final String subject;
  final String theme;
  final String content;
  final String participation;
  final String difficulties;
  final String improvement;
  final String nextCourse;
  final String homework;
  final String parentNote;
  final Cours course;
  final AppUser appUser;
  final bool canSend;
  final bool canValid;

  const PdfPreviewPage({
    super.key,
    required this.rapport,
    required this.canSend,
    required this.canValid,
    required this.appUser,
    required this.date,
    required this.studentName,
    required this.level,
    required this.subject,
    required this.theme,
    required this.content,
    required this.participation,
    required this.difficulties,
    required this.improvement,
    required this.nextCourse,
    required this.homework,
    required this.parentNote,
    required this.course,
  });

  @override
  State<PdfPreviewPage> createState() => _PdfPreviewPageState();
}

class _PdfPreviewPageState extends State<PdfPreviewPage> {
  late RapporClass rapport; // Déclaration de l'instance de RapporClass
  //String idFrom = '';
  String idTo = '';

  @override
  void initState() {
    super.initState();
    //idFrom = widget.course.teacherID!;
    rapport = RapporClass(
      id: '',
      // Remplacez par un ID unique approprié
      date: widget.date,
      studentCoursePath: widget.appUser.userType == 'Enseignant'
          ? widget.course.peerCoursePath
          : widget.course.coursePath,
      teacherCoursePath: widget.appUser.userType == 'Enseignant'
          ? widget.course.coursePath
          : widget.course.peerCoursePath,
      teacherName: '${widget.course.teacherFullName}',
      studentName: widget.studentName,
      level: widget.level,
      subject: widget.subject,
      theme: widget.theme,
      content: widget.content,
      participation: widget.participation,
      difficulties: widget.difficulties,
      improvement: widget.improvement,
      nextCourse: widget.nextCourse,
      homework: widget.homework,
      parentNote: widget.parentNote,
      parentCommentaire:
          null, // Vous pouvez définir ici un commentaire parent s'il existe
    );
  }

  Future<Uint8List> _generatePdf(final PdfPageFormat format) async {
    final pdf = pw.Document();
    final ByteData headerData1 = await rootBundle.load('lib/Assets/logo.jpg');
    Uint8List file1 = Uint8List.fromList(headerData1.buffer.asUint8List());

    pdf.addPage(
      pw.MultiPage(
        header: (context) {
          return pw.Column(children: [
            pw.Container(
              decoration: const pw.BoxDecoration(
                  gradient: pw.LinearGradient(colors: [
                PdfColors.indigo,
                PdfColors.indigoAccent,
                PdfColors.blue,
                PdfColors.blueAccent,
                PdfColors.blueGrey,
                PdfColors.greenAccent,
              ])),
              height: 40,
            ),
          ]);
        },
        footer: (context) {
          return pw.Column(children: [
            pw.Container(
              decoration: const pw.BoxDecoration(
                  gradient: pw.LinearGradient(colors: [
                PdfColors.indigo,
                PdfColors.indigoAccent,
                PdfColors.blue,
                PdfColors.blueAccent,
                PdfColors.blueGrey,
                PdfColors.greenAccent,
              ])),
              height: 40,
            ),
          ]);
        },
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return [
            pw.Padding(
                padding: const pw.EdgeInsets.only(top: -15),
                child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 20),
                        child: pw.Image(pw.MemoryImage(file1), width: 100),
                      ),
                      pw.Text(
                        'Rapport du Cours de ${widget.date}',
                        style: pw.TextStyle(
                            fontSize: 24,
                            decoration: pw.TextDecoration.underline,
                            fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 20),
                        child: pw.Image(pw.MemoryImage(file1), width: 100),
                      ),
                    ])),
            pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 20),
                child: pw.Column(
                  children: [
                    pw.SizedBox(height: 20),

                    // Section: Informations de base
                    pw.Text(
                      'Informations de base',
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold),
                    ),
                    _buildInfoRow('Date:', widget.date),
                    _buildInfoRow('Nom de l\'élève:', widget.studentName),
                    _buildInfoRow('Nom du professeur',
                        '${widget.course.teacherFullName}'),
                    _buildInfoRow('Niveau de l\'élève:', widget.level),
                    pw.SizedBox(height: 20),

                    // Section: Détails du cours
                    pw.Text(
                      'Détails du cours',
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold),
                    ),
                    _buildInfoRow('Matière:', widget.subject),
                    _buildInfoRow('Thème du cours:', widget.theme),
                    _buildInfoRow('Contenu:', widget.content),
                    pw.SizedBox(height: 20),

                    // Section: Participation & Difficultés
                    pw.Text(
                      'Participation & Difficultés',
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold),
                    ),
                    _buildInfoRow('Participation:', widget.participation),
                    _buildInfoRow('Difficultés:', widget.difficulties),
                    pw.SizedBox(height: 20),

                    // Section: Progrès & Prochain cours
                    pw.Text(
                      'Progrès & Prochain cours',
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold),
                    ),
                    _buildInfoRow('Progrès observés:', widget.improvement),
                    _buildInfoRow('Suggestions pour le prochain cours:',
                        widget.nextCourse),
                    pw.SizedBox(height: 20),

                    // Section: Devoirs & Remarques
                    pw.Text(
                      'Devoirs & Remarques',
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold),
                    ),
                    _buildInfoRow('Devoirs donnés:', widget.homework),
                    _buildInfoRow(
                        'Remarques pour les parents:', widget.parentNote),
                    pw.SizedBox(height: 20),
                  ],
                )),
          ];
        },
      ),
    );
    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (widget.canSend)
            TextButton(
                onPressed: () {
                  RapportDatabaseService().onSendRapport(
                      RapportParams(widget.course.coursePath,
                              widget.course.peerCoursePath)
                          .getChatGroupId(),
                      Rapport(
                          path: '',
                          idFrom: widget.appUser.id,
                          idTo: widget.course.peerCoursePath.split('/').first,
                          timestamp: Timestamp.fromDate(DateTime.now()),
                          content: rapport.toMap(),
                          type: 0));
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CourseDetailsPage(
                        cours: widget.course, appUser: widget.appUser),
                  ));
                },
                child: const Text("Envoyer le rapport")),
          if (widget.canValid)
            TextButton(
                onPressed: () async {
                  if (widget.rapport != null) {
                    List<String> coursPathDetails =
                    rapport.teacherCoursePath.split('/');
                    DocumentSnapshot ref = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(coursPathDetails.first)
                        .collection('profil')
                        .doc(coursPathDetails[1])
                        .collection('courses').doc(coursPathDetails.last).get();
                    Map<String, dynamic> map = ref.data() as Map<String, dynamic>;

                    await FirebaseFirestore.instance
                        .doc(widget.rapport!.path)
                        .update({'type': 1});
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(coursPathDetails.first)
                        .collection('profil')
                        .doc(coursPathDetails[1])
                        .collection('courses')
                        .doc(coursPathDetails.last)
                        .collection('request_payment')
                        .add({
                      'state': 'Unpaid',
                      'amount': (map['price']/6).floor(),
                      'course': widget.course.subject,
                      'coursePath': widget.course.peerCoursePath,
                      'fullName': widget.course.teacherFullName,
                      'monthOfTransaction':monthList[DateTime.now().month],
                      'transactionDateTime': widget.rapport?.timestamp,
                    });
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => RapportScrenn(
                          cours: widget.course, appUser: widget.appUser),
                    ));
                  }
                },
                child: const Text("Valider le rapport")),
        ],
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios)),
        title: const Text(
          'Aperçu du rapport',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      body: PdfPreview(
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        useActions: false,
        build: _generatePdf,
      ),
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Expanded(
            flex: 1,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          pw.Expanded(
              flex: 3,
              child: pw.Container(
                padding: const pw.EdgeInsets.only(left: 15, bottom: 6),
                child: pw.Text(
                  value,
                  style: const pw.TextStyle(
                    fontSize: 14,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
