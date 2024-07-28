import 'package:flutter/material.dart';
import 'package:g4_academie/screens/dashboard_screens/builder/cours_builder.dart';
import 'package:g4_academie/screens/dashboard_screens/builder/week_program_builder.dart';
import 'package:g4_academie/theme/theme.dart';
import 'package:g4_academie/widgets/custom_scaffold.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  late TabController _tabController;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return CustomScaffold(
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
                      "Nom Prénom",
                      style: TextStyle(
                        color: lightColorScheme.surface,
                      ),
                    )),
                TextButton(
                  onPressed: () {},
                  child: Row(
                    children: [
                      Text(
                        "Changer de profil",
                        style: TextStyle(color: lightColorScheme.surface),
                      ),
                      Icon(
                        size: height / 25,
                        Icons.keyboard_arrow_down_sharp,
                        color: lightColorScheme.surface,
                      ),
                    ],
                  ),
                )
              ],
            ),
            Padding(padding: EdgeInsets.only(top: width / 50)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: () {},
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
                child: TabBarView(controller: _tabController, children: const [
                  CoursBuilder(),
                  WeekProgramBuilder(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}










