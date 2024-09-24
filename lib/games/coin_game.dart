import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../custom_app_bar.dart';
import 'dart:math';

class CoinGameScreen extends StatefulWidget {
  @override
  _CoinGameScreenState createState() => _CoinGameScreenState();
}

class _CoinGameScreenState extends State<CoinGameScreen> with SingleTickerProviderStateMixin {
  String _result = '';
  String _selectedBet = '';
  int _balance = 0; // Start with zero, will be updated from Firestore
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFlipping = false;
  String _coinImage = 'assets/head.png';
  Color _resultColor = Colors.black;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? userId; // Store user ID

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _flipCoin();
        setState(() {
          _isFlipping = false;
        });
      }
    });

    // Get user ID from SharedPreferences or FirebaseAuth
    userId = FirebaseAuth.instance.currentUser?.uid;
    _fetchBalance(); // Fetch the initial balance from Firestore
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchBalance() async {
    if (userId != null) {
      DocumentSnapshot userDoc = await firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        setState(() {
          _balance = userDoc['balance'] ?? 0; // Set balance from Firestore
        });
      }
    }
  }

  Future<void> _updateBalance(int newBalance) async {
    if (userId != null) {
      await firestore.collection('users').doc(userId).update({
        'balance': newBalance,
      });
    }
  }

  void _flipCoin() {
    String outcome = Random().nextBool() ? 'Heads' : 'Tails';
    setState(() {
      _result = outcome;
      _coinImage = outcome == 'Heads' ? 'assets/head.png' : 'assets/tails.png';
      if (_selectedBet == outcome) {
        _balance += 10;
        _result += ' - You win!';
        _resultColor = Colors.green;
      } else {
        _balance -= 10;
        _result += ' - You lose!';
        _resultColor = Colors.red;
      }
      _updateBalance(_balance); // Update balance in Firestore
    });
  }

  void _startFlip() {
    if (_selectedBet.isEmpty) {
      setState(() {
        _result = 'Please select Heads or Tails!';
        _resultColor = Colors.black;
      });
      return;
    }
    setState(() {
      _isFlipping = true;
    });
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          title: 'Coin Game',
          menuItems: [
            PopupMenuItem<String>(value: 'Profile', child: Text('Profile')),
            PopupMenuItem<String>(value: 'History', child: Text('History')),
            PopupMenuItem<String>(value: 'Deposit', child: Text('Deposit')),
            PopupMenuItem<String>(value: 'Withdraw', child: Text('Withdraw')),
            PopupMenuItem<String>(value: 'Sign Out', child: Text('Sign Out')),
          ],
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Balance: \$$_balance',
                  style: TextStyle(
                      fontSize: 28,
                      color: Colors.yellow,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _isFlipping ? null : () {
                        setState(() {
                          _selectedBet = 'Heads';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedBet == 'Heads' ? Colors.blue : Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Heads'),
                    ),
                    ElevatedButton(
                      onPressed: _isFlipping ? null : () {
                        setState(() {
                          _selectedBet = 'Tails';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedBet == 'Tails' ? Colors.blue : Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Tails'),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(_animation.value),
                      child: Image.asset(
                        _coinImage,
                        height: 100,
                        width: 100,
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isFlipping ? null : _startFlip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Flip Coin'),
                ),
                SizedBox(height: 20),
                Text(
                  _result,
                  style: TextStyle(
                    fontSize: 24,
                    color: _resultColor,
                  ),
                ),
              ],
            ),
            ),
        );
    }
}