import 'package:flutter/material.dart';
import 'package:g4_academie/screens/dashboard_screens/builder/add_cours_builder.dart';
import 'package:g4_academie/screens/dashboard_screens/builder/cours_builder.dart';
import 'package:g4_academie/screens/dashboard_screens/builder/week_program_builder.dart';
import 'package:g4_academie/services/profil_services.dart';
import 'package:g4_academie/theme/theme.dart';
import 'package:g4_academie/widgets/custom_scaffold.dart';

import '../../profil_class.dart';
import '../../users.dart';

class DashboardPage extends StatefulWidget {
  final AppUser appUser;

  const DashboardPage({super.key, required this.appUser});

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
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _appUser = widget.appUser;
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    loadProfiles();
  }

  void loadProfiles() async {
    profiles = await ProfilServices().fetchProfiles(_appUser.id);
    setState(() {});
  }

  late TabController _tabController;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return CustomScaffold(
      appUser: _appUser,
      buttonExist: true,
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
                      selectedProfile == null
                          ? '${_appUser.firstName.toUpperCase()} ${_appUser.lastName.toUpperCase()}'
                          : selectedProfile!.isGroup
                              ? '${selectedProfile?.groupName}'
                              : '${selectedProfile?.firstName} ${selectedProfile?.lastName}',
                      style: TextStyle(
                        color: lightColorScheme.surface,
                      ),
                    )),
                DropdownButton<ProfilClass>(
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
                      print("*************${newProfile?.adresse}*********");
                    });
                  },
                  items: profiles.map((ProfilClass profile) {
                    return DropdownMenuItem<ProfilClass>(
                      value: profile,
                      child: Text(profile.isGroup
                          ? profile.groupName ?? 'Groupe'
                          : profile.firstName ?? 'Individuel'),
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
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AddCourseDialog(
                          profiles: profiles,
                          userId: _appUser.id,
                        ),
                      ));
                    },
                    child: Text(
                      "Ajouter un cours",
                      style: TextStyle(
                          color: lightColorScheme.surface,
                          //fontWeight: FontWeight.w600,
                          fontSize: height / 45),
                    )),
                IconButton(
                    onPressed: () {},
                    icon: Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                            left: width / 25,
                          ),
                          child: Text(
                            "2",
                            style: TextStyle(
                                color: lightColorScheme.error.withOpacity(1)),
                          ),
                        ),
                        Icon(
                          size: height / 35,
                          Icons.notifications,
                          color: lightColorScheme.surface,
                        ),
                      ],
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
                child: TabBarView(controller: _tabController, children:  [
                  CoursBuilder(userId: _appUser.id,selectedProfile: selectedProfile,),
                  const WeekProgramBuilder(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
