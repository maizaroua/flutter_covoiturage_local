import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:covoituragelocale/modele/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _prefsCtrl = TextEditingController(); // comma separated
  double _note = 0.0;

  bool _saving = false;
  File? _pickedImageFile;

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  DocumentReference get userRef =>
      FirebaseFirestore.instance.collection('users').doc(uid);

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _emailCtrl.dispose();
    _telCtrl.dispose();
    _prefsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? xfile = await picker.pickImage(
      source: source,
      imageQuality: 75,
      maxWidth: 1200,
    );
    if (xfile == null) return;

    setState(() => _pickedImageFile = File(xfile.path));
  }

  Future<String?> _uploadProfileImage(String uid, File file) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('users')
        .child(uid)
        .child('profile.jpg');

    await storageRef.putFile(file);
    return storageRef.getDownloadURL();
  }

  Future<void> _save(Utilisateur current) async {
    setState(() => _saving = true);
    try {
      String photoUrl = current.photoUrl;

      if (_pickedImageFile != null) {
        final url = await _uploadProfileImage(uid, _pickedImageFile!);
        if (url != null) photoUrl = url;
      }

      final prefs = _prefsCtrl.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      await userRef.set({
        "nom": _nomCtrl.text.trim(),
        "prenom": _prenomCtrl.text.trim(),
        "email": _emailCtrl.text.trim(),
        "telephone": _telCtrl.text.trim(),
        "photoUrl": photoUrl,
        "preferences": prefs,
        "noteMoyenne": _note,
        // ne pas écraser dateInscription si déjà existante
        "dateInscription": Timestamp.fromDate(current.dateInscription),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil mis à jour ✅")),
        );
      }
      setState(() => _pickedImageFile = null);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _fillControllers(Utilisateur u) {
    _nomCtrl.text = u.nom;
    _prenomCtrl.text = u.prenom;
    _emailCtrl.text = u.email;
    _telCtrl.text = u.telephone;
    _prefsCtrl.text = u.preferences.join(', ');
    _note = u.noteMoyenne;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mon Profil")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: userRef.snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text("Erreur: ${snap.error}"));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final doc = snap.data!;
          if (!doc.exists) {
            return Center(
              child: Text("Aucun profil trouvé pour uid=$uid"),
            );
          }

          final user = Utilisateur.fromDoc(doc);

          // remplir une seule fois visuellement
          if (_nomCtrl.text.isEmpty &&
              _prenomCtrl.text.isEmpty &&
              _emailCtrl.text.isEmpty &&
              _telCtrl.text.isEmpty &&
              _prefsCtrl.text.isEmpty) {
            _fillControllers(user);
          }

          final avatarProvider = _pickedImageFile != null
              ? FileImage(_pickedImageFile!)
              : (user.photoUrl.isNotEmpty
              ? NetworkImage(user.photoUrl)
              : null);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 54,
                        backgroundImage:
                        avatarProvider as ImageProvider<Object>?,
                        child: avatarProvider == null
                            ? const Icon(Icons.person, size: 54)
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: PopupMenuButton<String>(
                          icon: const CircleAvatar(
                            radius: 18,
                            child: Icon(Icons.camera_alt, size: 18),
                          ),
                          onSelected: (v) {
                            if (v == 'gallery') {
                              _pickImage(ImageSource.gallery);
                            } else {
                              _pickImage(ImageSource.camera);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'gallery',
                              child: Text("Galerie"),
                            ),
                            PopupMenuItem(
                              value: 'camera',
                              child: Text("Caméra"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                _field(_prenomCtrl, "Prénom", Icons.badge_outlined),
                const SizedBox(height: 10),
                _field(_nomCtrl, "Nom", Icons.badge_outlined),
                const SizedBox(height: 10),
                _field(_emailCtrl, "Email", Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 10),
                _field(_telCtrl, "Téléphone", Icons.phone_outlined,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 10),
                _field(_prefsCtrl, "Préférences (séparées par virgule)",
                    Icons.list_alt_outlined),

                const SizedBox(height: 16),


                ListTile(
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text("Date d’inscription"),
                  subtitle: Text(
                    "${user.dateInscription.toLocal()}".split('.').first,
                  ),
                ),

                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : () => _save(user),
                    icon: _saving
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.save),
                    label: Text(_saving ? "Enregistrement..." : "Enregistrer"),
                  ),
                ),
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text("Déconnexion"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      // Avec AuthGate, pas besoin de Navigator
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();

                    },
                  ),
                ),

              ],
            ),
          );
        },
      ),
    );
  }

  Widget _field(
      TextEditingController c,
      String label,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextField(
      controller: c,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
