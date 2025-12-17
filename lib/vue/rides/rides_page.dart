import 'package:covoituragelocale/controlleur/ride_controller.dart';
import 'package:covoituragelocale/modele/ride.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'ride_requests_page.dart';

class RidesPage extends StatelessWidget {
  RidesPage({super.key});

  final rideController = RideController();

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Rides")),
      body: StreamBuilder<List<Ride>>(
        stream: rideController.ridesStream(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final rides = snap.data!;
          if (rides.isEmpty) return const Center(child: Text("Aucun ride"));

          return ListView.builder(
            itemCount: rides.length,
            itemBuilder: (context, i) {
              final r = rides[i];
              return Card(
                child: ListTile(
                  title: Text("${r.startLocation} → ${r.endLocation}"),
                  subtitle: Text("Heure: ${r.time} | Prix: ${r.price}"),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.send),
                        tooltip: "Demander réservation",
                        onPressed: () async {
                          try {
                            await rideController.sendRequest(r.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Demande envoyée ✅")),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Erreur: $e")),
                            );
                          }
                        },
                      ),
                      if (currentUid == r.ownerUid)
                        IconButton(
                          icon: const Icon(Icons.list_alt),
                          tooltip: "Voir demandes",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RideRequestsPage(
                                  rideId: r.id,
                                  ownerUid: r.ownerUid,
                                ),
                              ),
                            );
                          },
                        ),

                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
