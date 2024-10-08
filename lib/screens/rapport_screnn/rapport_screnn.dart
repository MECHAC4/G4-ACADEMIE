import 'package:flutter/material.dart';
import 'package:g4_academie/screens/rapport_screnn/rapport_view.dart';
import 'package:g4_academie/users.dart';

import '../../cours.dart';
import '../../services/rapport_service/rapport.dart';
import '../../services/rapport_service/rapport_database.dart';
import '../../services/rapport_service/rapport_params.dart';

class RapportScrenn extends StatefulWidget {
  final Cours cours;
  final AppUser appUser;

  const RapportScrenn({super.key, required this.cours, required this.appUser});

  @override
  State<RapportScrenn> createState() => _RapportScrennState();
}

class _RapportScrennState extends State<RapportScrenn>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Rapports du cours",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorPadding:
              const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 3,
          tabs: const [
            Tab(
                child:
                    Text("Non validé", style: TextStyle(color: Colors.white))),
            Tab(child: Text("Validé", style: TextStyle(color: Colors.white))),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: RapportDatabaseService().getRapport(
            RapportParams(widget.cours.coursePath, widget.cours.peerCoursePath)
                .getChatGroupId(),
            20),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          List<Rapport>? rapports = snapshot.data;
          List<Rapport>? valide =
              rapports?.where((element) => element.type == 1).toList();
          List<Rapport>? nonValide =
              rapports?.where((element) => element.type == 0).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildRapportListView(nonValide, false),
              _buildRapportListView(valide, true),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRapportListView(List<Rapport>? rapports, bool isValid) {
    if (rapports == null || rapports.isEmpty) {
      return const Center(child: Text("Aucun rapport"));
    } else {
      return ListView.builder(
        itemCount: rapports.length,
        itemBuilder: (context, index) {
          Rapport rapport = rapports[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 3),
            child: ListTile(
              leading: CircleAvatar(
                  child: Icon(isValid ? Icons.check : Icons.close,
                      color: isValid ? Colors.green : Colors.red)),
              trailing: TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PdfPreviewPage(
                      rapport: (!(widget.appUser.userType == 'Enseignant') && rapport.type == 0)?rapport:null,
                      canSend: false,
                      canValid: !(widget.appUser.userType == 'Enseignant') &&
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
                      course: widget.cours,
                    ),
                  ));
                },
                child: const Text("voir le rapport"),
              ),
              title: Text("Rapport du ${rapport.content['date']}"),
            ),
          );
        },
      );
    }
  }
}
