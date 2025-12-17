import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'rides/rides_page.dart';
import 'add_ride.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
   HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String? typeUtilisateur; // passager | conducteur

  @override
  void initState() {
    super.initState();
    _loadUserType();
  }

  Future<void> _loadUserType() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!mounted) return;

    setState(() {
      typeUtilisateur = (doc.data()?['typeUtilisateur'] ?? 'passager').toString();
    });
  }

  List<Widget> get _pages {
    if (typeUtilisateur == "conducteur") {
      return [
        RidesPage(),
        AddRidePage(), // ✅ seulement conducteur
        const ProfilePage(),
      ];
    } else {
      return  [
        RidesPage(),
        ProfilePage(), // ❌ pas de AddRide
      ];
    }
  }

  List<BottomNavigationBarItem> get _navItems {
    if (typeUtilisateur == "conducteur") {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt),
          label: 'Trajets',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: 'Ajouter',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profil',
        ),
      ];
    } else {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt),
          label: 'Trajets',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profil',
        ),
      ];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ⏳ En attente du type utilisateur
    if (typeUtilisateur == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // sécurité index
    if (_selectedIndex >= _pages.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
