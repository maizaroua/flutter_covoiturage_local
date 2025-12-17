import 'package:covoituragelocale/vue/Home.dart';
import 'package:covoituragelocale/vue/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // en attente
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // utilisateur connecté
        if (snapshot.hasData && snapshot.data != null) {
          return HomePage();
        }

        // pas connecté
        return LoginPage();
      },
    );
  }
}
