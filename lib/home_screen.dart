import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'custom_app_bar.dart';
import 'games/coin_game.dart';
import 'games/mines_game.dart';
import 'games/cricket_screen.dart';

import 'package:http/http.dart' as http;


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Future<void> handleMatchUpdates() async {
    try {
      // Fetch all bet documents from Firestore
      final betDocs = await FirebaseFirestore.instance.collection('bets').get();
      final bets = betDocs.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
      for (final bet in bets) {
        if(bet['status'] != "pending"){
          continue;
        }
        final String matchId = bet['matchId'];
        final String team = bet['selectedTeam'];
        final String userId = bet['userId'];
        final double betAmount = bet['betAmount'];

        // API call to get match info
        final String apiUrl = 'https://api.cricapi.com/v1/match_info?apikey=14dfe74a-588d-4a34-9366-f2065d81ef0f&id=$matchId';
        final response = await http.get(Uri.parse(apiUrl));
        if (response.statusCode == 200) {
          final resdata = await jsonDecode(response.body);
          final data  = resdata['data'];
          // Check if the match has ended
          if (data['matchEnded'] == true) {
            final matchStatus = data['status'];
            print(matchStatus);
            // Check if the selected team won
            if (matchStatus.contains(team)) {
              print("won");
              // Update user balance and bet status if won
              await FirebaseFirestore.instance.collection('users').doc(userId).update({
                'balance': FieldValue.increment(betAmount * 2),
              });
              await FirebaseFirestore.instance.collection('bets').doc(bet['id']).update({
                'status': 'won',
              });
            } else {
              print("loose");
              // Update bet status if lost
              await FirebaseFirestore.instance.collection('bets').doc(bet['id']).update({
                'status': 'lost',
              });
            }
          }
          else{
            print("match not Ended yet");
          }
        } else {
          print('Failed to fetch match data: ${response.statusCode}');
        }
      }
    } catch (error) {
      print('Error fetching match updates: $error');
    }
  }


  FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;
  int balance = 0;
  bool isLoading = true;  // To show loading state while fetching data
  String email = '';

  void update() async {
    await handleMatchUpdates();
  }

  @override
  void initState() {
    super.initState();
    update();
    _getUserData();  // Fetch user data (balance and email) on screen load
  }

  // Function to get balance and email
  Future<void> _getUserData() async {
    try {
      // Check if user is authenticated
      if (user != null) {
        setState(() {
          email = user!.email ?? 'No Email';  // Get user email
        });

        DocumentSnapshot doc = await firestore.collection('users').doc(user!.uid).get();

        if (doc.exists) {
          print('Document exists: ${doc.data()}');  // Debugging: print the entire document data

          // Check if doc.data() is not null and contains 'balance' field
          var data = doc.data() as Map<String, dynamic>?; // Cast to Map
          if (data != null && data.containsKey('balance')) {
            setState(() {
              balance = data['balance'];  // Safely access balance
            });
            print('Balance fetched: $balance');  // Debugging: print the fetched balance
          } else {
            print('Balance field does not exist in document');
          }
        } else {
          print('User document does not exist');
        }
      } else {
        print('User is not authenticated');
      }
    } catch (e) {
      print('Error fetching balance or email: $e');
    } finally {
      setState(() {
        isLoading = false;  // Stop loading once the data is fetched
      });
    }
  }

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
            value: 'bets',
            child: Text('See Bets'),
          ),
          PopupMenuItem<String>(
            value: 'Sign Out',
            child: Text('Sign Out'),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())  // Show loading indicator while fetching data
          : Stack(
        children: [
          // Background image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg.webp'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Opacity overlay
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.65), // Adjust opacity here
          ),
          // Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                // Rest of the games section
                Text(
                  'Coin Games',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CoinGameScreen()),
                    );
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage('assets/coin.webp'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Mines Games',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MinesGameScreen()),
                    );
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage('assets/mines.avif'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Cricket',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CricketScreen()),
                    );
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage('assets/cricket.jpeg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
