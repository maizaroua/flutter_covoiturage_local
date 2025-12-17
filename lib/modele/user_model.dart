import 'package:cloud_firestore/cloud_firestore.dart';

class Utilisateur {
  final String uid;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String photoUrl;
  final DateTime dateInscription;
  final List<String> preferences;
  final double noteMoyenne;

  Utilisateur({
    required this.uid,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.photoUrl,
    required this.dateInscription,
    required this.preferences,
    required this.noteMoyenne,
  });

  Map<String, dynamic> toJson() => {
    "nom": nom,
    "prenom": prenom,
    "email": email,
    "telephone": telephone,
    "photoUrl": photoUrl,
    "dateInscription": Timestamp.fromDate(dateInscription),
    "preferences": preferences,
    "noteMoyenne": noteMoyenne,
  };

  factory Utilisateur.fromDoc(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>? ?? {});
    final ts = data["dateInscription"];
    return Utilisateur(
      uid: doc.id,
      nom: (data["nom"] ?? "").toString(),
      prenom: (data["prenom"] ?? "").toString(),
      email: (data["email"] ?? "").toString(),
      telephone: (data["telephone"] ?? "").toString(),
      photoUrl: (data["photoUrl"] ?? "").toString(),
      dateInscription: ts is Timestamp ? ts.toDate() : DateTime.now(),
      preferences: (data["preferences"] as List?)?.map((e) => e.toString()).toList() ?? [],
      noteMoyenne: (data["noteMoyenne"] is num) ? (data["noteMoyenne"] as num).toDouble() : 0.0,
    );
  }
}
