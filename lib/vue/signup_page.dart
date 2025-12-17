import 'package:covoituragelocale/modele/user_model.dart';
import 'package:covoituragelocale/vue/Home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final telController = TextEditingController();

  Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
  }

  Future<void> signup() async {
    try {
      // 1) Création Firebase Auth
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text.trim(),
      );

      final firebaseUser = cred.user;
      if (firebaseUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur: user null")),
        );
        return;
      }

      final uid = firebaseUser.uid;
      final email = firebaseUser.email ?? emailController.text.trim();

      // 2) Création du modèle Utilisateur
      // ⚠️ On met dateInscription côté Firestore avec serverTimestamp (mieux)

      Utilisateur user = Utilisateur(
        uid: uid,
        nom: nomController.text.trim(),
        prenom: prenomController.text.trim(),
        email: email,
        telephone: telController.text.trim(),
        photoUrl: "",
        dateInscription: DateTime.now(),
        preferences: const [],
        noteMoyenne: 0.0,
        typeUtilisateur: selectedType, // ✅ IMPORTANT
      );


      // 3) Enregistrement Firestore
      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        ...user.toJson(),
        "dateInscription": FieldValue.serverTimestamp(), // ✅ mieux
      }, SetOptions(merge: true));

      // 4) Save email in SharedPreferences
      await saveEmail(email);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Compte créé avec succès !")),
      );

      // ✅ Option A: aller direct à Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );

      // ✅ Option B: revenir au Login (si tu préfères)
      // Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur : $e")));
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    nomController.dispose();
    prenomController.dispose();
    telController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Signup")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nomController,
                decoration: const InputDecoration(labelText: "Nom"),
              ),
              TextField(
                controller: prenomController,
                decoration: const InputDecoration(labelText: "Prénom"),
              ),
              TextField(
                controller: telController,
                decoration: const InputDecoration(labelText: "Téléphone"),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: passController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedType,
                items: types
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => selectedType = v ?? "passager"),
                decoration: const InputDecoration(
                  labelText: "Type d'utilisateur",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: signup,
                child: const Text("Créer un compte"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
