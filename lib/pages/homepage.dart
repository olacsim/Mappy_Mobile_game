import 'package:flutter/material.dart';
import 'package:mappy_adventure/pages/playgame.dart';
import 'settings.dart';
import 'achievements.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Stack(
        children: [
          // Positioned image (no background, no decoration)
          Positioned(
            top: 5, // Adjust this to control the position of the image
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/icons/mappymainscreen.png',
                // No sizing constraints, allows it to use image pixel size
                fit: BoxFit
                    .cover, // Scale to fill the screen and maintain aspect ratio
                width: MediaQuery.of(context).size.width *
                    0.8, // Full screen width
                height: MediaQuery.of(context).size.height *
                    0.6, // Scale image to 40% of screen height
              ),
            ),
          ),
          // Positioned buttons towards the bottom center
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the Play Game page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PlayGamePage()),
                    );
                  },
                  child: Text('Play Game'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the Settings page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                    );
                  },
                  child: Text('Settings'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the Achievements page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AchievementsPage()),
                    );
                  },
                  child: Text('Achievements'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
