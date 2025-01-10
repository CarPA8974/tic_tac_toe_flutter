// main.dart
import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(TicTacToeApp());
}

class TicTacToeApp extends StatefulWidget {
  @override
  _TicTacToeAppState createState() => _TicTacToeAppState();
}

enum GameMode { PlayerVsPlayer, PlayerVsCPU }
enum Difficulty { Easy, Medium, Hard }

class _TicTacToeAppState extends State<TicTacToeApp> {
  GameMode _gameMode = GameMode.PlayerVsPlayer;
  Difficulty _difficulty = Difficulty.Easy;
  List<String> _board = List.filled(9, '');
  String _currentPlayer = 'X';
  bool _gameOver = false;
  String _winnerMessage = '';

  void _restartGame() {
    setState(() {
      _board = List.filled(9, '');
      _currentPlayer = 'X';
      _gameOver = false;
      _winnerMessage = '';
    });
  }

  void _changeMode(GameMode mode) {
    setState(() {
      _gameMode = mode;
      _restartGame();
    });
  }

  void _changeDifficulty(Difficulty difficulty) {
    setState(() {
      _difficulty = difficulty;
      _restartGame();
    });
  }

  void _makeMove(int index) {
    if (_board[index] != '' || _gameOver) return;
    setState(() {
      _board[index] = _currentPlayer;
      if (_checkWinner(_currentPlayer)) {
        _gameOver = true;
        _winnerMessage = 'Player $_currentPlayer Wins!';
      } else if (!_board.contains('')) {
        _gameOver = true;
        _winnerMessage = "It's a Draw!";
      } else {
        _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
        if (_gameMode == GameMode.PlayerVsCPU && _currentPlayer == 'O' && !_gameOver) {
          _cpuMove();
        }
      }
    });
  }

  void _cpuMove() {
    int move;
    if (_difficulty == Difficulty.Easy) {
      move = _board.indexWhere((e) => e == '');
    } else if (_difficulty == Difficulty.Medium) {
      move = _findBestMove();
    } else {
      move = _findBestMove();
    }
    _makeMove(move);
  }

  int _findBestMove() {
    if (_difficulty == Difficulty.Hard) {
      int bestScore = -1000;
      int bestMove = -1;

      for (int i = 0; i < 9; i++) {
        if (_board[i] == '') {
          _board[i] = 'O'; // Simulate CPU move
          int score = _minimax(0, false);
          _board[i] = ''; // Undo the move
          if (score > bestScore) {
            bestScore = score;
            bestMove = i;
          }
        }
      }
      return bestMove;
    }

    for (int i = 0; i < 9; i++) {
      if (_board[i] == '') {
        _board[i] = 'O';
        if (_checkWinner('O')) {
          _board[i] = '';
          return i;
        }
        _board[i] = '';
      }
    }

    for (int i = 0; i < 9; i++) {
      if (_board[i] == '') {
        _board[i] = 'X';
        if (_checkWinner('X')) {
          _board[i] = '';
          return i;
        }
        _board[i] = '';
      }
    }
    return _board.indexWhere((e) => e == '');
  }

  int _minimax(int depth, bool isMaximizing) {
    if (_checkWinner('O')) return 10 - depth; // Favor CPU wins
    if (_checkWinner('X')) return depth - 10; // Penalize player wins
    if (!_board.contains('')) return 0; // Draw

    if (isMaximizing) {
      int bestScore = -1000;
      for (int i = 0; i < 9; i++) {
        if (_board[i] == '') {
          _board[i] = 'O'; // Simulate CPU move
          int score = _minimax(depth + 1, false);
          _board[i] = ''; // Undo move
          bestScore = max(bestScore, score);
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < 9; i++) {
        if (_board[i] == '') {
          _board[i] = 'X'; // Simulate Player move
          int score = _minimax(depth + 1, true);
          _board[i] = ''; // Undo move
          bestScore = min(bestScore, score);
        }
      }
      return bestScore;
    }
  }

  bool _checkWinner(String player) {
    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
      [0, 4, 8], [2, 4, 6]             // Diagonals
    ];
    for (var pattern in winPatterns) {
      if (_board[pattern[0]] == player &&
          _board[pattern[1]] == player &&
          _board[pattern[2]] == player) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text('Tic Tac Toe')),
        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Mode: ${_gameMode == GameMode.PlayerVsPlayer ? 'Player vs Player' : 'Player vs CPU'}${_gameMode == GameMode.PlayerVsCPU ? ' | Difficulty: ${_difficulty.name}' : ''}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (_winnerMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _winnerMessage,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    SizedBox(height: 20),
                    Center(
                      child: Container(
                        width: 300,
                        height: 300,
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                          itemCount: 9,
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: () => _makeMove(index),
                            child: Container(
                              margin: EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Center(
                                child: Text(
                                  _board[index],
                                  style: TextStyle(fontSize: 32, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: _restartGame,
                      tooltip: 'Restart Game',
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.settings),
                      onSelected: (value) {
                        if (value == 'Mode') {
                          _changeMode(_gameMode == GameMode.PlayerVsPlayer
                              ? GameMode.PlayerVsCPU
                              : GameMode.PlayerVsPlayer);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 'Mode', child: Text('Change Mode')),
                        if (_gameMode == GameMode.PlayerVsCPU)
                          PopupMenuItem(
                            value: 'Difficulty',
                            child: PopupMenuButton<Difficulty>(
                              onSelected: (difficulty) => _changeDifficulty(difficulty),
                              itemBuilder: (context) => [
                                PopupMenuItem(value: Difficulty.Easy, child: Text('Easy')),
                                PopupMenuItem(value: Difficulty.Medium, child: Text('Medium')),
                                PopupMenuItem(value: Difficulty.Hard, child: Text('Hard')),
                              ],
                              child: Text('Select Difficulty'),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
