import 'dart:convert';

import 'package:elder/entity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

User? login;

Future<void> save_or_update_user(User user, on_success, on_error) async {


  
  final headers = {'Content-Type': 'application/json'};

  String jsonBody = json.encode(user.toJson());
  final encoding = Encoding.getByName('utf-8');

  if(user.id.length > 1){
    String url = "https://app-elder-care-default-rtdb.firebaseio.com/user/${user.id}.json";
    final uri = Uri.parse(url);
    
    Response response = await put(
      uri,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );
    on_success();
    return;
  }

  String url = "https://app-elder-care-default-rtdb.firebaseio.com/user.json";
  final uri = Uri.parse(url);
  
  Response response = await post(
    uri,
    headers: headers,
    body: jsonBody,
    encoding: encoding,
  );

  int statusCode = response.statusCode;
  String responseBody = response.body;
  String id = json.decode(responseBody)['name'];
  user.id = id;

  response = await put(
    Uri.parse("https://app-elder-care-default-rtdb.firebaseio.com/user/" + id + "/id.json"),
    headers: headers,
    body: json.encode(id),
    encoding: encoding,
  );

  on_success();
}
Future<List<User>> get_users() async {
  String url = "https://app-elder-care-default-rtdb.firebaseio.com/user.json";

  final uri = Uri.parse(url);
  final headers = {'Content-Type': 'application/json'};

  Response response = await get(
    uri,
    headers: headers,
  );

  List<User> users = [];
  Map<String, dynamic> data = jsonDecode(response.body);
  List<dynamic> d = List<dynamic>.from(data.entries);
  for (var v in d) {
    var entry = v as MapEntry<String, dynamic>;
    Map<String, dynamic> value = entry.value;

    User user = User(value['id'], value['username'], value['full_name'], value['email'], value['password'], value['type'], []);

    var a = value['details'];
    if (a != null) {
      print('Not null');
      Map<String, dynamic> details = value['details'];
      print(details);
      user.data = details.cast<String, String>();
    }
    if (value.containsKey('health')){
      List<dynamic> h = value['health'];
      List<HealthEntry> entries = [];
      for (var ent in h) {
        Map<String, dynamic> entr = ent;

        if (entr['time'] == null){
          entr['time'] = "00:00";
        }

        entries.add(HealthEntry(entr['doctor'], entr['date'], entr['time'], entr['status'], entr['medication'], entr['diseases']));
      }
      user.health = entries;
    }
    users.add(user);
  }

  return users;
}

Future<void> create_care(Care care, on_success, on_error) async {

  String url = "https://app-elder-care-default-rtdb.firebaseio.com/care.json";

  final uri = Uri.parse(url);
  final headers = {'Content-Type': 'application/json'};
  Map<String, dynamic> body = {'id': 21, 'name': 'bob'};
  String jsonBody = json.encode(care.toJson());
  final encoding = Encoding.getByName('utf-8');

  Response response = await post(
    uri,
    headers: headers,
    body: jsonBody,
    encoding: encoding,
  );

  int statusCode = response.statusCode;
  String responseBody = response.body;
  String id = json.decode(responseBody)['name'];
  care.id = id;

  response = await put(
    Uri.parse("https://app-elder-care-default-rtdb.firebaseio.com/care/" + id + "/id.json"),
    headers: headers,
    body: json.encode(id),
    encoding: encoding,
  );

  on_success();
}
Future<void> edit_care(Care care, on_success, on_error) async {

  String url = "https://app-elder-care-default-rtdb.firebaseio.com/care/${care.id}.json";

  final uri = Uri.parse(url);
  final headers = {'Content-Type': 'application/json'};
  Map<String, dynamic> body = {'id': 21, 'name': 'bob'};
  String jsonBody = json.encode(care.toJson());
  final encoding = Encoding.getByName('utf-8');

  Response response = await put(
    uri,
    headers: headers,
    body: jsonBody,
    encoding: encoding,
  );

  on_success();
}
Future<void> delete_care(Care care, on_success, on_error) async {

  String url = "https://app-elder-care-default-rtdb.firebaseio.com/care/${care.id}.json";

  final uri = Uri.parse(url);
  final headers = {'Content-Type': 'application/json'};
  Map<String, dynamic> body = {'id': 21, 'name': 'bob'};
  String jsonBody = json.encode(care.toJson());
  final encoding = Encoding.getByName('utf-8');

  Response response = await delete(
    uri,
    headers: headers,
    encoding: encoding,
  );

  on_success();
}
Future<List<Care>> get_cares() async {
  String url = "https://app-elder-care-default-rtdb.firebaseio.com/care.json";

  final uri = Uri.parse(url);
  final headers = {'Content-Type': 'application/json'};

  Response response = await get(
    uri,
    headers: headers,
  );

  List<Care> cares = [];
  Map<String, dynamic> data = jsonDecode(response.body);
  List<dynamic> d = List<dynamic>.from(data.entries);
  for (var v in d) {
    var entry = v as MapEntry<String, dynamic>;
    Map<String, dynamic> value = entry.value;

    Care care = Care(value['id'], value['name'], value['category'], value['image']);
    cares.add(care);
  }

  return cares;
}

Future<Map<String, dynamic>> get_reminders(String patient, on_success, on_error) async {

  final headers = {'Content-Type': 'application/json'};

  String today = get_today();

  String url = "https://app-elder-care-default-rtdb.firebaseio.com/reminder/$today/$patient.json";
  final uri = Uri.parse(url);

  Response response = await get(
    uri,
    headers: headers
  );

  Map<String, dynamic> data = jsonDecode(response.body);
  return data;
}
Future<List<Care>> get_marked_cares(String patient, String day, List<Care> cares, on_success, on_error) async {

  final headers = {'Content-Type': 'application/json'};


  String url = "https://app-elder-care-default-rtdb.firebaseio.com/reminder/$day/$patient.json";
  final uri = Uri.parse(url);

  Response response = await get(
      uri,
      headers: headers
  );

  Map<String, dynamic> map = jsonDecode(response.body);
  List<Care> c = [];

  for(Care care in cares){
    if(map.containsKey(care.id)){


      try{
        if (map[care.id]['status']) {
          care.time = map[care.id]['status_time'];
          c.add(care);
        }
      }catch(e){
        print(e.toString());
      }

    }
  }


  return c;
}

String get_today() {
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  final String today = formatter.format(now);
  return today;
}
String get_time() {
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('HH:mm');
  final String today = formatter.format(now);
  return today;
}
Future<void> save_or_update_reminder(String patient, String care, String time,
    on_success, on_error) async {

  final headers = {'Content-Type': 'application/json'};

  String jsonBody = json.encode(time);
  final encoding = Encoding.getByName('utf-8');

  String today = get_today();

  String url = "https://app-elder-care-default-rtdb.firebaseio.com/reminder/$today/$patient/$care/time.json";
  final uri = Uri.parse(url);

  Response response = await put(
    uri,
    headers: headers,
    body: jsonBody,
    encoding: encoding,
  );
  on_success();
}
Future<void> save_or_update_status(String patient, String care, bool status,
    on_success, on_error) async {

  final headers = {'Content-Type': 'application/json'};

  String jsonBody = json.encode(status);
  final encoding = Encoding.getByName('utf-8');

  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  final String today = formatter.format(now);

  String url = "https://app-elder-care-default-rtdb.firebaseio.com/reminder/$today/$patient/$care/status.json";
  final uri = Uri.parse(url);

  Response response = await put(
    uri,
    headers: headers,
    body: jsonBody,
    encoding: encoding,
  );
  response = await put(
    Uri.parse("https://app-elder-care-default-rtdb.firebaseio.com/reminder/$today/$patient/$care/status_time.json"),
    headers: headers,
    body: json.encode(DateFormat('yyyy-MM-dd HH:mm:ss').format(now)),
    encoding: encoding,
  );
  on_success();
}

Future<void> save_health_entry(String patient, int index, HealthEntry entry,
    on_success, on_error) async {

  final headers = {'Content-Type': 'application/json'};

  String jsonBody = json.encode(entry.toJson());
  final encoding = Encoding.getByName('utf-8');

  String today = get_today();

  String url = "https://app-elder-care-default-rtdb.firebaseio.com/user/$patient/health/$index.json";
  final uri = Uri.parse(url);

  Response response = await put(
    uri,
    headers: headers,
    body: jsonBody,
    encoding: encoding,
  );
  on_success();
}

User? get_login(){
  return login;
}

void set_login(User user){
  login = user;
}

void show_loading_dialog(BuildContext context){
  AlertDialog alert=AlertDialog(
    content: new Row(
      children: [
        CircularProgressIndicator(),
        Container(margin: EdgeInsets.only(left: 7),child:Text("Loading..." )),
      ],),
  );
  showDialog(barrierDismissible: false,
    context:context,
    builder:(BuildContext context){
      return alert;
    },
  );


}
void hide_loading_dialog(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop('dialog');
}

void show_snackbar(BuildContext context, String text){
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text),));

}