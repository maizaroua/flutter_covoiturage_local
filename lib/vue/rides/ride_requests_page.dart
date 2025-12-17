import 'package:covoituragelocale/controlleur/ride_controller.dart';
import 'package:covoituragelocale/modele/ride_request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RideRequestsPage extends StatelessWidget {
  final String rideId;
  final String ownerUid;
  RideRequestsPage({super.key, required this.rideId, required this.ownerUid});

  final rideController = RideController();

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (currentUid != ownerUid) {
      return const Scaffold(
        body: Center(child: Text("Accès refusé (pas propriétaire)")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Demandes")),
      body: StreamBuilder<List<RideRequest>>(
        stream: rideController.requestsStream(rideId),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final reqs = snap.data!;
          if (reqs.isEmpty) return const Center(child: Text("Aucune demande"));

          return ListView.builder(
            itemCount: reqs.length,
            itemBuilder: (context, i) {
              final r = reqs[i];
              return Card(
                child: ListTile(
                  title: Text(r.requesterEmail.isEmpty ? r.requesterUid : r.requesterEmail),
                  subtitle: Text("Status: ${r.status}"),
                  trailing: r.status == "pending"
                      ? Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () => rideController.updateRequestStatus(
                          rideId: rideId,
                          requesterUid: r.requesterUid,
                          status: "accepted",
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => rideController.updateRequestStatus(
                          rideId: rideId,
                          requesterUid: r.requesterUid,
                          status: "rejected",
                        ),
                      ),
                    ],
                  )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
