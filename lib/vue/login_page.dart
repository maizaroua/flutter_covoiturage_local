import 'package:covoituragelocale/vue/Home.dart';
import 'package:covoituragelocale/vue/add_ride.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signup_page.dart';
import 'package:covoituragelocale/vue/Home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passController = TextEditingController();

  Future<void> login() async {
    try {
      // 1) Login Firebase
      final credential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text.trim(),
      );

      final user = credential.user;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur: user null")),
        );
        return;
      }

      final email = user.email ?? emailController.text.trim();

      // 2) Save email in SharedPreferences
      await saveEmail(email);

      // 3) Create user doc in Firestore if missing
      await createUserDocIfMissing(uid: user.uid, email: email);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connexion réussie !")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur : $e")));
    }
  }

  Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
  }

  Future<void> createUserDocIfMissing({
    required String uid,
    required String email,
  }) async {
    final ref = FirebaseFirestore.instance.collection('users').doc(uid);
    final doc = await ref.get();

    if (!doc.exists) {
      await ref.set({
        "nom": "",
        "prenom": "",
        "email": email,
        "telephone": "",
        "photoUrl": "",
        "dateInscription": FieldValue.serverTimestamp(),
        "preferences": [],
        "noteMoyenne": 0.0,
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            ElevatedButton(
              onPressed: login,
              child: const Text("Login"),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SignupPage()),
              ),
              child: const Text("Créer un compte"),
            )
          ],
        ),
      ),
    );
  }
}
