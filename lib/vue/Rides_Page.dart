import 'package:covoituragelocale/modele/ride_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class RidesPage extends StatelessWidget {
  const RidesPage({super.key});

  Stream<List<Ride>> ridesStream() {
    return FirebaseFirestore.instance
        .collection('rides')
        .orderBy('time', descending: false) // optionnel
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => Ride.fromDoc(d)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rides')),
      body: StreamBuilder<List<Ride>>(
        stream: ridesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final rides = snapshot.data ?? [];
          if (rides.isEmpty) {
            return const Center(child: Text('Aucun ride pour le moment.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: rides.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final ride = rides[index];

              return Card(
                elevation: 2,
                child: ExpansionTile(
                  leading: const Icon(Icons.directions_car),
                  title: Text('${ride.startLocation} → ${ride.endLocation}'),
                  subtitle: Text('Heure: ${ride.time}'),
                  childrenPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Départ: ${ride.startLocation}')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.flag_outlined, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Arrivée: ${ride.endLocation}')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Time: ${ride.time}')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.email_outlined, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Email: ${ride.email}')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.attach_money, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Prix: ${ride.prix}')),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'ID: ${ride.id}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
