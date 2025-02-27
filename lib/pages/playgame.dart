import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mappy_adventure/audiomanager.dart';
import 'package:mappy_adventure/gamecomponents/background.dart';
import 'package:mappy_adventure/gamecomponents/endlessworld.dart';
import 'package:mappy_adventure/pages/gameover.dart';

class PlayGamePage extends StatefulWidget {
  const PlayGamePage({super.key});

  @override
  _PlayGamePageState createState() => _PlayGamePageState();
}

class _PlayGamePageState extends State<PlayGamePage> {
  @override
  void initState() {
    super.initState();
    // Set the screen orientation to landscape when this page is loaded
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void dispose() {
    // Reset the screen orientation when leaving the page
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hide system UI to make the game fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return GameWidget(
      game: PlayGame(context),
    );
  }
}

class PlayGame extends FlameGame<EndlessWorld> with HasCollisionDetection {
  late List<TextComponent> heartIcons;
  late Background background;
  final Random random = Random();
  final BuildContext context;

  PlayGame(this.context)
      : super(
          world: EndlessWorld(),
        );

  @override
  Future<void> onLoad() async {
    // Stop any currently playing music and play the main theme
    AudioManager().stopMusic();
    AudioManager().playMusic('music/mappy_main.mp3');

    // Get the device's screen size for the camera
    final deviceScreenSize = Vector2(
      MediaQuery.of(context).size.width,
      MediaQuery.of(context).size.height,
    );

    // Set up the camera to use the screen size
    camera = CameraComponent.withFixedResolution(
      width: deviceScreenSize.x,
      height: deviceScreenSize.y,
    );

    // Setup the camera resolution and backdrop
    background = Background(); // Create the background
    camera.backdrop.add(background); // Add it to the backdrop

    // Initialize the text elements
    final scoreText = 'Score: 0';
    final livesText = '♥ ♥ ♥';

    // Initialize score text and add to viewport
    final scoreComponent = TextComponent(
      text: scoreText,
      position: Vector2(15, 40),
      textRenderer:
          TextPaint(style: TextStyle(color: Colors.white, fontSize: 22)),
    );
    camera.viewport.add(scoreComponent);

    // Initialize lives text and add to viewport
    final livesComponent = TextComponent(
      text: livesText, // Heart symbol for life
      position: Vector2(10, 10),
      textRenderer:
          TextPaint(style: TextStyle(color: Colors.red, fontSize: 22)),
    );
    camera.viewport.add(livesComponent);

    // Add a listener to the notifier that is updated when the player
    // gets points, in the callback we update the text of the `scoreComponent`.
    world.scoreNotifier.addListener(() {
      scoreComponent.text =
          scoreText.replaceFirst('0', '${world.scoreNotifier.value}');
    });

    // Add a listener to the notifier that is updated when the player
    // loses a life, in the callback we update the text of the `livesComponent`.
    world.livesNotifier.addListener(() {
      // Update the hearts based on the number of lives left
      final hearts = '♥ ' * world.livesNotifier.value;
      livesComponent.text = hearts.trim();
    });
  }

  // This method is called when the player runs out of lives, it will
  // navigate to the GameOverScreen, passing in score and time survived.
  void endGame() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GameOverScreen(
          score: world.scoreNotifier.value,
          timeSurvived: world.playTime,
        ),
      ),
    );
  }
}
