import 'package:flutter/material.dart';
import '../custom_app_bar.dart';

class MinesGameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Mines Game',
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
      body: Center(
        child: Text('This is the Mines Game screen.'),
      ),
    );
  }
}
