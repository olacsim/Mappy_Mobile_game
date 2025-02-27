import 'package:flutter/material.dart';
import 'package:mappy_adventure/pages/homepage.dart';
import '../audiomanager.dart';

// Game Over Screen
class GameOverScreen extends StatelessWidget {
  final int score;
  final int timeSurvived;

  // Constructor
  const GameOverScreen({
    super.key,
    required this.score,
    required this.timeSurvived,
  });

  @override
  Widget build(BuildContext context) {
    AudioManager().stopMusic();
    AudioManager().playMusic('music/game_lost.mp3');

    return Scaffold(
      appBar: AppBar(
        title: Text('Game Over'),
        backgroundColor: Colors.redAccent, // App bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Displaying the score
            Text(
              'Game Over!',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Score: $score',
              style: TextStyle(fontSize: 24),
            ),
            // Format and display timeSurvived
            Text(
              'Time Survived: ${_formatTime(timeSurvived)}',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 50),
            // Floating action button to go back to main menu
            FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.home),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to format the time
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
