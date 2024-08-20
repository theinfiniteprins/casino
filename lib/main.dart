import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'games/coin_game.dart';
import 'games/mines_game.dart';
import 'games/cricket_screen.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(
          color: Colors.black,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20,fontFamily: 'BungeeTint'),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/coin_game': (context) => CoinGameScreen(),
        '/mines_game': (context) => MinesGameScreen(),
        '/cricket_game':(context) => CricketScreen(),
      },
    );
  }
}
