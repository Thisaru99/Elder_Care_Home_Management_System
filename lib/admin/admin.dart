// ignore_for_file: non_constant_identifier_names

import 'dart:core';

import 'package:elder/admin/constants.dart';
import 'package:elder/auth/login.dart';
import 'package:elder/entity.dart';
import 'package:elder/functions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:elder/admin/responsive.dart';
import 'package:flutter_svg/svg.dart';

import '../widgets.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin Panel',
      // theme: ThemeData.dark().copyWith(
      //   scaffoldBackgroundColor: bgColor,
      //   textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
      //       .apply(bodyColor: Colors.white),
      //   canvasColor: secondaryColor,
      // ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => MenuAppController(),
          ),
        ],
        child: Dashboard(),
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {



    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: const SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We want this side menu only for large screen
            if (Responsive.isDesktop(context))
              const Expanded(
                // default flex = 1
                // and it takes 1/6 part of the screen
                child: SideMenu(),
              ),
            const Expanded(
              // It takes 5/6 part of the screen
              flex: 5,
              child: Screen(),
            ),
          ],
        ),
      ),
    );
  }
}

int screen = 0;
Function? changeScreen;

class Screen extends StatefulWidget {

  const Screen({
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _Screen();
  }
}
class _Screen extends State<Screen> {

  List<User> users = [];
  List<Care> cares = [];

  Future<void> load() async {
    List<User> u = await get_users();

    try{
      List<Care> c = await get_cares();
      setState(() {
        cares = c;
      });
    }catch(e){

    }

    setState(() {
      users = u;
    });




  }


  @override
  Widget build(BuildContext context) {
    if (screen == 0) return DashboardScreen(users);
    if (screen == 1) return UsersScreen(users);
    if (screen == 2) return CaresScreen(cares);
    if (screen == 3) return HealthScreen(users);
    if (screen == 4) return CompletedCareScreen(users, cares);
    if (screen == 5) return SevereDiseaseScreen(users);

    return DashboardScreen(users);
  }

  void callSetState() {
    setState((){}); // it can be called without parameters. It will redraw based on changes done in _SecondWidgetState
  }

  _Screen(){
    changeScreen = callSetState;
    load();
  }
}



class SideMenu extends StatefulWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SideMenu();
  }


}
class _SideMenu extends State<SideMenu> {

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset("assets/images/care.PNG"),
          ),
          DrawerListTile(
            title: "Dashboard",
            svgSrc: "assets/icons/menu_dashboard.svg",
            press: () {
              screen = 0;
              changeScreen!();
              Navigator.of(context).pop();
            },
          ),
          DrawerListTile(
            title: "Users",
            svgSrc: "assets/icons/users.svg",
            press: () {

              screen = 1;
              changeScreen!();
              Navigator.of(context).pop();

            },
          ),
          DrawerListTile(
            title: "Cares",
            svgSrc: "assets/icons/cares.svg",
            press: () {

              screen = 2;
              changeScreen!();
              Navigator.of(context).pop();

            },
          ),
          DrawerListTile(
            title: "Health Status",
            svgSrc: "assets/icons/health.svg",
            press: () {
              screen = 3;
              changeScreen!();
              Navigator.of(context).pop();
            },
          ),
          DrawerListTile(
            title: "Completed Cares",
            svgSrc: "assets/icons/completed.svg",
            press: () {
              screen = 4;
              changeScreen!();
              Navigator.of(context).pop();
            },
          ),
          DrawerListTile(
            title: "Severe Diseases",
            svgSrc: "assets/icons/severe.svg",
            press: () {
              screen = 5;
              changeScreen!();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}


class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
        height: 16,
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}


class UsersScreen extends StatelessWidget {
  final List<User> users;


  DataRow recentFileDataRow(BuildContext context, User user) {


    DataRow row = DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              const Icon(IconData(0xe491, fontFamily: 'MaterialIcons')),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Text(user.username),
              ),
            ],
          ),
        )
      ],
      onSelectChanged: (bool? selected) {
        if (selected != null && selected) {
          Navigator.push(context, MaterialPageRoute(
              builder: (context) =>
              ViewUser(user))
          );
        }
      },
    );



    return row;
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> widgets = [];

    Map<String, List<User>> care_map = Map();

    for(User care in users){
      List<User> list = [];
      {
        List<User>? ff = care_map[care.type];
        if (ff != null){
          list = ff;
        }
      }

      list.add(care);

      care_map[care.type] = list;
    }

    for(String key in care_map.keys){
      List<User> cares = care_map[key]!;
      Widget widget = get_care_widget(context, key, cares);
      widgets.add(widget);
    }

    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        // padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            const Header(),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20 ,horizontal: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Users",
                    // style: Theme.of(context).textTheme.titleMedium,
                    style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),

                  ),
                  ElevatedButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      padding: EdgeInsets.symmetric(
                        horizontal: defaultPadding * 1.5,
                        vertical:
                        defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) =>
                              const AddUser())
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add New",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: widgets,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );

  }





  Widget get_care_widget(BuildContext context, String category, List<User> cares) {
    Widget widget = Container(
      padding: const EdgeInsets.all(defaultPadding),
      margin: const EdgeInsets.symmetric(vertical: defaultPadding, horizontal: 30),
      decoration: const BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: defaultPadding,
              columns: [
                DataColumn(
                  label: Text(category),
                ),
              ],
              rows: List.generate(
                cares.length,
                    (index) => recentFileDataRow(context, cares[index]),
              ),
              showCheckboxColumn: false,
            ),
          ),
        ],
      ),
    );
    return widget;
  }




  UsersScreen(this.users);
}
class DashboardScreen extends StatelessWidget {
  final List<User> users;


  DataRow recentFileDataRow(BuildContext context, String type, int count) {


    DataRow row = DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              const Icon(IconData(0xe491, fontFamily: 'MaterialIcons')),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Text(type),
              ),
            ],
          ),
        ),
        DataCell(Text(count.toString()))
      ],
    );



    return row;
  }

  @override
  Widget build(BuildContext context) {

    Map details = {};

    for (User user in users){
      int count = 0;
      if(details.containsKey(user.type)){
        count = details[user.type];
      }

      count++;
      details[user.type] = count;
    }

    List<dynamic> data = List<dynamic>.from(details.keys);

    Widget userW = Container(
      padding: const EdgeInsets.all(defaultPadding),
      margin: const EdgeInsets.symmetric(vertical: defaultPadding, horizontal: 30 ),
      decoration: const BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: defaultPadding,
              // minWidth: 600,
              columns: [
                const DataColumn(
                  label: Text("User type"),
                ),
                const DataColumn(
                  label: Text("Count"),
                ),
              ],
              rows: List.generate(
                data.length,
                    (index) => recentFileDataRow(context, data[index], details[data[index]]),
              ),
              showCheckboxColumn: false,
            ),
          ),
        ],
      ),
    );


    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        // padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            const Header(),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20 ,horizontal: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Analytics",
                    // style: Theme.of(context).textTheme.titleMedium,
                    style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),

                  ),
                ],
              ),
            ),
            const SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      userW,
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  DashboardScreen(this.users);
}

/*
class CaresScreen extends StatelessWidget {
  final List<Care> cares;


  DataRow recentFileDataRow(BuildContext context, Care care) {


    DataRow row = DataRow(
      cells: [
        DataCell(Text(care.name),),
        DataCell(Text(care.category))
      ],
      onSelectChanged: (bool? selected) {
        if (selected != null && selected) {
          Navigator.push(context, MaterialPageRoute(
              builder: (context) =>
                  ViewCare(care))
          );
        }
      },
    );



    return row;
  }

  @override
  Widget build(BuildContext context) {

    Widget careW = Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: defaultPadding,
              // minWidth: 600,
              columns: [
                DataColumn(
                  label: Text("Carename"),
                ),
                DataColumn(
                  label: Text("Type"),
                ),
              ],
              rows: List.generate(
                cares.length,
                    (index) => recentFileDataRow(context, cares[index]),
              ),
              showCheckboxColumn: false,
            ),
          ),
        ],
      ),
    );


    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(),
            SizedBox(height: defaultPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Cares",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ElevatedButton.icon(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: defaultPadding * 1.5,
                      vertical:
                      defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) =>
                            AddCare())
                    );
                  },
                  icon: Icon(Icons.add),
                  label: Text("Add New"),
                ),
              ],
            ),
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      careW,
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }



  CaresScreen(this.cares);
}
*/
class CaresScreen extends StatelessWidget {
  final List<Care> cares;

  DataRow recentFileDataRow(BuildContext context, Care user) {


    DataRow row = DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              const Icon(IconData(0xe491, fontFamily: 'MaterialIcons')),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Text(user.name),
              ),
            ],
          ),
        )
      ],
      onSelectChanged: (bool? selected) {
        if (selected != null && selected) {
/*          Navigator.push(context, MaterialPageRoute(
              builder: (context) =>
                  ViewUser(user))
          );*/
        }
      },
    );



    return row;
  }
  Widget get_care_widget(BuildContext context, String category, List<Care> cares) {
    Widget widget = Container(
      padding: const EdgeInsets.all(defaultPadding),
      margin: const EdgeInsets.symmetric(vertical: defaultPadding, horizontal: 30),
      decoration: const BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: defaultPadding,
              columns: [
                DataColumn(
                  label: Text(category),
                ),
              ],
              rows: List.generate(
                cares.length,
                    (index) => recentFileDataRow(context, cares[index]),
              ),
              showCheckboxColumn: false,
            ),
          ),
        ],
      ),
    );
    return widget;
  }

  @override
  Widget build(BuildContext context) {


    List<Widget> widgets = [];

    Map<String, List<Care>> care_map = Map();

    for(Care care in cares){
      List<Care> list = [];
      {
        List<Care>? ff = care_map[care.category];
        if (ff != null){
          list = ff;
        }
      }

      list.add(care);

      care_map[care.category] = list;
    }

    for(String key in care_map.keys){
      List<Care> cares = care_map[key]!;
      Widget widget = get_care_widget(context, key, cares);
      widgets.add(widget);
    }

    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        // padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            const Header(),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20 ,horizontal: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Cares",
                    // style: Theme.of(context).textTheme.titleMedium,
                    style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),

                  ),
                  ElevatedButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      padding: EdgeInsets.symmetric(
                        horizontal: defaultPadding * 1.5,
                        vertical:
                        defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) =>
                              const AddCare())
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add New",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: widgets,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }



  CaresScreen(this.cares);
}


class HealthScreen extends StatelessWidget {
  late final List<User> users;


  DataRow recentFileDataRow(BuildContext context, User user) {


    DataRow row = DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              const Icon(IconData(0xe491, fontFamily: 'MaterialIcons')),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Text(user.username),
              ),
            ],
          ),
        )
      ],
      onSelectChanged: (bool? selected) {
        if (selected != null && selected) {
          Navigator.push(context, MaterialPageRoute(
              builder: (context) =>
                  ViewHealthStatus(user))
          );
        }
      },
    );



    return row;
  }

  @override
  Widget build(BuildContext context) {

    Widget userW = Container(
      padding: const EdgeInsets.all(defaultPadding),
      margin: const EdgeInsets.symmetric(vertical: defaultPadding, horizontal: 30),
      decoration: const BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: defaultPadding,
              // minWidth: 600,
              columns: [
                const DataColumn(
                  label: Text("Username"),
                )
              ],
              rows: List.generate(
                users.length,
                    (index) => recentFileDataRow(context, users[index]),
              ),
              showCheckboxColumn: false,
            ),
          ),
        ],
      ),
    );


    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        // padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            const Header(),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20 ,horizontal: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Health Status",
                    // style: Theme.of(context).textTheme.titleMedium,
                    style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),

                  ),
                ],
              ),
            ),
            const SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      userW,
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  HealthScreen(List<User> users){

    this.users = [];
    for(User user in users){
      if(user.type == "Elder"){
        this.users.add(user);
      }
    }

  }
}

class CompletedCareScreen extends StatelessWidget {
  late final List<User> users;
  late final List<Care> cares;

  DataRow recentFileDataRow(BuildContext context, User user) {


    DataRow row = DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              const Icon(IconData(0xe491, fontFamily: 'MaterialIcons')),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Text(user.username),
              ),
            ],
          ),
        )
      ],
      onSelectChanged: (bool? selected) {
        if (selected != null && selected) {

          DateTime today = DateTime.now();

          Future<void> _selectDate(BuildContext context) async {
            final DateTime? f = await showDatePicker(
                context: context,
                helpText: "Select starting date",
                initialDate: today,
                firstDate: DateTime(2015, 8),
                lastDate: DateTime(2101));

            final DateTime? t = await showDatePicker(
                context: context,
                helpText: "Select ending date",
                initialDate: f??today,
                firstDate: DateTime(2015, 8),
                lastDate: DateTime(2101));


            DateTime from, to, old_from;

            if (f != null && t != null) {
              from = f;
              old_from = f;
              to = t;

              if(from.isAfter(to)){
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Starting date should be older than ending date!"),
                ));
                return;
              }


              Set<String> days = {};
              days.add(from.toString().split(" ")[0]);

              while (from.isBefore(to)) {
                from = from.add(Duration(days: 1));
                days.add(from.toString().split(" ")[0]);
              }

              days.add(to.toString().split(" ")[0]);

              print(days);

              List<Care> cares = [];

              for(String day in days){
                try{
                  List<Care> c = await get_marked_cares(user.id, day, this.cares, () {}, () {});
                  cares.addAll(c);
                }catch(e){}
              }


              if(cares.length == 0){
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("No given cares!"),
                ));
              }else{
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) =>
                        ViewCompletedCare(user, cares, old_from, to)));
              }

            }
            else{
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Invalid date selection!"),
              ));

            }
          }

          _selectDate(context);


        }
      },
    );



    return row;
  }

/*
  Future<String> _select_date(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        helpText: "Select starting date",
        initialDate: DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      String day = picked.toString().split(" ")[0];

      List<Care> c = await get_marked_cares(user.id, day, cares, () {}, () {});

      Navigator.push(context, MaterialPageRoute(
          builder: (context) =>
              ViewCompletedCare(user, c, day)));
    }
  }
*/


  @override
  Widget build(BuildContext context) {

    Widget userW = Container(
      padding: const EdgeInsets.all(defaultPadding),
      margin: const EdgeInsets.symmetric(vertical: defaultPadding, horizontal: 30),
      decoration: const BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: defaultPadding,
              // minWidth: 600,
              columns: [
                const DataColumn(
                  label: Text("Username"),
                )
              ],
              rows: List.generate(
                users.length,
                    (index) => recentFileDataRow(context, users[index]),
              ),
              showCheckboxColumn: false,
            ),
          ),
        ],
      ),
    );


    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        // padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            const Header(),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20 ,horizontal: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Completed Cares",
                    // style: Theme.of(context).textTheme.titleMedium,
                    style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),

                  ),
                ],
              ),
            ),
            const SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      userW,
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  CompletedCareScreen(List<User> users, List<Care> cares){

    this.users = [];
    for(User user in users){
      if(user.type == "Elder"){
        this.users.add(user);
      }
    }
    this.cares = cares;

  }
}

class SevereDiseaseScreen extends StatelessWidget {
  late final List<User> users;


  DataRow recentFileDataRow(BuildContext context, User user) {


    DataRow row = DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              const Icon(IconData(0xe491, fontFamily: 'MaterialIcons')),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Text(user.username),
              ),
            ],
          ),
        )
      ],
      onSelectChanged: (bool? selected) {
        if (selected != null && selected) {
          Navigator.push(context, MaterialPageRoute(
              builder: (context) =>
                  ViewSevereDiseases(user))
          );
        }
      },
    );



    return row;
  }

  @override
  Widget build(BuildContext context) {

    List<User> users = [];

    for(User user in this.users){
      for(HealthEntry entry in user.health){
        if(entry.status == "Severe") {
          users.add(user);
          break;
        }
      }
    }




    Widget userW = Container(
      padding: const EdgeInsets.all(defaultPadding),
      margin: const EdgeInsets.symmetric(vertical: defaultPadding, horizontal: 30),
      decoration: const BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: defaultPadding,
              // minWidth: 600,

              columns: [
                const DataColumn(
                  label: Text("Username"),
                )
              ],
              rows: List.generate(
                users.length,
                    (index) => recentFileDataRow(context, users[index]),
              ),
              showCheckboxColumn: false,
            ),
          ),
        ],
      ),
    );


    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        // padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            const Header(),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20 ,horizontal: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Severe Diseases",
                    // style: Theme.of(context).textTheme.titleMedium,
                    style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),

                  ),
                ],
              ),
            ),
            const SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      userW,
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  SevereDiseaseScreen(List<User> users){

    this.users = [];
    for(User user in users){
      if(user.type == "Elder"){
        this.users.add(user);
      }
    }

  }
}

class AddUser extends StatefulWidget {
  const AddUser({Key? key}) : super(key: key);

  @override
  _AddUserState createState() {
    return _AddUserState();
  }

}
class _AddUserState extends State<AddUser> {

  static List<String> options = [
    'Select',
    'Elder',
    'Caregiver',
    'Doctor'
  ];
  User user = User("", "", "", "", "", "", []);
  String selectedOption = options[0];

  bool elder_selected = false;

  @override
  Widget build(BuildContext context) {

    List<Widget> widgets;
    Map<String, String> data = Map();
    List<String> fields = ["Birthday", "Age", "Address",
      "Relative name", "Relative phone", "Relative address", "Relative email",
    ];



    if(elder_selected){
      widgets = [];
      widgets.addAll([
        TextField(
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.black,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.black,
                ),
              ),
              labelText: "Username",
              hintStyle: const TextStyle(color: Colors.black),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              )),
          onChanged: ((String username) {
            user.username = username;
          }),

        ),
        const SizedBox(
          height: 30,
        ),
        TextField(
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.black,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.black,
                ),
              ),
              labelText: "Full name",
              hintStyle: const TextStyle(color: Colors.black),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              )),
          onChanged: ((String username) {
            user.full_name = username;
          }),
        ),

        const SizedBox(
          height: 30,
        ),
        AppDropdownInput(
          hintText: "User type",
          options: options,
          value: selectedOption,
          onChanged: (String? value) {
            setState(() {
              selectedOption = value!;
              user.type = selectedOption;
              elder_selected = selectedOption == "Elder";
            });
          },
          getLabel: (String value) => value,
        ),

        const SizedBox(
          height: 30,
        ),
      ]);

      for (int i = 0; i < fields.length; i++){

        String field = fields[i];

        widgets.addAll([
          TextField(
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Colors.black,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Colors.black,
                  ),
                ),
                labelText: field,
                hintStyle: const TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                )),
            onChanged: ((String v) {
              data[field] = v;
            }),
          ),
          const SizedBox(
            height: 30,
          ),
        ]);
      }
      widgets.addAll([
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {

                if(!validate(user)) return;

                show_loading_dialog(context);

                on_success(){
                  hide_loading_dialog(context);
                  Navigator.pop(context);
                }
                on_error(){
                  Navigator.pop(context);

                }

                user.data = data;
                save_or_update_user(user, on_success, on_error);
              },
              style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  backgroundColor: Colors.amberAccent
              ),
              child: const Text(
                'Create User',
                textAlign: TextAlign.left,
                style: TextStyle(decoration: TextDecoration.none, color: Colors.black, fontSize: 18),

              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: const ButtonStyle(),
              child: const Text(
                'Cancel',
                textAlign: TextAlign.left,
                style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Color(0xff4c505b),
                    fontSize: 18),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 40,
        ),
      ]);

    }
    else{
      widgets = [
        TextField(
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.black,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.black,
                ),
              ),
              labelText: "Username",
              hintStyle: const TextStyle(color: Colors.black),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              )),
          onChanged: ((String username) {
            user.username = username;
          }),

        ),
        const SizedBox(
          height: 30,
        ),
        TextField(
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.black,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.black,
                ),
              ),
              labelText: "Full Name",
              hintStyle: const TextStyle(color: Colors.black),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              )),
          onChanged: ((String username) {
            user.full_name = username;
          }),
        ),

        const SizedBox(
          height: 30,
        ),
        AppDropdownInput(
          hintText: "User Type",
          options: options,
          value: selectedOption,
          onChanged: (String? value) {
            setState(() {
              selectedOption = value!;
              user.type = selectedOption;
              elder_selected = selectedOption == "Elder";
            });
          },
          getLabel: (String value) => value,
        ),


        const SizedBox(
          height: 30,
        ),

        TextField(
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.black,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.black,
                ),
              ),
              labelText: "Email",
              hintStyle: const TextStyle(color: Colors.black),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              )),
          onChanged: ((String username) {
            user.email = username;
          }),
        ),
        const SizedBox(
          height: 30,
        ),


        TextField(
          style: const TextStyle(color: Colors.black),
          obscureText: true,
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.black,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.black,
                ),
              ),
              labelText: "Password",
              hintStyle: const TextStyle(color: Colors.black),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              )),
          onChanged: ((String username) {
            user.password = username;
          }),
        ),
        const SizedBox(
          height: 30,
        ),

        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {

                if(!validate(user)) return;

                show_loading_dialog(context);


                on_success(){
                  hide_loading_dialog(context);
                  Navigator.pop(context);
                }
                on_error(){
                  Navigator.pop(context);
                }


                save_or_update_user(user, on_success, on_error);
              },
              style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  backgroundColor: Colors.amberAccent
              ),
              child: const Text(
                'Create User',
                textAlign: TextAlign.left,
                style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.black,
                    fontSize: 18),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              // style: const ButtonStyle(),
              style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  backgroundColor: Colors.red[600]
              ),
              child: const Text(
                'Cancel',
                textAlign: TextAlign.left,
                style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.black,
                    fontSize: 18),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 40,
        ),
      ];
    }


    return Container(

      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.amberAccent,
          elevation: 0,
        ),
        body: Stack(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 35, top: 30),
              child: const Text(
                'Create User',
                // style: TextStyle(color: Colors.black, fontSize: 33, fontWeight: FontWeight.bold,),
                style: TextStyle(color: Colors.black, fontSize: 33, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),

              ),
            ),
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 35, right: 35),
                      child: Column(
                        children: widgets,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  bool validate(User user){

    if(user.username.isEmpty){
      show_snackbar(context, "Invalid username!");
      return false;
    }
    if(user.full_name.isEmpty){
      show_snackbar(context, "Invalid full name!");
      return false;
    }

    if(user.type != "Elder") {
      if (user.email.isEmpty) {
        show_snackbar(context, "Invalid email!");
        return false;
      }
      if (!user.email.contains("@") || !user.email.contains(".")) {
        show_snackbar(context, "Invalid email!");
        return false;
      }
    }
    return true;
  }
}

class ViewUser extends StatelessWidget{

  late final User user;
  late final String title;
  late final bool profile;

  ViewUser(User? user) {
    title = user == null ? "View Profile" : "View User";
    profile = user == null;
    user ??= get_login();
    user ??= User("", "Admin", "Admin", "Admin", "Admin","Admin", []);

    this.user = user;

  }

  @override
  Widget build(BuildContext context) {

    TextEditingController un = TextEditingController();
    un.text = user.username;
    TextEditingController fn = TextEditingController();
    fn.text = user.full_name;
    TextEditingController type = TextEditingController();
    type.text = user.type;

    Widget logout;

    if(profile) {
      logout = ElevatedButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: defaultPadding * 1.5,
            vertical:
            defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
          ),
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
              builder: (context) =>
                  const Login())
          );
        },
        icon: const Icon(Icons.logout),
        label: const Text("Logout"),
      );
    }
    else{
      logout = const SizedBox(width: 0, height: 0,);
    }

    if(user.type == "Elder"){
      List<Widget> widgets;

      List<String> fields = ["Username", "Full name", "Birthday", "Age", "Address",
        "Relative name", "Relative phone", "Relative address", "Relative email",
      ];
      List<String?> values = [user.username, user.full_name, user.data?["Birthday"], user.data?["Age"], user.data?["Address"],
        user.data?["Relative name"], user.data?["Relative phone"], user.data?["Relative address"], user.data?["Relative email"],
      ];
      widgets = [];
      

      for (int i = 0; i < fields.length; i++){

        String field = fields[i];

        TextEditingController controller = TextEditingController();

        controller.text = values[i] ?? "-";

        widgets.addAll([
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Colors.white,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Colors.black,
                  ),
                ),
                labelText: field,
                hintStyle: const TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                )),
            controller: controller,
            enabled: false,
          ),
          const SizedBox(
            height: 30,
          ),
        ]);
      }


      return Container(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Stack(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 35, top: 30),
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 33),
                ),
              ),
              SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 35, right: 35),
                        child: Column(
                          children: widgets,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

    }

    return Container(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.amberAccent,
          elevation: 0,
        ),
        body: Stack(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 35, top: 30),
              child: Text(
                title,
                style: const TextStyle(color: Colors.black, fontSize: 33),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 35, right: 35),
                      child: Column(
                        children: [
                          TextField(
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.white,
                                  ),
                                ),
                                labelText: "Username",
                                hintStyle: const TextStyle(color: Colors.black),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                            enabled: false,
                            controller: un,
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          TextField(
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                labelText: "Full name",
                                hintStyle: const TextStyle(color: Colors.black),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                            enabled: false,
                            controller: fn
                          ),

                          const SizedBox(
                            height: 30,
                          ),
                          TextField(
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                labelText: "User type",
                                hintStyle: const TextStyle(color: Colors.black),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                            enabled: false,
                            controller: type,

                          ),

                          const SizedBox(
                            height: 40,
                          ),
                          logout



                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class ViewHealthStatus extends StatelessWidget{

  late final User user;
  late final String title;

  ViewHealthStatus(User? user) {
    title = "Health Status";
    if (user == null) {
      user = User("", "Admin", "Admin", "Admin", "Admin","Admin", []);
    }
    this.user = user;

  }

  DataRow recentFileDataRow(BuildContext context, HealthEntry user) {


    DataRow row = DataRow(
      cells: [
        DataCell(
          Text(user.date),
        ),
        DataCell(
          Text(user.doctor),
        )
      ],
      onSelectChanged: (bool? selected) {
        if (selected != null && selected) {
          Navigator.push(context, MaterialPageRoute(
              builder: (context) =>
                  ViewHealthEntry(user))
          );
        }
      },
    );

    return row;
  }



  @override
  Widget build(BuildContext context) {

    List<HealthEntry> entries = user.health;

    Widget userW = Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: const BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: defaultPadding,
              // minWidth: 600,
              columns: [
                const DataColumn(
                  label: Text("Date"),
                ),
                const DataColumn(
                  label: Text("Doctor"),
                )
              ],
              rows: List.generate(
                entries.length,
                    (index) => recentFileDataRow(context, entries[index]),
              ),
              showCheckboxColumn: false,
            ),
          ),
        ],
      ),
    );

    return Container(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.amberAccent,
          elevation: 0,
        ),
        body: Stack(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 35, top: 30),
              child: Text(
                title,
                style: const TextStyle(color: Colors.black, fontSize: 33),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.11
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 35, right: 35),
                      child: Column(
                        children: [
                          userW
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton:  FloatingActionButton(
          onPressed: () {

            String month = get_today().substring(0, 7);

            String message = "";

            List<HealthEntry> entries = user.health;
            for(HealthEntry entry in entries){
              String doctor = entry.doctor, date = entry.date, status = entry.status,
                  medication = entry.medication, diseases = entry.diseases;
              if(entry.date.startsWith(month)){
                message += "Date: $date\n"
                    "  Doctor: $doctor\n"
                    "  Status: $status\n"
                    "  Medication: $medication\n"
                    "  Diseases: $diseases\n"
                    "\n\n";
              }
            }

            String name = user.username;
            Share.share(message, subject: "Health report of $name for $month");
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.share),
        ),
      ),
    );
  }

}
class ViewHealthEntry extends StatelessWidget{

  late final HealthEntry user;
  late final String title;

  ViewHealthEntry(HealthEntry user) {
    title = "View Health Entry";
    this.user = user;

  }

  @override
  Widget build(BuildContext context) {

    List<Widget> widgets = [];
    List<String> titles = ["Doctor", "Date",  "Medication", "Diseases"];
    List<String> values = [user.doctor, user.date, user.medication, user.diseases];

    for (var i = 0; i < titles.length; i++) {
      TextEditingController un = TextEditingController();
      un.text = values[i];

      widgets.add(
          TextField(
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Colors.black,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Colors.black,
                  ),
                ),
                labelText: titles[i],
                hintStyle: const TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                )),
            enabled: false,
            controller: un,
          )
      );

      widgets.add(const SizedBox(
        height: 30,
      ));
    }

    return Container(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.amberAccent,
          elevation: 0,
        ),
        body: Stack(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 35, top: 30),
              child: Text(
                title,
                style: const TextStyle(color: Colors.black, fontSize: 33),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 35, right: 35),
                      child: Column(
                        children: widgets,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class ViewCare extends StatelessWidget{

  late final Care care;
  late final String title;

  ViewCare(Care? care) {
    title = "View care";
    this.care = care!;

  }

  @override
  Widget build(BuildContext context) {

    TextEditingController un = TextEditingController();
    un.text = care.name;
    TextEditingController fn = TextEditingController();
    fn.text = care.category;
    // TextEditingController type = TextEditingController();
    // type.text = care.;

    return Container(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Stack(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 35, top: 30),
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 33),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 35, right: 35),
                      child: Column(
                        children: [
                          TextField(
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.white,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                labelText: "Care name",
                                hintStyle: const TextStyle(color: Colors.white),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                            enabled: false,
                            controller: un,
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          TextField(
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.black,
                                    ),
                                  ),
                                  labelText: "Category",
                                  hintStyle: const TextStyle(color: Colors.white),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                              enabled: false,
                              controller: fn
                          ),

                          const SizedBox(
                            height: 30,
                          ),

                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 35, right: 35),
                      child: Column(

                        children: [
                          Align(
                            alignment: Alignment.bottomRight,
                            child: FloatingActionButton(
                              onPressed: () {
                                editing_care = care;
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) =>
                                        const EditCare())
                                );
                              },
                              backgroundColor: Colors.green,
                              child: const Icon(Icons.edit),
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: FloatingActionButton(
                              onPressed: () {
                                show_loading_dialog(context);

                                on_success(){
                                  Navigator.of(context, rootNavigator: true).pop('dialog');
                                  Navigator.pop(context);
                                }
                                on_error(){
                                  Navigator.pop(context);
                                }

                                delete_care(care, on_success, on_error);
                              },
                              backgroundColor: Colors.red,
                              child: const Icon(Icons.delete),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

      ),
    );
  }

}
class AddCare extends StatefulWidget {
  const AddCare({Key? key}) : super(key: key);

  @override
  _AddCareState createState() {
    return _AddCareState();
  }

}
class _AddCareState extends State<AddCare> {

  static List<String> options = [
    'Nutrition care',
    'Personal care',
    'Personal safety and environment',
    'Activities'
  ];
  Care care = Care("", "", options[0], "");
  String selectedOption = options[0];

  @override
  Widget build(BuildContext context) {
    return Container(

      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.amberAccent,
          elevation: 0,
        ),
        body: Stack(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 35, top: 30),
              child: const Text(
                'Create Care',
                // style: TextStyle(color: Colors.black, fontSize: 33),
                style: TextStyle(color: Colors.black, fontSize: 33, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),

              ),
            ),
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 35, right: 35),
                      child: Column(
                        children: [
                          TextField(
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                labelText: "Carename",
                                hintStyle: const TextStyle(color: Colors.black),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                            onChanged: ((String carename) {
                              care.name = carename;
                            }),

                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          AppDropdownInput(
                            hintText: "Category",
                            options: options,
                            value: selectedOption,
                            onChanged: (String? value) {
                              setState(() {
                                selectedOption = value!;
                                care.category = selectedOption;
                              });
                            },
                            getLabel: (String value) => value,
                          ),
                          SizedBox(height: 20),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  show_loading_dialog(context);

                                  on_success(){
                                    Navigator.of(context, rootNavigator: true).pop('dialog');
                                    Navigator.pop(context);
                                  }
                                  on_error(){
                                    Navigator.pop(context);

                                  }

                                  create_care(care, on_success, on_error);
                                },
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                    backgroundColor: Colors.amberAccent
                                ),
                                child: const Text(
                                  'Create Care',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      decoration: TextDecoration.none,
                                      color: Colors.black,
                                      fontSize: 18),
                                ),
                              ),



                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                // style: const ButtonStyle(),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  backgroundColor: Colors.red[600]
                                ),
                                child: const Text(
                                  'Cancel',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      decoration: TextDecoration.none,
                                      color: Colors.black,
                                      fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Care editing_care = Care("", "", "", "");

class EditCare extends StatefulWidget {
  const EditCare({Key? key}) : super(key: key);

  @override
  _EditCareState createState() {
    return _EditCareState();
  }

}
class _EditCareState extends State<EditCare> {

  static List<String> options = [
    'Select',
    'Elder',
    'Caregiver',
    'Doctor'
  ];
  Care care = editing_care;
  String selectedOption = options[0];

  TextEditingController? name_controller, category_controller;

  @override
  void initState() {
    super.initState();
    name_controller = new TextEditingController(text: care.name);
    category_controller = new TextEditingController(text: care.category);
  }

  @override
  Widget build(BuildContext context) {
    return Container(

      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.amberAccent,
          elevation: 0,
        ),
        body: Stack(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 35, top: 30),
              child: const Text(
                'Edit Care',
                style: TextStyle(color: Colors.black, fontSize: 33),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 35, right: 35),
                      child: Column(
                        children: [
                          TextField(
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                labelText: "Carename",
                                hintStyle: const TextStyle(color: Colors.black),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                            onChanged: ((String carename) {
                              care.name = carename;
                            }),
                            controller: name_controller,

                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          TextField(
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                labelText: "Category",
                                hintStyle: const TextStyle(color: Colors.black),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                            onChanged: ((String carename) {
                              care.category = carename;
                            }),
                            controller: category_controller,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  show_loading_dialog(context);

                                  on_success(){
                                    Navigator.of(context, rootNavigator: true).pop('dialog');
                                    Navigator.pop(context);
                                  }
                                  on_error(){
                                    Navigator.pop(context);
                                  }

                                  edit_care(care, on_success, on_error);
                                },
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                    backgroundColor: Colors.amberAccent
                                ),
                                child: const Text(
                                  'Update care',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Colors.white,
                                      fontSize: 18),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: const ButtonStyle(),
                                child: const Text(
                                  'Cancel',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      decoration: TextDecoration.none,
                                      color: Color(0xff4c505b),
                                      fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.amberAccent,
      child: Row(
        children: [
          if (!Responsive.isDesktop(context))
            IconButton(
              icon: const Icon(Icons.menu,
                  color: Colors.black
              ),
              onPressed: context.read<MenuAppController>().controlMenu,
            ),

          if (!Responsive.isMobile(context))
            Text(
              "Dashboard",
              style: Theme.of(context).textTheme.titleLarge,
            ),

          if (!Responsive.isMobile(context))
            Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
          const Expanded(child: SizedBox(),),
          const ProfileCard()
        ],
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: defaultPadding),
      padding: const EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding,
      ),
      // decoration: BoxDecoration(
      //   color: Colors.grey,
      //   borderRadius: const BorderRadius.all(Radius.circular(10)),
      //   border: Border.all(color: Colors.white10),
      // ),
      child: Row(
        children: [
          GestureDetector(
            child:const Icon(Icons.person,
              color: Colors.black,
            ),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) =>
                      ViewUser(null))
              );
            },
          )

        ],

      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search",
        fillColor: secondaryColor,
        filled: true,
        border: const OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        suffixIcon: InkWell(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(defaultPadding * 0.75),
            margin: const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: SvgPicture.asset("assets/icons/Search.svg"),
          ),
        ),
      ),
    );
  }
}

class MenuAppController extends ChangeNotifier {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;

  void controlMenu() {
    if (!_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.openDrawer();
    }
  }
}

//New
class ViewCompletedCare extends StatelessWidget{

  late final User user;
  late final List<Care> cares;
  late final DateTime from;
  late final  DateTime to;

  ViewCompletedCare(User? user, List<Care> cares, DateTime from, DateTime to) {
    this.from = from;
    this.to = to;
    if (user == null) {
      user = User("", "Admin", "Admin", "Admin", "Admin","Admin", []);
    }
    this.user = user;
    this.cares = cares;
  }

  DataRow recentFileDataRow(BuildContext context, Care user) {


    DataRow row = DataRow(
      cells: [
        DataCell(
          Text(user.time),
        ),
        DataCell(
          Text(user.name),
        )
      ],
    );

    return row;
  }



  @override
  Widget build(BuildContext context) {

    List<Care> entries = cares;

    Widget userW = Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: const BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: defaultPadding,
              // minWidth: 600,
              columns: [
                const DataColumn(
                  label: Text("Date"),
                ),
                const DataColumn(
                  label: Text("Care"),
                )
              ],
              rows: List.generate(
                entries.length,
                    (index) => recentFileDataRow(context, entries[index]),
              ),
              showCheckboxColumn: false,
            ),
          ),
        ],
      ),
    );

    return Container(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.amberAccent,
          elevation: 0,
        ),
        body: Stack(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 35, top: 30),
              child: Text(
                "Completed Cares Of " "\n" + user.full_name + "\n" + from.toString().split(" ")[0]+ " - " + to.toString().split(" ")[0],
                style: const TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.26
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 35, right: 35),
                      child: Column(
                        children: [
                          userW
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton:  FloatingActionButton(
          onPressed: () {

            String month = get_today().substring(0, 7);

            String message = "";

            List<Care> entries = cares;
            for(Care entry in entries){
              message += entry.time + "   " + entry.name + "\n";
            }

            String name = user.username;

            message = "Completed cares of $name on $from\n\n" + message;
            Share.share(message, subject: "Completed cares of $name on $from");
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.share),
        ),
      ),
    );
  }

}
class ViewSevereDiseases extends StatelessWidget{

  late final User user;
  late final String title;

  ViewSevereDiseases(User? user) {
    title = "Severe Diseases";

    if (user == null) {
      user = User("", "Admin", "Admin", "Admin", "Admin","Admin", []);
    }
    this.user = user;

  }

  DataRow recentFileDataRow(BuildContext context, HealthEntry user) {


    DataRow row = DataRow(
      cells: [
        DataCell(
          Text(user.date),
        ),
        DataCell(
          Text(user.diseases),
        )
      ],
      onSelectChanged: (bool? selected) {
        if (selected != null && selected) {
          Navigator.push(context, MaterialPageRoute(
              builder: (context) =>
                  ViewHealthEntry(user))
          );
        }
      },
    );

    return row;
  }

  @override
  Widget build(BuildContext context) {

    List<HealthEntry> entries = [];
    List<HealthEntry> es = user.health;

    for(HealthEntry entry in es){
      if(entry.status == "Severe") entries.add(entry);
    }

    Widget userW = Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: const BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: defaultPadding,
              // minWidth: 600,
              columns: [
                const DataColumn(
                  label: Text("Date"),
                ),
                const DataColumn(
                  label: Text("Disease"),
                )
              ],
              rows: List.generate(
                entries.length,
                    (index) => recentFileDataRow(context, entries[index]),
              ),
              showCheckboxColumn: false,
            ),
          ),
        ],
      ),
    );

    return Container(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.amberAccent,
          elevation: 0,
        ),
        body: Stack(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 35, top: 30),
              child: Text(
                title,
                style: const TextStyle(color: Colors.black, fontSize: 33),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.11
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 35, right: 35),
                      child: Column(
                        children: [
                          userW
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton:  Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                String message = "";

                for(HealthEntry entry in entries){
                  String doctor = entry.doctor, date = entry.date, status = entry.status,
                      medication = entry.medication, diseases = entry.diseases;
                  message += "Date: $date\n"
                      "  Doctor: $doctor\n"
                      "  Status: $status\n"
                      "  Medication: $medication\n"
                      "  Diseases: $diseases\n"
                      "\n\n";
                }

                String name = user.username;
                message = "Severe diseases of $name\n\n" + message;
                String email = user.data?['Relative email'] ?? "";

                String url = 'mailto:$email?subject=Severe diseases of $name\n\n&body=$message';
                launch(url);
                // Share.share(message, subject: "Severe diseases of $name");
              },
              backgroundColor: Colors.blueAccent,
              child: const Icon(Icons.mail),
            ),
            SizedBox(height: 12,),
            FloatingActionButton(
              onPressed: () {
                String message = "";

                for(HealthEntry entry in entries){
                  String doctor = entry.doctor, date = entry.date, status = entry.status,
                      medication = entry.medication, diseases = entry.diseases;
                  message += "Date: $date\n"
                      "  Doctor: $doctor\n"
                      "  Status: $status\n"
                      "  Medication: $medication\n"
                      "  Diseases: $diseases\n"
                      "\n\n";
                }

                String name = user.username;
                message = "Severe diseases of $name\n\n" + message;
                String email = user.data?['Relative email'] ?? "";

                String url = 'mailto:$email?subject=Severe diseases of $name\n\n&body=$message';
                Share.share(message, subject: "Severe diseases of $name");
              },
              backgroundColor: Colors.green,
              child: const Icon(Icons.share),
            ),
          ],
        ),
/*
        floatingActionButton:  FloatingActionButton(
          onPressed: () {
            String message = "";

            for(HealthEntry entry in entries){
              String doctor = entry.doctor, date = entry.date, status = entry.status,
                  medication = entry.medication, diseases = entry.diseases;
                  message += "Date: $date\n"
                      "  Doctor: $doctor\n"
                      "  Status: $status\n"
                      "  Medication: $medication\n"
                      "  Diseases: $diseases\n"
                      "\n\n";
            }

            String name = user.username;
            message = "Severe diseases of $name\n\n" + message;
            String email = user.data?['Relative email'] ?? "";

            String url = 'mailto:$email?subject=Severe diseases of $name\n\n&body=$message';
            launch(url);
            // Share.share(message, subject: "Severe diseases of $name");
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.share),
        ),
*/
      ),
    );
  }

}

