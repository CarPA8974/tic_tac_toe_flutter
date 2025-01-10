import 'package:flutter/material.dart';

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
  int _playerXScore = 0;
  int _playerOScore = 0;
  int _cpuScore = 0;

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
        if (_gameMode == GameMode.PlayerVsPlayer) {
          if (_currentPlayer == 'X') {
            _playerXScore++;
          } else {
            _playerOScore++;
          }
        } else if (_gameMode == GameMode.PlayerVsCPU) {
          if (_currentPlayer == 'X') {
            _playerXScore++;
          } else {
            _cpuScore++;
          }
        }
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

  bool _checkWinner(String player) {
    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text('Player X', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('$_playerXScore', style: TextStyle(fontSize: 24)),
                        ],
                      ),
                      if (_gameMode == GameMode.PlayerVsPlayer)
                        Column(
                          children: [
                            Text('Player O', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('$_playerOScore', style: TextStyle(fontSize: 24)),
                          ],
                        ),
                      if (_gameMode == GameMode.PlayerVsCPU)
                        Column(
                          children: [
                            Text('CPU', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('$_cpuScore', style: TextStyle(fontSize: 24)),
                          ],
                        ),
                    ],
                  ),
                ),
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
                            color: const Color.fromARGB(255, 148, 154, 165),
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
                        if (value == 'Player vs Player') {
                          _changeMode(GameMode.PlayerVsPlayer);
                        } else if (value == 'Player vs CPU') {
                          _changeMode(GameMode.PlayerVsCPU);
                        } else if (value == 'Easy') {
                          _changeDifficulty(Difficulty.Easy);
                        } else if (value == 'Medium') {
                          _changeDifficulty(Difficulty.Medium);
                        } else if (value == 'Hard') {
                          _changeDifficulty(Difficulty.Hard);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(child: Text('Player vs Player'), value: 'Player vs Player'),
                        PopupMenuItem(child: Text('Player vs CPU'), value: 'Player vs CPU'),
                        if (_gameMode == GameMode.PlayerVsCPU) ...[
                          PopupMenuItem(child: Text('Easy'), value: 'Easy'),
                          PopupMenuItem(child: Text('Medium'), value: 'Medium'),
                          PopupMenuItem(child: Text('Hard'), value: 'Hard'),
                        ],
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
