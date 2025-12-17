import 'package:cloud_firestore/cloud_firestore.dart';

class RideRequest {
  final String requesterUid; // doc.id
  final String requesterEmail;
  final String status; // pending | accepted | rejected | canceled
  final DateTime? createdAt;

  RideRequest({
    required this.requesterUid,
    required this.requesterEmail,
    required this.status,
    required this.createdAt,
  });

  factory RideRequest.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final ts = data["createdAt"];
    return RideRequest(
      requesterUid: doc.id,
      requesterEmail: (data["requesterEmail"] ?? "").toString(),
      status: (data["status"] ?? "pending").toString(),
      createdAt: ts is Timestamp ? ts.toDate() : null,
    );
  }
}
