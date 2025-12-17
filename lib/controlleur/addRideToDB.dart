import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:covoituragelocale/modele/ride_model.dart';

Future<void> addRideToDB(Ride ride) async {
  await FirebaseFirestore.instance
      .collection("rides")
      .doc(ride.id)
      .set(ride.toJson());
}
