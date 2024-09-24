import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'home_screen.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final String? userId = prefs.getString('id');  // Check if user id is stored
  final String? password = prefs.getString('password');  // Check if password is stored

  runApp(MyApp(userId: userId, password: password));
}

class MyApp extends StatelessWidget {
  final String? userId;
  final String? password;

  const MyApp({super.key, required this.userId, required this.password});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          color: Colors.black,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'BungeeTint',
          ),
        ),
      ),
      home: AuthCheck(userId: userId, password: password), // Pass user id and password
    );
  }
}

class AuthCheck extends StatelessWidget {
  final String? userId;
  final String? password;

  const AuthCheck({super.key, required this.userId, required this.password});

  @override
  Widget build(BuildContext context) {
    // If both userId and password are stored, redirect to HomeScreen
    if (userId != null && password != null) {
      return HomeScreen();
    } else {
      // Otherwise, redirect to LoginPage
      return const LoginPage();
    }
  }
}
