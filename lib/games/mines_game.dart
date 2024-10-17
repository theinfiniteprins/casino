import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../custom_app_bar.dart';
import 'dart:math';

class MinesGameScreen extends StatefulWidget {
  @override
  _MinesGameScreenState createState() => _MinesGameScreenState();
}

class _MinesGameScreenState extends State<MinesGameScreen> {
  static const int gridSize = 5;
  int mineCount = 3;
  int _balance = 0;
  int _betAmount = 0;
  int _openedSafeTiles = 0;
  bool _gameOver = false;
  bool _gameStarted = false;
  bool _cashOutClicked = false; // New flag to track cash out click
  bool _mineHit = false; // New flag to track if mine was hit

  double _winAmount = 0; // New variable to track win amount
  late List<List<bool>> _mines;
  late List<List<bool>> _revealed;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? userId;
  final TextEditingController _mineCountController = TextEditingController();
  final TextEditingController _betController = TextEditingController();

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
    _fetchBalance();
    _initializeGame();
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
      await firestore.collection('users').doc(userId!).update({'balance': newBalance});
    }
  }

  Future<void> _saveGameHistory(bool won) async {
    if (userId != null) {
      await firestore.collection('users').doc(userId!).collection('history').add({
        'Game': "Mines",
        'amount': _betAmount,
        'winAmount': _winAmount,
        'mineCount': mineCount,
        'openedSafeTiles': _openedSafeTiles,
        'won': won,
        'date': FieldValue.serverTimestamp(),
      });
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save bet history. Please try again.')),
      );
    }
  }

  void _initializeGame() {
    _mines = List.generate(gridSize, (_) => List.generate(gridSize, (_) => false));
    _revealed = List.generate(gridSize, (_) => List.generate(gridSize, (_) => false));
    _gameOver = false;
    _openedSafeTiles = 0;
    _cashOutClicked = false;
    _mineHit = false;
    _winAmount = 0;
  }

  void _placeMines() {
    int minesPlaced = 0;
    while (minesPlaced < mineCount) {
      int row = Random().nextInt(gridSize);
      int col = Random().nextInt(gridSize);
      if (!_mines[row][col]) {
        _mines[row][col] = true;
        minesPlaced++;
      }
    }
  }

  double _calculateWinAmount() {
    int totalMines = 25;
    double winAmount = _betAmount.toDouble();
    winAmount += ((winAmount * winAmount * mineCount * (_openedSafeTiles + 1)) /
        (totalMines * (totalMines - mineCount)));
    return winAmount;
  }

  void _revealSquare(int row, int col) {
    if (_gameOver || _revealed[row][col] || !_gameStarted) return;

    setState(() {
      _revealed[row][col] = true;
      if (_mines[row][col]) {
        _gameOver = true;
        _mineHit = true;
        _revealAllMines();
        _winAmount = -_betAmount.toDouble(); // Show loss amount
        _updateBalance(_balance); // No change in balance since bet is lost
        _saveGameHistory(false);
      } else {
        _openedSafeTiles++;
        _winAmount = _calculateWinAmount(); // Update win amount after each safe tile
        if (_checkWin()) {
          _balance += _winAmount.round();
          _updateBalance(_balance);
          _saveGameHistory(true);
          _gameOver = true;
        }
      }
    });
  }

  void _revealAllMines() {
    setState(() {
      for (int i = 0; i < gridSize; i++) {
        for (int j = 0; j < gridSize; j++) {
          if (_mines[i][j]) {
            _revealed[i][j] = true;
          }
        }
      }
    });
  }

  void _restartGame() {
    setState(() {
      int newMineCount = int.tryParse(_mineCountController.text) ?? mineCount;
      if (newMineCount < 1 || newMineCount > 24) {
        _showInvalidMineCountDialog();
        return;
      }
      if (_betAmount > _balance) {
        _showInvalidBetDialog();
        return;
      }
      _betAmount = int.tryParse(_betController.text) ?? 0;
      _balance -= _betAmount;
      _updateBalance(_balance);
      mineCount = newMineCount;
      _initializeGame();
      _placeMines();
      _gameStarted = true;
    });
  }

  void _showInvalidMineCountDialog() {
    _mineCountController.text = mineCount.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Invalid Mine Count'),
          content: Text('The number of mines must be between 1 and 24'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showInvalidBetDialog() {
    _betController.text = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Invalid Bet Amount'),
          content: Text('Bet amount exceeds your current balance.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _cashOut() {
    _winAmount = _calculateWinAmount();
    _balance += _winAmount.round();
    _updateBalance(_balance);


    _revealAllMines();
    _saveGameHistory(true);
    setState(() {
      _cashOutClicked = true;
      _gameOver = true;
      _gameStarted = false;
    });
  }

  bool _checkWin() {
    return _openedSafeTiles == (gridSize * gridSize - mineCount);
  }

  bool _isGameStarted() {
    return _openedSafeTiles > 0 && _gameStarted;
  }

  void _startGame() {
    setState(() {
      mineCount = int.tryParse(_mineCountController.text) ?? mineCount;
      _betAmount = int.tryParse(_betController.text) ?? 0;
      if (mineCount < 1 || mineCount > 24 || _betAmount <= 0 || _betAmount > _balance) {
        _showInvalidMineCountDialog();
        return;
      }
      _balance -= _betAmount;
      _updateBalance(_balance);
      _initializeGame();
      _placeMines();
      _gameStarted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Mines',
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
            child: Text('Cricket Bets'),
          ),
          PopupMenuItem<String>(
            value: 'Sign Out',
            child: Text('Sign Out'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Win Amount Display
            Text(
              _cashOutClicked
                  ? 'Won: ₹${_winAmount.toStringAsFixed(2)}'
                  : _mineHit
                  ? 'Lost: ₹${(-_winAmount).toStringAsFixed(2)}'
                  : 'Potential Win: ₹${_winAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _cashOutClicked
                    ? Colors.green
                    : _mineHit
                    ? Colors.red
                    : Colors.grey,
              ),
            ),
            SizedBox(height: 20),
            // Mine Count Input
            TextField(
              controller: _mineCountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter number of mines',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // Bet Amount Input
            TextField(
              controller: _betController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter Bet Amount',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // Start Game Button
            ElevatedButton(
              onPressed: _startGame,
              child: Text('Start Game'),
            ),
            SizedBox(height: 20),
            // Game Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridSize,
                ),
                itemCount: gridSize * gridSize,
                itemBuilder: (context, index) {
                  int row = index ~/ gridSize;
                  int col = index % gridSize;
                  return GestureDetector(
                    onTap: () {
                      _revealSquare(row, col);
                    },
                    child: Container(
                      margin: EdgeInsets.all(4),
                      color: _revealed[row][col]
                          ? (_mines[row][col] ? Colors.red : Colors.green)
                          : Colors.grey,
                      child: Center(
                        child: Text(
                          _revealed[row][col]
                              ? (_mines[row][col] ? '💣' : '✔️')
                              : '',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Cash Out Button
            ElevatedButton(
              onPressed: _isGameStarted() && !_gameOver ? _cashOut : null,
              child: Text('Cash Out'),
            ),
          ],
        ),
      ),
    );
  }
}
