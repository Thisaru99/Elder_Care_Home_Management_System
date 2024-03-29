
import 'package:elder/admin/admin.dart';
import 'package:elder/care_giver.dart';
import 'package:elder/entity.dart';
import 'package:elder/functions.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../doctor.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}
class _LoginState extends State<Login> {
  bool isChecked = false;
  TextEditingController email_controller = TextEditingController();
  TextEditingController password_controller = TextEditingController();


  late Box box1;

  @override
  void initState() {
    //
    super.initState();
    createBox();

  }

  void createBox() async {
    box1 = await Hive.openBox('logininfo');
    getdata();
  }
  void getdata()async {
    if (box1.get('email') != null) {
      email_controller.text = box1.get('email');
      isChecked = true;
      setState(() {

      });
    }
    if (box1.get('password') != null) {
      password_controller.text = box1.get('password');
      isChecked = true;
      setState(() {

      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(

      child: Scaffold(
        backgroundColor: Colors.amberAccent,
        body: Stack(
          children: [
            Container(),
            Container(
              padding: EdgeInsets.only(left: 90, top: 130),
              child: Text(
              'Care Zone\nWelcome Back',
                style: TextStyle( color: Colors.black, fontSize: 33, fontWeight: FontWeight.bold,),
              ),
            ),

            SizedBox(width: 10), // Adjust the width based on your spacing preference
            Image.asset('assets/images/care.PNG', // Replace with the actual path to your PNG image
              height: 50, // Adjust the height as needed
              width: 50,  // Adjust the width as needed
            ),

            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    top: MediaQuery
                        .of(context)
                        .size
                        .height * 0.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 35, right: 35),
                      child: Column(
                        children: [
                          TextField(
                            controller: email_controller,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                                fillColor: Colors.grey.shade100,
                                filled: true,
                                labelText: "Email",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          TextField(
                            controller: password_controller,
                            style: TextStyle(),
                            obscureText: true,
                            decoration: InputDecoration(
                                fillColor: Colors.grey.shade100,
                                filled: true,
                                labelText: "Password",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                          ),
                          SizedBox(
                            height: 40,
                          ),


                          Row(
                            mainAxisAlignment: MainAxisAlignment.center, // Center the button horizontally
                            children: [
                              Container(
                                width: 120,  // Adjust the width and height to make it a square
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Color(0xffa9a9a9),
                                  borderRadius: BorderRadius.circular(10), // Optional: Add rounded corners
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    login();
                                  },
                                  child: Text(
                                    'Sign In',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),




                          SizedBox(
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

  Future<void> login() async {

    String email = email_controller.text;
    String pass = password_controller.text;

    List<User> users = await get_users();
    for (User user in users) {

      if(user.email.toLowerCase() == email.toLowerCase()){

        set_login(user);

        if(user.password == pass){
          if (user.email.toLowerCase() == "hmrnxt@gmail.com".toLowerCase()){
            user.type = "Admin";
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
              return const AdminHome();
            }));

          }
          else if (user.type.toLowerCase() == "caregiver"){
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
              return CareGiver();
            }));
          }
          else if (user.type.toLowerCase() == "doctor"){
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
              return const DoctorHome();
            }));
          }

        }
        else{
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Invalid password!"),
          ));
        }

        return;
      }

    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Invalid email!"),
    ));

  }
}
