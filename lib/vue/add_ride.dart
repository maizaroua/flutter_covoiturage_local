import 'package:covoituragelocale/controlleur/addRideToDB.dart';
import 'package:covoituragelocale/modele/ride.dart';
import 'package:covoituragelocale/vue/destination.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddRidePage extends StatefulWidget {
   AddRidePage({Key? key}) : super(key: key);

  @override
  _AddRidePageState createState() => _AddRidePageState();
}

class _AddRidePageState extends State<AddRidePage> {
  final _formKey = GlobalKey<FormState>();

  String startLocation = '';
  String endLocation = '';
  String time = '10:00 AM';
  String email = '';

  final TextEditingController startCtrl = TextEditingController();
  final TextEditingController endCtrl = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEmailFromPrefs();
  }

  @override
  void dispose() {
    startCtrl.dispose();
    endCtrl.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> _loadEmailFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('user_email') ?? '';
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked =
    await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() => time = picked.format(context));
    }
  }

  Future<String?> _pickDestination() async {
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
    return result?.toString();
  }

  Future<void> _submitRide() async {
    // ✅ validate form
    if (!_formKey.currentState!.validate()) return;

    if (startLocation.isEmpty || endLocation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Choisir start et end location")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vous devez vous connecter.")),
      );
      return;
    }

    final price = double.tryParse(priceController.text.trim()) ?? 0.0;

    final ride = Ride(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startLocation: startLocation,
      endLocation: endLocation,
      time: time,
      email: email.isNotEmpty ? email : (user.email ?? ""),
      ownerUid: user.uid, // ✅ important pour reservations
      price: price,
    );

    try {
      await addRideToDB(ride);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Trajet ajouté ✅")),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // keep controllers in sync (without recreating them)
    startCtrl.text = startLocation;
    endCtrl.text = endLocation;

    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un Trajet')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: startCtrl,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Start Location",
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (_) =>
                startLocation.isEmpty ? "Choisir Start Location" : null,
                onTap: () async {
                  final result = await _pickDestination();
                  if (result != null) {
                    setState(() {
                      startLocation = result;
                      startCtrl.text = result;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: endCtrl,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "End Location",
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (_) =>
                endLocation.isEmpty ? "Choisir End Location" : null,
                onTap: () async {
                  final result = await _pickDestination();
                  if (result != null) {
                    setState(() {
                      endLocation = result;
                      endCtrl.text = result;
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
                  final value = double.tryParse((v ?? "").trim());
                  if (value == null || value <= 0) return "Prix invalide";
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
