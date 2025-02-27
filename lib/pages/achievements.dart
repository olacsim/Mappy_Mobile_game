// achievements.dart
import 'package:flutter/material.dart';
import 'package:mappy_adventure/audiomanager.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Stop the bonus music
    AudioManager().stopMusic();

    // Start the achivements theme when the user enters the Achievements page
    AudioManager().playMusic('music/achievements.mp3');

    // Sample achievement data
    final Map<String, String> achievements = {
      'Items Collected': '120 items',
      'Time Played': '5 hours 32 minutes',
      'Highest Score': '5000 points',
      'Longest Run': '2 minutes 45 seconds',
    };

    return WillPopScope(
      onWillPop: () async {
        // When the back button is pressed (top-left back button or device back button),
        // Stop the theme
        AudioManager().stopMusic();
        // Restart the bonus level music before popping the page.
        AudioManager().playMusic('music/mappy_bonus.mp3');
        return true; // Allow the pop (i.e., go back to the previous page)
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Achievements'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Achievements',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20), // Add space between title and list

              // List of achievements
              Expanded(
                child: ListView(
                  children: achievements.entries.map((entry) {
                    return ListTile(
                      title: Text(
                        entry.key, // Achievement name
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(entry.value), // Achievement value
                      leading: Icon(Icons.emoji_events),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
