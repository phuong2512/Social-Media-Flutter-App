import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Home"),
      backgroundColor: Colors.cyan,
      actions: [
        IconButton(onPressed: logout, icon: Icon(Icons.logout))
      ],
      ),
    );
  }

  void logout() {
    FirebaseAuth.instance.signOut();
  }
}
