import 'dart:convert';

class User {

  String id, username, full_name, email, password, type;
  List<HealthEntry> health;
  Map<String, String>? data;

  User(this.id, this.username, this.full_name, this.email, this.password, this.type, this.health);

  Map<String, dynamic> toJson() {
    List<String> h = [];

    for(HealthEntry entry in health){
      h.add(jsonEncode(entry.toJson()));
    }

    return {
        "id": id,
        "username": username,
        "full_name": full_name,
        "email": email,
        "password": password,
        "type": type,
        "details": data,
        "health" : h,
      };
  }
}

class Care {

  String id, name, category, image;
  String time = "";

  Care(this.id, this.name, this.category, this.image);

  Map<String, dynamic> toJson() =>
      {
        "id": id,
        "name": name,
        "category": category,
        "image": image,

      };
}

class HealthEntry{

  String doctor, date, time, status = "", medication, diseases;

  HealthEntry(this.doctor, this.date, this.time, this.status, this.medication, this.diseases);

  Map<String, dynamic> toJson() =>
      {
        "doctor": doctor,
        "date": date,
        "time": time,
        "status": status,
        "medication": medication,
        "diseases": diseases,
      };
}
