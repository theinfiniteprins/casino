import 'package:flutter/material.dart';
import 'custom_app_bar.dart'; // Import the custom AppBar widget
import 'games/coin_game.dart'; // Import the CoinGameScreen
import 'games/mines_game.dart'; // Import the MinesGameScreen

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Casino',
        menuItems: [
          PopupMenuItem<String>(
            value: 'Profile',
            child: Text('Profile'),
          ),
          PopupMenuItem<String>(
            value: 'History',
            child: Text('History'),
          ),
          PopupMenuItem<String>(
            value: 'Deposit',
            child: Text('Deposit'),
          ),
          PopupMenuItem<String>(
            value: 'Withdraw',
            child: Text('Withdraw'),
          ),
          PopupMenuItem<String>(
            value: 'Sign Out',
            child: Text('Sign Out'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding around the content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Coin Games',
              style: TextStyle(
                color: Colors.white, // Text color for Coin Games
                fontSize: 18, // Adjust font size as needed
                fontWeight: FontWeight.bold, // Make text bold
              ),
            ),
            SizedBox(height: 10), // Space between text and button
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CoinGameScreen()),
                );
              },
              child: Container(
                width: 100, // Set width for the button
                height: 100, // Set height for the button
                decoration: BoxDecoration(
                  color: Colors.grey[800], // Background color for the button
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                  image: DecorationImage(
                    image: AssetImage('assets/coin.webp'), // Path to coin game image
                    fit: BoxFit.cover, // Ensure the image covers the button
                  ),
                ),
              ),
            ),
            SizedBox(height: 20), // Space between the two sections
            Text(
              'Mines Games',
              style: TextStyle(
                color: Colors.white, // Text color for Mines Games
                fontSize: 18, // Adjust font size as needed
                fontWeight: FontWeight.bold, // Make text bold
              ),
            ),
            SizedBox(height: 10), // Space between text and button
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MinesGameScreen()),
                );
              },
              child: Container(
                width: 100, // Set width for the button
                height: 100, // Set height for the button
                decoration: BoxDecoration(
                  color: Colors.grey[800], // Background color for the button
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                  image: DecorationImage(
                    image: AssetImage('assets/mines.avif'), // Path to mines game image
                    fit: BoxFit.cover, // Ensure the image covers the button
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
