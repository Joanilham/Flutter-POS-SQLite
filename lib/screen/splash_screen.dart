import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos_sqlite/auth/login_screen.dart';
import 'package:flutter_pos_sqlite/db/app_db.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initDatabase();
 }

 Future<void> _initDatabase() async {
    try {
      // Wait for the database to initialize
      await AppDatabase.instance.database;
      // If initialization is successful, navigate to LoginScreen
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()));
        });
      }
    } catch (e) {
      debugPrint('Error initializing database: $e');
      // You could also show an error message on the screen to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}