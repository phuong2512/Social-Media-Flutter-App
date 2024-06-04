import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:social_media_app/auth_firebase.dart';
import 'package:social_media_app/auth_gate.dart';
import 'package:social_media_app/home_screen.dart';
import 'package:social_media_app/profile_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthFirebase(),
      routes: {
        '/auth_gate':(context) => const AuthGate(),
        '/home_screen':(context) => const HomeScreen(),
        '/profile_screen':(context) => ProfileScreen(),
      },
    );
  }
}
