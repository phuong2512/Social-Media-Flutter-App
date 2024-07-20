import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/bottom_navigation_bar.dart';
import '../page/home_screen.dart';
import '../auth_gate/auth_gate.dart';

class AuthFirebase extends StatefulWidget {
  const AuthFirebase({super.key});

  @override
  State<AuthFirebase> createState() => _AuthFirebaseState();
}

class _AuthFirebaseState extends State<AuthFirebase> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(      //Lắng nghe thay đổi từ stream
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData){
            return const AppNavigation();
          }
          else {
            return const AuthGate();
          }
        },
      ),
    );
  }
}
