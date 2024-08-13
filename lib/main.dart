import 'package:flutter/material.dart';
import 'home_screen.dart'; // Import the HomeScreen
import 'games/coin_game.dart'; // Import the CoinGameScreen
import 'games/mines_game.dart'; // Import the MinesGameScreen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner
      theme: ThemeData(
        brightness: Brightness.dark, // Set the theme to dark mode
        primarySwatch: Colors.red, // Primary color for the app
        appBarTheme: AppBarTheme(
          color: Colors.black, // AppBar color for consistency
          fontFamily: 'BungeeTint',
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20), // AppBar title color and size
        ),
      ),
      initialRoute: '/', // Set the initial route
      routes: {
        '/': (context) => HomeScreen(), // Define the root route
        '/coin_game': (context) => CoinGameScreen(),
        '/mines_game': (context) => MinesGameScreen(),
      },
    );
  }
}
