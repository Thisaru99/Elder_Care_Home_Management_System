import 'dart:collection';
import 'dart:convert';

import 'package:elder/admin/constants.dart';
import 'package:elder/entity.dart';
import 'package:elder/functions.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';


import 'package:flutter_svg/svg.dart';

import 'admin/admin.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'admin/responsive.dart';
import 'auth/login.dart';

class CareGiver extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Care giver',
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
          child: const Dashboard(),
        ),

      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      body: const SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
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

List<User> users = [];
List<Care> cares = [];


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

  Future<void> load() async {
    List<User> u = await get_users();

    try{
      List<Care> c = await get_cares();
      setState(() {
        cares = c;
      });
    }catch(e){/**/}

    setState(() {
      users = u;
    });

  }


  @override
  Widget build(BuildContext context) {
    List<User> u = [];
    for (var value in users) {
      if (value.type == "Elder"){
        u.add(value);
      }
    }

    return SelectElderScreen(u);
  }

  void callSetState() {
    setState((){});
  }

  _Screen(){
    load();
  }
}


class DashboardScreen extends StatelessWidget {

  final User user;

  @override
  Widget build(BuildContext context) {

    Widget widget = Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: const BoxDecoration(
        // color: bgColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(

            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => ViewUser(user))
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.amberAccent),
                  padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.fromLTRB(64, 12, 64, 12)),
                ),
                child: const Text(
                  'View Elder Details',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
              const SizedBox(
                height: 16,
              ),

              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) =>
                          ViewCaresScreen(cares))
                  );

                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.amberAccent),
                  padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.fromLTRB(74, 12, 74, 12)),
                ),

                child: const Text(
                  'View All Cares',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
              const SizedBox(
                height: 16,
              ),

              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) =>
                          MarkCaresScreen(user: user, key: key, cares: cares,))
                  );

                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.amberAccent),
                  padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.fromLTRB(64, 12, 64, 12)),
                ),

                child: const Text(
                  'Mark Today Cares',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
            ],
          )
        ],
      ),
    );


    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          primary: false,
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            children: [

              const SizedBox(height: defaultPadding),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        widget,
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      appBar: AppBar(
        leading: const BackButton(),
        backgroundColor: Colors.amberAccent,
        title: const Text("Caregiver Dashboard"),
        elevation: 0,
        actions: [],
      ),
    );

  }

  DashboardScreen(this.user);
}
class SelectElderScreen extends StatelessWidget {
  final List<User> users;

  @override
  Widget build(BuildContext context) {

    Widget widget = Container(
      // padding: const EdgeInsets.all(defaultPadding),
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
              headingRowHeight: 0,
              dividerThickness: double.minPositive,
              columns: [
                DataColumn(
                  label: Container(),
                ),
              ],
              rows: List.generate(
                users.length,
                    (index) {
                      User user = users[index];
                      return DataRow(
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
                          ),
                        ],
                        onSelectChanged: (bool? selected) {
                          if (selected != null && selected) {

                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return DashboardScreen(user);
                            }));
                          }
                        },
                      );
                    },
              ),
              showCheckboxColumn: false,
            ),
          ),
        ],
      ),
    );


    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          primary: false,
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            children: [

              const SizedBox(height: defaultPadding),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        widget,
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      appBar: AppBar(
        leading: const BackButton(),
        backgroundColor: Colors.amberAccent,
        title: const Text("Select Your Elder"),
        elevation: 0,
        actions: [
          GestureDetector(
            child:const Icon(Icons.person),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) =>
                      ViewUser(null))
              );
            },
          ),
          SizedBox(
            width: 12,
          )
        ],

      ),
    );

  }

  SelectElderScreen(this.users);
}

class ViewCaresScreen extends StatelessWidget {
  final List<Care> cares;



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

    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
            primary: false,
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              children: [

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
        ),
      appBar: AppBar(
        leading: const BackButton(),
        backgroundColor: Colors.amberAccent,
        title: const Text("View All Cares"),
        elevation: 0,
        actions: [],
      ),
    );

  }

  DataRow recentFileDataRow(BuildContext context, Care care) {


    DataRow row = DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              const Icon(Icons.accessible_outlined),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Text(care.name),
              ),
            ],
          ),
        ),
      ],
      onSelectChanged: (bool? selected) {
        if (selected != null && selected) {

        }
      },
    );



    return row;
  }
  Widget get_care_widget(BuildContext context, String category, List<Care> cares) {
    Widget widget = Container(
      padding: const EdgeInsets.all(defaultPadding),
      margin: const EdgeInsets.all(defaultPadding),
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

  ViewCaresScreen(this.cares);
}

class MarkCaresScreen extends StatefulWidget {

  final User user;
  final List<Care> cares;
  const MarkCaresScreen({
    super.key, required this.user, required this.cares,
  });

  @override
  State<StatefulWidget> createState() => _MarkCaresScreen();

}
class _MarkCaresScreen extends State<MarkCaresScreen> {

  final Map<Care, bool> marked = Map();
  final Map<String, String> times = Map();


  _MarkCaresScreen();

  show_notifications(){

  }


  @override
  void initState() {
    super.initState();
    User user = widget.user;
    List<Care> cares = widget.cares;

    load() async {
      Map<String, dynamic> map = await get_reminders(user.id, () {}, () {});

      setState(() {
        for(Care care in cares){
          if(map.containsKey(care.id)){
            try{
              times[care.id] = map[care.id]['time'];
            }catch(e){}

            try{
              if (map[care.id]['status']) {
                marked[care] = true;
              }
            }catch(e){}

          }
        }
      });
    }

    load();

    for(Care care in cares){
      marked[care] = false;
    }
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
      List<Care>? cares = care_map[key];
      if (cares != null) {
        Widget widget = get_care_widget(context, key, cares);
        widgets.add(widget);
      }
    }





    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          primary: false,
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            children: [

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
      ),
      appBar: AppBar(
        leading: const BackButton(),
        backgroundColor: Colors.amberAccent,
        title: const Text("Mark Today's Cares"),
        elevation: 0,
        actions: [],
      ),
    );

  }

  Widget get_care_widget(BuildContext context, String category, List<Care> cares) {


    Widget widget = Container(
      padding: const EdgeInsets.all(defaultPadding),
      margin: const EdgeInsets.all(defaultPadding),
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
                DataColumn(
                  label: Container(),
                ),
                DataColumn(
                  label: Container(),
                ),
              ],
              rows: List.generate(
                cares.length,
                    (index) {
                      Care care = cares[index];

                      DataRow row = get_row(care);

                      return row;
                    },
              ),
              showCheckboxColumn: false,
            ),
          ),
        ],
      ),
    );
    return widget;
  }

  empty(){
  }

  DataRow get_row(Care care) {

      return DataRow(
        cells: [
          DataCell(
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: Text(care.name),
                ),
              ],
            ),
          ),
          DataCell(
              IconButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          String time = "";

                          try{
                            time = times[care.id]!;
                          }catch(e){}

                          return UpdateReminders(patient: widget.user, care: care, times: time,);
                        })
                    );

                  },
                  icon: const Icon(Icons.alarm)
              ),
          ),
          DataCell(
              Checkbox(value: marked[care],
                onChanged: (bool? value){
                  setState(() {
                    if(value != null) {
                      marked[care] = value;
                      save_or_update_status(widget.user.id, care.id, value, empty, empty);
                    }
                  });
                },)
          ),
        ],
        onSelectChanged: (bool? selected) {
          if (selected != null && selected) {

          }
        },
      );
    }



}

class UpdateReminders extends StatefulWidget {
  final String times;
  final User patient;
  final Care care;

  const UpdateReminders({super.key, required this.patient, required this.care, required this.times});

  @override
  _UpdateRemindersState createState() {
    return _UpdateRemindersState();
  }

}
class _UpdateRemindersState extends State<UpdateReminders> {

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    List<String> times = ["", "", "", "", "", ""];
    try{
      List<String> splits = widget.times.split(",");
      for (var i = 0; i < 5; i++){
        times[i] = splits[i];
      }
    }catch(e){}


    for (var i = 0; i < 5; i++){

      TextEditingController controller = TextEditingController();
      controller.text = times[i];

      widgets.add(
        TextField(
          readOnly: true,
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
              labelText: "Reminder ${i + 1}",
              hintStyle: const TextStyle(color: Colors.black),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              suffixIcon: IconButton(
                onPressed: () async {
                  controller.text = "";

                  Future<TimeOfDay?> selectedTime = showTimePicker(
                    initialTime: TimeOfDay.now(),
                    context: context,
                  );

                  add_zero(int number){
                    if (number < 10) return "0$number";
                    return "$number";
                  }

                  TimeOfDay? time = await selectedTime;
                  if (time != null){
                    String t = "${add_zero(time.hour)}:${add_zero(time.minute)}";
                    times[i] = t;
                    controller.text = t;
                  }

                },
                icon: const Icon(Icons.alarm),
              ),

          ),
          controller: controller,
        ),
      );

      widgets.add(
        const SizedBox(
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
              child: const Text(
                'Update Reminders!',
                style: TextStyle(color: Colors.black, fontSize: 33, fontWeight: FontWeight.bold),
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
        floatingActionButton: FloatingActionButton(
          child: new Icon(Icons.save),
          onPressed: (){
            String a = "";
            for (var i = 0; i < 5; i++){
              a += times[i];
              if (i != 4){
                a += ",";
              }
            }

            save(a);

            save_or_update_reminder(widget.patient.id, widget.care.id, a, (){
              Navigator.pop(context);
            }, (){});

          },
        ),
      ),
    );
  }

  void save(String data) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String today = get_today();
    preferences.setString("$today.times", data);
    preferences.setString("$today.elder", widget.patient.full_name);
    preferences.setString("$today.care", widget.care.name);

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
                  const Login())
          );
        },
        icon: const Icon(Icons.logout),
        label: const Text("Logout"),
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
    }else{
      logout = const SizedBox(width: 0, height: 0,);
    }

    List<Widget> widgets;

    List<String> fields = ["Username", "Full name", "Birthday", "Age", "Address",
      "Relative name", "Relative phone", "Relative address", "Relative email",
    ];
    List<String?> values = [user.username, user.full_name, user.data?["Birthday"], user.data?["Age"], user.data?["Address"],
      user.data?["Relative name"], user.data?["Relative phone"], user.data?["Relative address"], user.data?["Relative email"],
    ];
    widgets = [];

    print(jsonEncode(user));

    for (int i = 0; i < fields.length; i++){

      String field = fields[i];

      TextEditingController controller = TextEditingController();

      controller.text = values[i] ?? "-";

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
