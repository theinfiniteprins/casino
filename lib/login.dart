import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkForSavedCredentials();
  }

  Future<void> _checkForSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('id');
    final password = prefs.getString('password');

    if (id == 'admin' && password == 'admin') {
      // Redirect to HomeScreen if valid credentials are found
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  Future<void> _login() async {
    final id = _idController.text;
    final password = _passwordController.text;

    if (id == 'admin' && password == 'admin') {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('id', id);
      prefs.setString('password', password);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      // Handle incorrect login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Incorrect ID or Password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular image
            ClipOval(
              child: Image.asset(
                'assets/logo.png',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 30),
            // Styling TextFields
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: 'ID',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),
            SizedBox(height: 20),
            // Styling ElevatedButton
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // Button color
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Text(
                'Login',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
