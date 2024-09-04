import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:g4_academie/screens/dashboard_screens/builder/add_cours_builder.dart';
import 'package:g4_academie/screens/dashboard_screens/builder/cours_builder.dart';
import 'package:g4_academie/screens/dashboard_screens/builder/notification_icon_builder.dart';
import 'package:g4_academie/screens/dashboard_screens/builder/week_program_builder.dart';
import 'package:g4_academie/screens/notification/courses_notification_screen.dart';
import 'package:g4_academie/screens/verification/verification.dart';
import 'package:g4_academie/services/profil_services.dart';
import 'package:g4_academie/theme/theme.dart';
import 'package:g4_academie/widgets/custom_scaffold.dart';

import '../../app_UI.dart';
import '../../profil_class.dart';
import '../../users.dart';

class DashboardPage extends StatefulWidget {
  final AppUser appUser;
  final AppUser admin;

  const DashboardPage({super.key, required this.appUser, required this.admin});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  late AppUser _appUser;
  ProfilClass? selectedProfile;
  List<ProfilClass> profiles = [];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
    verification();
  }

  Future<bool> isProfilVerified() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('verification')
        .doc(widget.appUser.id)
        .get();
    return doc.exists;
  }

  bool isVerified = true;

  void verification() async {
    isVerified = await isProfilVerified();//setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _appUser = widget.appUser;
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    loadProfiles();
    createMainProfile();
  }

  void loadProfiles() async {
    profiles = await ProfilServices().fetchProfiles(_appUser.id);
    setState(() {});
  }

  void createMainProfile() async {
    bool mainProfilExist =
        await ProfilServices().profilExist(widget.appUser.id);
    print("Profil existant ? : $mainProfilExist");
    if (!mainProfilExist) {
      ProfilServices().saveProfileToFirestore({
        'firstName': _appUser.firstName,
        'lastName': _appUser.lastName,
        'studentClass': _appUser.studentClass,
        'adresse': _appUser.address,
      }, _appUser.id);
    }
  }

  late TabController _tabController;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return CustomScaffold(
      appUser: _appUser,
      buttonExist: _appUser.userType == "Parent d'élève",
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: () {},
                    child: Text(
                      ((selectedProfile == null) ||
                              (selectedProfile?.firstName ==
                                      _appUser.firstName &&
                                  selectedProfile?.lastName ==
                                      _appUser.lastName &&
                                  selectedProfile?.adresse ==
                                      _appUser.address &&
                                  selectedProfile?.studentClass ==
                                      _appUser.studentClass))
                          ? 'Profil principal' /*'${_appUser.firstName.toUpperCase()} ${_appUser.lastName.toUpperCase()}'*/
                          : '${selectedProfile?.firstName} ${selectedProfile?.lastName}',
                      style: TextStyle(
                        color: lightColorScheme.surface,
                      ),
                    )),
                _appUser.userType == "Elève" ||
                        _appUser.userType == "Enseignant"
                    ? TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                AppUI(appUser: widget.appUser, index: 3),
                          ));
                        },
                        child: Row(
                          children: [
                            Text(
                              "Modifier mon profil",
                              style: TextStyle(color: lightColorScheme.surface),
                            ),
                            Icon(
                              Icons.edit,
                              color: lightColorScheme.surface,
                            ),
                          ],
                        ),
                      )
                    : DropdownButton<ProfilClass>(
                        underline: const SizedBox(),
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: lightColorScheme.surface,
                        ),
                        onTap: () {
                          setState(() {
                            loadProfiles();
                          });
                        },
                        hint: Text(
                          'Changer de profil',
                          style: TextStyle(
                            color: lightColorScheme.surface,
                          ),
                        ),
                        //value: selectedProfile,
                        onChanged: (ProfilClass? newProfile) {
                          setState(() {
                            selectedProfile = newProfile;
                            print(
                                "*************${newProfile?.adresse}*********");
                          });
                        },
                        items: profiles.map((ProfilClass profile) {
                          return DropdownMenuItem<ProfilClass>(
                            value: profile,
                            child: Text(
                                (profile.firstName == _appUser.firstName &&
                                        profile.lastName == _appUser.lastName &&
                                        profile.adresse == _appUser.address &&
                                        profile.studentClass ==
                                            _appUser.studentClass)
                                    ? 'Profil principal'
                                    : profile.firstName + profile.lastName),
                          );
                        }).toList(),
                      ),
              ],
            ),
            Padding(padding: EdgeInsets.only(top: width / 50)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: () {
                      verification();
                      if (_appUser.userType != "Enseignant") {
                        setState(() {
                        });
                        if (isVerified) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AddCourseDialog(
                              profiles: profiles,
                              appUser: _appUser,
                              //userId: _appUser.id,
                            ),
                          ));
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: const Text(
                                  "Vous devez vérifier votre profil d'abord avant de demander un cours",
                                  textAlign: TextAlign.center,
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                          builder: (context) =>
                                              VerificationStepPage(
                                            user: widget.appUser,
                                          ),
                                        ));
                                      },
                                      child: const Text("Vérifier mon profil"))
                                ],
                              );
                            },
                          );
                        }
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => NotificationsPage(
                            appUser: widget.appUser,
                            admin: widget.admin,
                          ),
                        ));
                      }
                    },
                    child: Text(
                      _appUser.userType != "Enseignant"
                          ? "Ajouter un cours"
                          : "Notifications",
                      style: TextStyle(
                          color: lightColorScheme.surface,
                          fontSize: height / 45),
                    )),
                IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => NotificationsPage(
                          appUser: widget.appUser,
                          admin: widget.admin,
                        ),
                      ));
                    },
                    icon: NotificationsIcon(
                      userId: _appUser.id,
                    ))
              ],
            ),
            Padding(padding: EdgeInsets.only(top: width / 50)),
            TabBar(
                automaticIndicatorColorAdjustment: true,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 8),
                indicatorWeight: 3,
                indicatorColor: lightColorScheme.surface,
                controller: _tabController,
                dividerColor: lightColorScheme.primary.withOpacity(0),
                tabs: [
                  Text(
                    "Apperçcu des cours",
                    style: TextStyle(
                        color: lightColorScheme.surface,
                        fontWeight: FontWeight.w700),
                  ),
                  Text("Programme de la semaine",
                      style: TextStyle(
                          color: lightColorScheme.surface,
                          fontWeight: FontWeight.w700)),
                ],
                padding: const EdgeInsets.only(bottom: 15)),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(top: width / 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.0),
                    topRight: Radius.circular(40.0),
                  ),
                ),
                child: TabBarView(controller: _tabController, children: [
                  CoursBuilder(
                    appUser: widget.appUser,
                    userId: _appUser.id,
                    selectedProfile: selectedProfile,
                  ),
                   WeekProgramBuilder(profil: selectedProfile, appUser: widget.appUser,),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
