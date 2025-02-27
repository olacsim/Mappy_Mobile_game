import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'pages/homepage.dart';
import 'audiomanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the settings plugin
  await Settings.init();

  // Get the saved volume from settings, or default to 50.0
  final savedVolume =
      Settings.getValue<double>('music_volume', defaultValue: 50.0);

  // Set up the initial theme mode
  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  runApp(MyApp(
    savedThemeMode: savedThemeMode,
    savedVolume: savedVolume,
  ));
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;
  final double? savedVolume;

  const MyApp({super.key, this.savedThemeMode, required this.savedVolume});

  @override
  Widget build(BuildContext context) {
    // If savedVolume is null, use 50.0 as the default volume
    final initialVolume = savedVolume ?? 50.0;

    // Initialize AudioManager with the saved or default volume
    final audioManager = AudioManager();
    audioManager.setMusicVolume(
        initialVolume / 100.0); // Ensure it's between 0.0 and 1.0

    //Stop any music that was playing before
    audioManager.stopMusic();

    // Play bonus level music when not in game.
    audioManager.playMusic('music/mappy_bonus.mp3');

    return AdaptiveTheme(
      light: ThemeData.light(useMaterial3: true),
      dark: ThemeData.dark(useMaterial3: true),
      initial: savedThemeMode ?? AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp(
        title: 'Settings',
        theme: theme,
        darkTheme: darkTheme,
        home: HomePage(),
      ),
    );
  }
}
