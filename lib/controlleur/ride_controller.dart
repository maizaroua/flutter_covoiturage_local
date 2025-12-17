import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:covoituragelocale/modele/ride.dart';
import 'package:covoituragelocale/modele/ride_request.dart';
import 'package:firebase_auth/firebase_auth.dart';


class RideController {
  final _db = FirebaseFirestore.instance;

  Stream<List<Ride>> ridesStream() {
    return _db.collection('rides').snapshots().map(
          (s) => s.docs.map((d) => Ride.fromDoc(d)).toList(),
    );
  }

  Future<void> addRide({
    required String start,
    required String end,
    required String time,
    required double price,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Not logged in");

    await _db.collection('rides').add({
      "startLocation": start.trim(),
      "endLocation": end.trim(),
      "time": time.trim(),
      "price": price,
      "email": user.email ?? "",
      "ownerUid": user.uid,
    });
  }

  // requester sends request (doc id = requesterUid to avoid duplicates)
  Future<void> sendRequest(String rideId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Not logged in");

    final reqRef = _db
        .collection('rides')
        .doc(rideId)
        .collection('requests')
        .doc(user.uid);

    final doc = await reqRef.get();
    if (doc.exists) throw Exception("Request already exists");

    await reqRef.set({
      "requesterUid": user.uid,
      "requesterEmail": user.email ?? "",
      "status": "pending",
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Stream<List<RideRequest>> requestsStream(String rideId) {
    return _db
        .collection('rides')
        .doc(rideId)
        .collection('requests')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => RideRequest.fromDoc(d)).toList());
  }

  Future<void> updateRequestStatus({
    required String rideId,
    required String requesterUid,
    required String status,
  }) async {
    await _db
        .collection('rides')
        .doc(rideId)
        .collection('requests')
        .doc(requesterUid)
        .update({"status": status});
  }
}
