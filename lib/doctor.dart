// ignore_for_file: non_constant_identifier_names

import 'package:elder/admin/constants.dart';
import 'package:elder/entity.dart';
import 'package:elder/functions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:elder/admin/responsive.dart';
import 'package:flutter_svg/svg.dart';

import 'auth/login.dart';

class DoctorHome extends StatelessWidget {
  const DoctorHome({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Doctor',
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
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Screen(),
            ),
          ],
        ),
      ),
    );
  }
}


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

  Future<void> load() async {
    List<User> u = await get_users();

    setState(() {
      users = u;
    });




  }


  @override
  Widget build(BuildContext context) {
    return HealthScreen(users);
  }

  _Screen(){
    load();
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
        colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
        height: 16,
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}

class HealthScreen extends StatelessWidget {
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
                  ViewHealthStatus(user))
          );
        }
      },
    );



    return row;
  }

  @override
  Widget build(BuildContext context) {

    List<User> u = [];
    for(User user in users){
      if(user.type == "Elder"){
        u.add(user);
      }
    }

    Widget userW = Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Colors.grey,
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
                  label: Text("Username"),
                )
              ],
              rows: List.generate(
                u.length,
                    (index) => recentFileDataRow(context, u[index]),
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
                  "Health Status",
                  // style: Theme.of(context).textTheme.titleMedium,
                  style: TextStyle(color: Colors.black, fontSize: 33, fontWeight: FontWeight.bold, decoration: TextDecoration.underline,
                  ),

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

  HealthScreen(this.users);
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
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Colors.grey,
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
                  label: Text("Date"),
                ),
                DataColumn(
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
              padding: EdgeInsets.only(left: 35, top: 30),
              child: Text(
                title,
                style: TextStyle(color: Colors.black, fontSize: 33),
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
                      margin: EdgeInsets.only(left: 35, right: 35),
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  String a = get_login()?.full_name ?? "";

                  return AddHealthEntry(user: user, entry: HealthEntry(a, get_today(), get_time(), "", "", ""));
                }
            )
            );
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

}

class AddHealthEntry extends StatefulWidget {
  final User user;
  final HealthEntry entry;

  AddHealthEntry({required this.user, required this.entry});

  @override
  _AddHealthEntryState createState() => _AddHealthEntryState();
}
class _AddHealthEntryState extends State<AddHealthEntry> {
  late final String title;
  late List<TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    title = "Add Health Entry";
    controllers = [
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ];

    for (int i = 0; i < controllers.length; i++) {
      controllers[i].text = getFieldByIndex(i);
    }
  }

  String getFieldByIndex(int index) {
    switch (index) {
      case 0:
        return widget.entry.doctor;
      case 1:
        return widget.entry.date;
      case 2:
        return widget.entry.time;
      case 3:
        return widget.entry.diseases;
      case 4:
        return widget.entry.medication;
      default:
        return '';
    }
  }

  void updateEntry(int index, String value) {
    switch (index) {
      case 0:
        widget.entry.doctor = value;
        break;
      case 1:
        widget.entry.date = value;
        break;
      case 2:
        widget.entry.time = value;
        break;
      case 3:
        widget.entry.diseases = value;
        break;
      case 4:
        widget.entry.medication = value;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    List<String> titles = ["Doctor", "Date", "Time", "Diseases", "Medication"];

    for (var i = 0; i < titles.length; i++) {
      final int j = i;
      widgets.add(
        TextField(
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.black),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.black),
            ),
            labelText: titles[i],
            hintStyle: TextStyle(color: Colors.black),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          enabled: j > 2,
          controller: controllers[j],
          onChanged: (String v) {
            // controllers[j].text = v;
            updateEntry(j, v);

          },
        ),
      );

      widgets.add(SizedBox(
        height: 30,
      ));
    }

    widgets.add(CheckboxListTile(
      title: const Text("Severe disease"),
      value: widget.entry.status == "Severe",
      onChanged: (newValue) {
        setState(() {
          if (newValue != null && newValue) {
            widget.entry.status = "Severe";
          } else {
            widget.entry.status = "Non severe";
          }
        });
      },
    ));

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
              padding: EdgeInsets.only(left: 35, top: 30),
              child: Text(
                title,
                style: TextStyle(color: Colors.black, fontSize: 33),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.22,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 35, right: 35),
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            widget.user.health.add(widget.entry);

            save_health_entry(
              widget.user.id,
              widget.user.health.length - 1,
              widget.entry,
                  () {},
                  () {},
            );
            Navigator.of(context).pop();
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.save),
        ),
      ),
    );
  }
}

class ViewHealthEntry extends StatelessWidget{

  late final HealthEntry entry;
  late final String title;

  ViewHealthEntry(HealthEntry user) {
    title = "View Health Entry";
    this.entry = user;

  }

  @override
  Widget build(BuildContext context) {

    List<Widget> widgets = [];
    List<String> titles = ["Doctor", "Date", "Time",  "Medication", "Diseases", "Status", ];
    List<String> values = [entry.doctor, entry.date, entry.time, entry.medication, entry.diseases, entry.status == "Severe" ? "Severe" : "Non severe", ];

    for (var i = 0; i < titles.length; i++) {
      TextEditingController un = TextEditingController();
      un.text = values[i];

      widgets.add(
          TextField(
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                ),
                labelText: titles[i],
                hintStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                )),
            enabled: false,
            controller: un,
          )
      );

      widgets.add(SizedBox(
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
              padding: EdgeInsets.only(left: 35, top: 30),
              child: Text(
                title,
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
                      margin: EdgeInsets.only(left: 35, right: 35),
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

class Header extends StatelessWidget {
  const Header({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
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
      margin: EdgeInsets.only(left: defaultPadding),
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding / 2,
      ),
      child: Row(
        children: [
          GestureDetector(
            child:Icon(Icons.person),
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
        fillColor: Colors.grey,
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        suffixIcon: InkWell(
          onTap: () {},
          child: Container(
            padding: EdgeInsets.all(defaultPadding * 0.75),
            margin: EdgeInsets.symmetric(horizontal: defaultPadding / 2),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
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
                  Login())
          );
        },
        icon: Icon(Icons.logout),
        label: Text("Logout"),
      );
    }else{
      logout = const SizedBox(width: 0, height: 0,);
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
              padding: EdgeInsets.only(left: 35, top: 30),
              child: Text(
                title,
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
                      margin: EdgeInsets.only(left: 35, right: 35),
                      child: Column(
                        children: [
                          TextField(
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                labelText: "Username",
                                hintStyle: TextStyle(color: Colors.black),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                            enabled: false,
                            controller: un,
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          TextField(
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                    ),
                                  ),
                                  labelText: "Full name",
                                  hintStyle: TextStyle(color: Colors.black),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                              enabled: false,
                              controller: fn
                          ),

                          SizedBox(
                            height: 30,
                          ),
                          TextField(
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                labelText: "User type",
                                hintStyle: TextStyle(color: Colors.black),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                            enabled: false,
                            controller: type,

                          ),

                          SizedBox(
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
