import 'dart:ffi';

import 'package:covoituragelocale/controlleur/addRideToDB.dart';
import 'package:covoituragelocale/modele/ride_model.dart';
import 'package:covoituragelocale/vue/destination.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddRidePage extends StatefulWidget {
  const AddRidePage({Key? key}) : super(key: key);

  @override
  _AddRidePageState createState() => _AddRidePageState();
}

class _AddRidePageState extends State<AddRidePage> {
  final _formKey = GlobalKey<FormState>();
  String start_location = '';
  String end_location = '';
  String time = '10:00 AM';
  String email = '';
  late double price = double.tryParse(priceController.text.trim()) ?? 0.0;

  @override
  void initState() {
    super.initState();
    _loadEmailFromPrefs();
  }
  final TextEditingController priceController = TextEditingController();


  /// Méthode pour récupérer l’email depuis SharedPreferences
  Future<void> _loadEmailFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('user_email') ?? '';
    });
  }

  /// Méthode pour choisir l’heure
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked =
    await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() {
        time = picked.format(context);
      });
    }
  }

  /// Méthode pour ajouter le trajet dans Firestore
  Future<void> _submitRide() async {

      if (start_location.isNotEmpty && end_location.isNotEmpty) {
        final ride = Ride(
          id: DateTime
              .now()
              .millisecondsSinceEpoch
              .toString(),
          startLocation: start_location,
          endLocation: end_location,
          time: time,
          email: email,
          prix: price,
        );

        await addRideToDB(ride);
      }
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un Trajet')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: TextEditingController(text: start_location),
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Start Location",
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onTap: () async {
                  final result = await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => DraggableScrollableSheet(
                      expand: true,
                      builder: (context, scrollController) {
                        return DestinationFilterPage(scrollController: scrollController);
                      },
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      start_location = result;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),
              TextField(
                controller: TextEditingController(text: end_location),
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "End Location",
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onTap: () async {
                  final result = await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => DraggableScrollableSheet(
                      expand: true,
                      builder: (context, scrollController) {
                        return DestinationFilterPage(scrollController: scrollController);
                      },
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      end_location = result;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Heure: $time', style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () => _selectTime(context),
                    child: const Text('Choisir l’heure'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final value = double.tryParse(v ?? "");
                  if (value == null || value <= 0) {
                    return "Prix invalide";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: "Prix",
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
              ),


              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitRide,
                  child: const Text('Ajouter Trajet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
