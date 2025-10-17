import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'firebase_options.dart';

import 'package:darbk/screens/Define_screen.dart';
import 'package:darbk/screens/welcome_screen.dart';
import 'package:darbk/admin/screens/admin_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
          await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ Force-enable Firestore connection settings on macOS
  if (defaultTargetPlatform == TargetPlatform.macOS) {
    FirebaseFirestore.instance.settings = const Settings(
      sslEnabled: true,
      persistenceEnabled: false,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Darbk',
      debugShowCheckedModeBanner: false,
      home: kIsWeb ? const AdminLoginScreen() : const WelcomeScreen(),
      routes: {
        "/WelcomeScreen": (context) => const WelcomeScreen(),
        "/Define_screen": (context) => const DefineScreen(),
      },
    );
  }
}
