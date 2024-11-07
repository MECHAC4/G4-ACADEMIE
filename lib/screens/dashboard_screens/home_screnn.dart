import 'package:flutter/material.dart';
import 'package:g4_academie/screens/dashboard_screens/builder/add_cours_builder.dart';
import 'package:g4_academie/screens/dashboard_screens/builder/cours_builder.dart';
import 'package:g4_academie/screens/dashboard_screens/builder/notification_icon_builder.dart';
import 'package:g4_academie/screens/dashboard_screens/builder/week_program_builder.dart';
import 'package:g4_academie/screens/notification/courses_notification_screen.dart';
import 'package:g4_academie/screens/profil/user_profil.dart';
import 'package:g4_academie/services/profil_services.dart';

import '../../profil_class.dart';
import '../../users.dart';
import 'builder/profil_dialog_builder.dart';

class DashboardPage extends StatefulWidget {
  final AppUser appUser;
  final AppUser admin;
  final bool? redirect;

  const DashboardPage({Key? key,this.redirect = false, required this.appUser, required this.admin}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with TickerProviderStateMixin {
  late AppUser _appUser;
  ProfilClass? selectedProfile;
  List<ProfilClass> profiles = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _appUser = widget.appUser;
    _tabController = TabController(length: 2, vsync: this);
    loadProfiles();
    createMainProfile();

  }

  void loadProfiles() async {
    profiles = await ProfilServices().fetchProfiles(_appUser.id);
    setState(() {});
  }

  void createMainProfile() async {
    bool mainProfilExist = await ProfilServices().profilExist(widget.appUser.id);
    if (!mainProfilExist) {
      ProfilServices().saveProfileToFirestore({
        'firstName': _appUser.firstName,
        'lastName': _appUser.lastName,
        'studentClass': _appUser.studentClass ?? 'Particulière',
        'adresse': _appUser.address,
      }, _appUser.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Accueil", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        actions: [
          IconButton(
            icon: NotificationsIcon(userId: _appUser.id),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => NotificationsPage(
                  appUser: widget.appUser,
                  admin: widget.admin,
                ),
              ));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Selection Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<ProfilClass>(
                  underline: const SizedBox(),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blueAccent),
                  hint: Text(
                    selectedProfile == null ? 'Profil principal' : '${selectedProfile?.firstName} ${selectedProfile?.lastName}',
                    style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  onChanged: (ProfilClass? newProfile) {
                    setState(() {
                      selectedProfile = newProfile;
                    });
                  },
                  items: profiles.map((ProfilClass profile) {
                    return DropdownMenuItem<ProfilClass>(
                      value: profile,
                      child: Text(
                          '  ${profile.firstName} ${profile.lastName}'
                              .trim() ==
                              '${widget.appUser.firstName} ${widget.appUser.lastName}'
                              ? 'Profil principal'
                              : '  ${profile.firstName} ${profile.lastName}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    );
                  }).toList(),
                ),
                IconButton(
                  icon: const Row(
                    children: [
                      Text('Voir mon profil  ', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w900),),
                       Icon(Icons.visibility, color: Colors.blueAccent),
                    ],
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => UserProfilePage(user: widget.appUser),
                    ));
                  },
                ),
              ],
            ),
            //const SizedBox(height: 20),
            // Buttons Section
            if(_appUser.userType != "Enseignant")
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text(
                     "Demander un cours",
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (_appUser.userType != "Enseignant") {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AddCourseDialog(profiles: profiles, appUser: _appUser),
                      ));
                    } else {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => NotificationsPage(appUser: widget.appUser, admin: widget.admin),
                      ));
                    }
                  },
                ),
              ],
            ),
            //const SizedBox(height: 20),
            // Tab Section
            TabBar(
              controller: _tabController,
              labelColor: Colors.blueAccent,
              indicatorColor: Colors.blueAccent,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: "Aperçu des cours"),
                Tab(text: "Programme de la semaine"),
              ],
            ),
            const SizedBox(height: 20),
            // Tab View Section
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  CoursBuilder(appUser: _appUser, userId: _appUser.id, selectedProfile: selectedProfile),
                  WeekProgramBuilder(profil: selectedProfile, appUser: _appUser),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: (widget.appUser.userType == "Parent d'élève")
          ? FloatingActionButton(
          onPressed: () {
              showProfileDialog(context, widget.appUser.id, widget.appUser.address, profiles, widget.appUser);
          },
          child: Text(
            widget.appUser.userType == "Parent d'élève"
                ? "Créer un profil"
                : "Créer un groupe",
            textAlign: TextAlign.center,
          ) /*const Icon(Icons.add),*/)
          : null,
    );
  }
}
