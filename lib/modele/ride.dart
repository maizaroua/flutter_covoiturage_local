import 'package:cloud_firestore/cloud_firestore.dart';

class Ride {
  final String id;
  final String startLocation;
  final String endLocation;
  final String time;
  final String email;
  final String ownerUid;
  final double price;

  Ride({
    required this.id,
    required this.startLocation,
    required this.endLocation,
    required this.time,
    required this.email,
    required this.ownerUid,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
    "startLocation": startLocation,
    "endLocation": endLocation,
    "time": time,
    "email": email,
    "ownerUid": ownerUid,
    "price": price,
  };

  factory Ride.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Ride(
      id: doc.id,
      startLocation: (data["startLocation"] ?? "").toString(),
      endLocation: (data["endLocation"] ?? "").toString(),
      time: (data["time"] ?? "").toString(),
      email: (data["email"] ?? "").toString(),
      ownerUid: (data["ownerUid"] ?? "").toString(),
      price: (data["price"] is num) ? (data["price"] as num).toDouble() : 0.0,
    );
  }
}
