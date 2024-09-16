import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class CoinGameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coin Game'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Profile') {
                // Navigate to Profile Screen
              } else if (value == 'Deposit') {
                // Trigger deposit action
              } else if (value == 'Withdraw') {
                // Trigger withdraw action
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(value: 'Profile', child: Text('Profile')),
                PopupMenuItem(value: 'Deposit', child: Text('Deposit')),
                PopupMenuItem(value: 'Withdraw', child: Text('Withdraw')),
              ];
            },
          ),
        ],
      ),
      body: Center(
        child: CoinFlipWidget(),
      ),
    );
  }
}

class CoinFlipWidget extends StatefulWidget {
  @override
  _CoinFlipWidgetState createState() => _CoinFlipWidgetState();
}

class _CoinFlipWidgetState extends State<CoinFlipWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _result = '';
  String _selectedBet = '';
  double _gameBalance = 0; // In-game balance
  double _userBalance =0;
  String _betAmount = '';

  bool _isFlipping = false;
  String _coinImage = 'assets/head.png';
  Color _resultColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _fetchUserBalance();
  }
  User? currentUser = FirebaseAuth.instance.currentUser;
  // Fetch user balance from Firebase
  Future<void> _fetchUserBalance() async {




    DatabaseReference balanceRef = FirebaseDatabase.instance.ref('users/${currentUser!.uid}/balance');
    balanceRef.get().then((DataSnapshot snapshot) {
      if (snapshot.exists) {
        setState(() {
          int bl = snapshot.value as int;
          _userBalance = bl.toDouble();// Set the user's balance
        });
      }
    }).catchError((error) {
      print("Failed to get balance: $error");
    });
  }

  // Update user balance in Firebase
  Future<void> _updateUserBalance(double newBalance, String userId) async {
    DatabaseReference databaseRef = FirebaseDatabase.instance.ref('users/$userId');
    await databaseRef.update({
      'balance': newBalance,
    }).then((_) {
      print("User's balance updated successfully!");
    }).catchError((error) {
      print("Failed to update balance: $error");
    });
  }

  // Deposit money from Firebase balance to in-game balance
  void _deposit() {
    double bet = double.tryParse(_betAmount) ?? 0.0;
    if (bet <= _userBalance) {
      setState(() {
        _userBalance -= bet;
        _gameBalance += bet;
      });
      _updateUserBalance(_userBalance,currentUser!.uid);
    } else {
      setState(() {
        _result = 'Insufficient balance in Firebase!';
      });
    }
  }

  // Withdraw winnings from in-game balance to Firebase balance
  void _withdraw() {
    setState(() {
      _userBalance += _gameBalance;
      _gameBalance = 0.0;
    });
    _updateUserBalance(_userBalance,currentUser!.uid);
  }

  // Coin flip logic
  void _flipCoin() {
    double bet = double.tryParse(_betAmount) ?? 0.0;
    if (bet > _gameBalance) {
      setState(() {
        _result = 'Insufficient game balance to bet!';
        _resultColor = Colors.red;
      });
      return;
    }

    setState(() {
      _isFlipping = true;
      _result = '';
      _coinImage = 'assets/flip.png'; // Placeholder for flipping coin
    });

    Future.delayed(Duration(seconds: 2), () {
      String outcome = Random().nextBool() ? 'Heads' : 'Tails';
      setState(() {
        _coinImage = outcome == 'Heads' ? 'assets/head.png' : 'assets/tails.png';
        if (_selectedBet == outcome) {
          _gameBalance += bet; // Win: Double the bet
          _result = 'You win!';
          _resultColor = Colors.green;
        } else {
          _gameBalance -= bet; // Lose: Deduct bet
          _result = 'You lose!';
          _resultColor = Colors.red;
        }
        _isFlipping = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Balance: \$$_gameBalance',
          style: TextStyle(fontSize: 28, color: Colors.yellow, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Text(
          'Firebase Balance: \$$_userBalance',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        SizedBox(height: 20),
        TextField(
          onChanged: (value) {
            _betAmount = value;
          },
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Enter bet amount',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedBet = 'Heads';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedBet == 'Heads' ? Colors.blue : Colors.grey,
              ),
              child: Text('Heads'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedBet = 'Tails';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedBet == 'Tails' ? Colors.blue : Colors.grey,
              ),
              child: Text('Tails'),
            ),
          ],
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isFlipping ? null : _flipCoin,
          child: Text('Flip Coin'),
        ),
        SizedBox(height: 20),
        Text(
          _result,
          style: TextStyle(fontSize: 24, color: _resultColor),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _deposit,
          child: Text('Deposit'),
        ),
        ElevatedButton(
          onPressed: _withdraw,
          child: Text('Withdraw'),
        ),
      ],
    );
  }
}
