import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DestinationFilterPage extends StatefulWidget {
  final ScrollController scrollController;

  const DestinationFilterPage({Key? key, required this.scrollController})
      : super(key: key);

  @override
  State<DestinationFilterPage> createState() => _DestinationFilterPageState();
}

class _DestinationFilterPageState extends State<DestinationFilterPage> {
  Map<String, dynamic>? jsonData;

  String? selectedGovernorate;
  String? selectedDelegation;
  String? selectedCity;

  List governorates = [];
  List delegations = [];
  List cities = [];

  @override
  void initState() {
    super.initState();
    loadJson();
  }

  /// Load JSON from assets
  Future<void> loadJson() async {
    final String response =
    await rootBundle.loadString("assets/destinations.json");
    final data = json.decode(response);

    final tunisia = data["FR"]["Tunisie"];

    setState(() {
      jsonData = tunisia;
      governorates = tunisia["governorates"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: ListView(
        controller: widget.scrollController,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const Text(
            "Select Destination",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),

          // GOVERNORATES
          DropdownButtonFormField<String>(
            decoration: _inputDecoration("Governorate"),
            value: selectedGovernorate,
            items: governorates
                .map((g) => DropdownMenuItem<String>(
              value: g["nom"],
              child: Text(g["nom"]),
            ))
                .toList(),
            onChanged: (value) {
              final gov = governorates
                  .firstWhere((element) => element["nom"] == value);

              setState(() {
                selectedGovernorate = value;
                delegations = gov["delegations"];
                selectedDelegation = null;
                cities = [];
                selectedCity = null;
              });
            },
          ),

          SizedBox(height: 20),

          // DELEGATIONS
          DropdownButtonFormField<String>(
            decoration: _inputDecoration("Delegation"),
            value: selectedDelegation,
            items: delegations
                .map((d) => DropdownMenuItem<String>(
              value: d["nom"],
              child: Text(d["nom"]),
            ))
                .toList(),
            onChanged: (value) {
              final del = delegations
                  .firstWhere((element) => element["nom"] == value);

              setState(() {
                selectedDelegation = value;
                cities = del["cites"];
                selectedCity = null;
              });
            },
          ),

          SizedBox(height: 20),

          // CITIES
          DropdownButtonFormField<String>(
            decoration: _inputDecoration("City"),
            value: selectedCity,
            items: cities
                .map((c) => DropdownMenuItem<String>(
              value: c,
              child: Text(c),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedCity = value;
              });
            },
          ),

          SizedBox(height: 30),

          // VALIDATE BUTTON
          ElevatedButton(
            onPressed: (selectedGovernorate != null &&
                selectedDelegation != null &&
                selectedCity != null)
                ? () {
              Navigator.pop(
                context,
                "$selectedGovernorate - $selectedDelegation - $selectedCity",
              );
            }
                : null,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle:
              TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: Text("Confirm"),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[100],
    );
  }
}
