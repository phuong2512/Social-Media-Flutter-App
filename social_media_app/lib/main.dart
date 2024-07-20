import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:social_media_app/firebase/auth_firebase.dart';
import 'package:social_media_app/auth_gate/auth_gate.dart';
import 'package:social_media_app/page/home_screen.dart';
import 'package:social_media_app/page/profile_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();    //Đảm bảo widget binding được khởi tạo
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
        '/profile_screen':(context) => const ProfileScreen(),
      },
    );
  }
}
