import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final postController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Home"),
        backgroundColor: Colors.cyan,
        actions: [
          IconButton(onPressed: logout, icon: const Icon(Icons.logout))
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
                child: Icon(
              Icons.camera,
              size: 45,
            )),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: ListTile(
                leading: const Icon(
                  Icons.home,
                ),
                title: const Text("HOME"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: ListTile(
                leading: const Icon(
                  Icons.person,
                ),
                title: const Text("MY PROFILE"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/profile_screen');
                },
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(23.0),
              child: TextFormField(
                controller: postController,
                decoration: InputDecoration(
                  hintText: "Tell us what are you feeling ...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )
          ),
        ],
      ),
    );
  }

  void logout() {
    FirebaseAuth.instance.signOut();
  }
}
