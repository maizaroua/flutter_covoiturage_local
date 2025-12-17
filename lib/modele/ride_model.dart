import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class Ride {
  String id;
  String startLocation;
  String endLocation;
  String time;
  String email;
  double prix;

  Ride({
    required this.id,
    required this.startLocation,
    required this.endLocation,
    required this.time,
    required this.email,
    required this.prix,
  });

  /// Convert Object → JSON (for Firebase or SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "startLocation": startLocation,
      "endLocation": endLocation,
      "time": time,
      "email": email,
      "prix":prix
    };
  }

  /// Convert JSON → Object
  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json["id"],
      startLocation: json["startLocation"],
      endLocation: json["endLocation"],
      time: json["time"],
      email: json["email"],
      prix:  json["prix"]
    );
  }



  factory Ride.fromDoc(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>? ?? {};
  return Ride(
  id: doc.id,
  startLocation: (data['startLocation'] ?? '').toString(),
  endLocation: (data['endLocation'] ?? '').toString(),
  time: (data['time'] ?? '').toString(),
  email: (data['email'] ?? '').toString(),
    prix: (data['prix'] ?? 0.0),
  );
  }

}
