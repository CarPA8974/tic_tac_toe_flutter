import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TicTacToeScreen(),
    );
  }
}

class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key});

  @override
  _TicTacToeScreenState createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  List<String> board = List.filled(9, "");
  String currentPlayer = "X";
  bool isAgainstComputer = false;
  String difficulty = "Easy";

  void _handleTap(int index) {
    if (board[index] == "") {
      setState(() {
        board[index] = currentPlayer;
        if (_checkWin(currentPlayer)) {
          _showDialog("Player $currentPlayer wins!");
          return;
        }
        if (_checkDraw()) {
          _showDialog("It's a draw!");
          return;
        }
        currentPlayer = currentPlayer == "X" ? "O" : "X";
        if (isAgainstComputer && currentPlayer == "O") {
          _computerMove();
        }
      });
    }
  }

  void _computerMove() {
    int bestMove = -1;
    if (difficulty == "Easy") {
      List<int> availableMoves = []; // Corrected syntax
      for (int i = 0; i < board.length; i++) {
        if (board[i] == "") {
          availableMoves.add(i);
        }
      }
      if (availableMoves.isNotEmpty) {
        Random random = Random();
        bestMove = availableMoves[random.nextInt(availableMoves.length)];
      }
    } else {
      int bestScore = -100;

      for (int i = 0; i < board.length; i++) {
        if (board[i] == "") {
          board[i] = "O";
          int score = minimax(board, 0, false);
          board[i] = "";

          if (score > bestScore) {
            bestScore = score;
            bestMove = i;
          }
        }
      }
    }
    if (bestMove != -1) {
      _handleTap(bestMove);
    }
  }

  int minimax(List<String> board, int depth, bool isMaximizing) {
    if (_checkWin("X")) {
      return -1;
    }
    if (_checkWin("O")) {
      return 1;
    }
    if (_checkDraw()) {
      return 0;
    }

    if (isMaximizing) {
      int bestScore = -100;
      for (int i = 0; i < board.length; i++) {
        if (board[i] == "") {
          board[i] = "O";
          int score = minimax(board, depth + 1, false);
          board[i] = "";
          bestScore = max(score, bestScore);
        }
      }
      return bestScore;
    } else {
      int bestScore = 100;
      for (int i = 0; i < board.length; i++) {
        if (board[i] == "") {
          board[i] = "X";
          int score = minimax(board, depth + 1, true);
          board[i] = "";
          bestScore = min(score, bestScore);
        }
      }
      return bestScore;
    }
  }

  bool _checkWin(String player) { // Corrected: Added the method
    for (int i = 0; i < 9; i += 3) {
      if (board[i] == player && board[i + 1] == player && board[i + 2] == player) {
        return true;
      }
    }
    for (int i = 0; i < 3; i++) {
      if (board[i] == player && board[i + 3] == player && board[i + 6] == player) {
        return true;
      }
    }
    if (board[0] == player && board[4] == player && board[8] == player) {
      return true;
    }
    if (board[2] == player && board[4] == player && board[6] == player) {
      return true;
    }
    return false;
  }

  bool _checkDraw() { // Corrected: Added the method
    return !board.contains("");
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("Restart"),
              onPressed: () {
                setState(() {
                  board = List.filled(9, "");
                  currentPlayer = "X";
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... (rest of the build method remains the same)
      return Scaffold(
      appBar: AppBar(
        title: Text("Tic Tac Toe"),
      ),
      body: Center( // Center the GridView
        child: SizedBox( // Constrain the size of the GridView
          width: 300, // Adjust as needed
          height: 300,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _handleTap(index),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  child: Center(
                    child: Text(
                      board[index],
                      style: TextStyle(fontSize: 40),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton( // Cog icon menu
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      title: Text('1 Player'),
                      onTap: () {
                        Navigator.pop(context); // Close bottom sheet
                        _showDifficultySelection();
                      },
                    ),
                    ListTile(
                      title: Text('2 Players'),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          isAgainstComputer = false;
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: Icon(Icons.settings), // Cog icon
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showDifficultySelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('Easy'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    isAgainstComputer = true;
                    difficulty = "Easy";
                  });
                },
              ),
              ListTile(
                title: Text('Medium'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    isAgainstComputer = true;
                    difficulty = "Medium";
                  });
                },
              ),
              ListTile(
                title: Text('Hard'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    isAgainstComputer = true;
                    difficulty = "Hard";
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}