import 'package:flutter/material.dart';
import '../custom_app_bar.dart';
import 'dart:math';
class CoinGameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Coin Game',
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
        child: CoinFlipWidget(),
      ),
    );
  }
}
class CoinFlipWidget extends StatefulWidget {
  @override
  _CoinFlipWidgetState createState() => _CoinFlipWidgetState();
}

class _CoinFlipWidgetState extends State<CoinFlipWidget> with SingleTickerProviderStateMixin {
  String _result = '';
  String _selectedBet = '';
  int _balance = 100;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFlipping = false;
  String _coinImage = 'assets/head.png';

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCoin() {
    String outcome = Random().nextBool() ? 'Heads' : 'Tails';
    setState(() {
      _result = outcome;
      _coinImage = outcome == 'Heads' ? 'assets/head.png' : 'assets/tails.png';
      if (_selectedBet == outcome) {
        _balance += 10;
        _result += ' - You win!';
      } else {
        _balance -= 10;
        _result += ' - You lose!';
      }
    });
  }

  void _startFlip() {
    if (_selectedBet.isEmpty) {
      setState(() {
        _result = 'Please select Heads or Tails!';
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
      appBar: AppBar(
        title: Text('Coin Flip Game'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Balance: \$$_balance',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isFlipping
                      ? null
                      : () {
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
                  onPressed: _isFlipping
                      ? null
                      : () {
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
                    _coinImage, // Update to use dynamic image
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
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}