import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
  }

  Future<User> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = cred.user;
    if (user == null) throw Exception("User null");

    await saveEmail(user.email ?? email.trim());
    await createUserDocIfMissing(user.uid, user.email ?? email.trim());
    return user;
  }

  Future<User> signup({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required String telephone,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    final user = cred.user;
    if (user == null) throw Exception("User null");

    await _db.collection("users").doc(user.uid).set({
      "nom": nom.trim(),
      "prenom": prenom.trim(),
      "email": user.email ?? email.trim(),
      "telephone": telephone.trim(),
      "photoUrl": "",
      "dateInscription": FieldValue.serverTimestamp(),
      "preferences": [],
      "noteMoyenne": 0.0,
    });

    await saveEmail(user.email ?? email.trim());
    return user;
  }

  Future<void> createUserDocIfMissing(String uid, String email) async {
    final ref = _db.collection("users").doc(uid);
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
}
