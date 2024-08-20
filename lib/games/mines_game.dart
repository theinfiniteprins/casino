import 'package:flutter/material.dart';
import '../custom_app_bar.dart';
import 'dart:math';

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
        child: MinesGameWidget(),
      ),
    );
  }
}

class MinesGameWidget extends StatefulWidget {
  @override
  _MinesGameWidgetState createState() => _MinesGameWidgetState();
}

class _MinesGameWidgetState extends State<MinesGameWidget> {
  static const int gridSize = 5;
  int mineCount = 3;

  late List<List<bool>> _mines;
  late List<List<bool>> _revealed;
  late bool _gameOver;

  final TextEditingController _mineCountController = TextEditingController(text: '3');

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    _mines = List.generate(gridSize, (_) => List.generate(gridSize, (_) => false));
    _revealed = List.generate(gridSize, (_) => List.generate(gridSize, (_) => false));
    _gameOver = false;

    _placeMines();
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

  void _revealSquare(int row, int col) {
    if (_gameOver || _revealed[row][col]) {
      return;
    }

    setState(() {
      _revealed[row][col] = true;
      if (_mines[row][col]) {
        _gameOver = true; // Stop the game without showing a popup
      } else {
        if (_checkWin()) {
          _showWinDialog();
        }
      }
    });
  }

  bool _checkWin() {
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (!_mines[i][j] && !_revealed[i][j]) {
          return false;
        }
      }
    }
    return true;
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('You Win!'),
          content: Text('You have successfully avoided all mines!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _restartGame();
              },
              child: Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  void _restartGame() {
    setState(() {
      mineCount = int.tryParse(_mineCountController.text) ?? 3;
      _initializeGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _mineCountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Enter number of mines',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              _restartGame();
            },
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridSize,
          ),
          itemCount: gridSize * gridSize,
          itemBuilder: (context, index) {
            int row = index ~/ gridSize;
            int col = index % gridSize;
            return GestureDetector(
              onTap: () => _revealSquare(row, col),
              child: Container(
                margin: EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: _revealed[row][col]
                      ? (_mines[row][col] ? Colors.red : Colors.green)
                      : Colors.grey[800],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: _revealed[row][col]
                      ? (_mines[row][col]
                      ? Image.asset(
                    'assets/mine.webp',
                    height: 50,
                    width: 50,
                  )
                      : Container())
                      : Container(),
                ),
              ),
            );
          },
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _restartGame,
          child: Text('Restart Game'),
        ),
      ],
    );
  }
}
