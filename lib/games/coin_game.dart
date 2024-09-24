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
  int _balance = 0;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFlipping = false;
  String _coinImage = 'assets/head.png';
  Color _resultColor = Colors.black;
  TextEditingController _betController = TextEditingController(); // Controller for bet amount

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? userId;

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

    userId = FirebaseAuth.instance.currentUser?.uid;
    _fetchBalance();
  }

  @override
  void dispose() {
    _controller.dispose();
    _betController.dispose(); // Dispose the controller
    super.dispose();
  }

  Future<void> _fetchBalance() async {
    if (userId != null) {
      DocumentSnapshot userDoc = await firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        setState(() {
          _balance = userDoc['balance'] ?? 0;
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
    int betAmount = int.tryParse(_betController.text) ?? 0; // Get bet amount

    setState(() {
      _result = outcome;
      _coinImage = outcome == 'Heads' ? 'assets/head.png' : 'assets/tails.png';

      if (_selectedBet == outcome) {
        int winAmount = (betAmount * 1.9).round();
        _balance += winAmount;
        _result += ' - You win \$${winAmount}!';
        _resultColor = Colors.green;
      } else {
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

    int betAmount = int.tryParse(_betController.text) ?? 0;
    if (betAmount <= 0 || betAmount > _balance) {
      setState(() {
        _result = 'Invalid bet amount!';
        _resultColor = Colors.red;
      });
      return;
    }

    setState(() {
      _balance -= betAmount; // Deduct the bet amount from balance
      _isFlipping = true;
    });

    _updateBalance(_balance); // Update balance before the flip
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Flip It',
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
            const SizedBox(height: 20),
            TextField(
              controller: _betController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter Bet Amount',
                border: OutlineInputBorder(),
                suffix: Text(
                  '1.9X',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
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
