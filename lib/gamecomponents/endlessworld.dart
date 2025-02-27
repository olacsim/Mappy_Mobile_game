import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:mappy_adventure/gamecomponents/background.dart';
import 'package:mappy_adventure/gamecomponents/door.dart';
import 'package:mappy_adventure/gamecomponents/goro.dart';
import 'package:mappy_adventure/gamecomponents/item.dart';
import 'package:mappy_adventure/gamecomponents/mewski.dart';
import 'package:mappy_adventure/gamecomponents/platform.dart';
import 'package:mappy_adventure/gamecomponents/player.dart';
import 'package:mappy_adventure/gamecomponents/trampoline.dart';
import 'package:mappy_adventure/pages/playgame.dart';

// TODO: This class is the one most in need of fixes and revisions, particularly in how we place entities in the game world, Procedural generation rules,
// Ensuring we dont modify or add ontop of current world elements, and more. The other classes like player, mewski, and goro may need some minor adjustments
// For state managment, and collisions, but this class is where the most work is needed.
class EndlessWorld extends World with TapCallbacks, HasGameReference<PlayGame> {
  Vector2 get size => (parent as FlameGame).size;

  late final Player player;
  // Start with 3 lives, and no points.
  final scoreNotifier = ValueNotifier(0);
  final livesNotifier = ValueNotifier(3);
  late final DateTime timeStarted;

  late Background background;
  final Random random = Random();
  // Default speed at which all entities move (other than enemies).
  double speed = 30;

  // Timer to manage entitity spawning (the world is generated in chunks, and we wait before generating a new chunk)
  // Enemies also can only spawn periodically.
  double spawnTimer = 0;

  // Counter for the playtime
  double _playTimeInSeconds = 0;

  // Getter for playtime
  int get playTime => _playTimeInSeconds.toInt();

  // Ensure we dont keep updating after we lose.
  bool gameOverExecuted = false;

  // Divide the screen across the y axis into 4 pieces so that each section will be an equal distance from eachother
  // And add on offset to properly position the floors on the screen.
  late final List<double> platformHeights = List.generate(4, (index) {
    double segmentHeight = -size.y / 4;
    return segmentHeight * (index + 1) + 250;
  });

  @override
  Future<void> onLoad() async {
    super.onLoad();
    timeStarted = DateTime.now();

// Initialize the player
    player = Player(
        background: game.background,
        position: Vector2(-size.x / 4, platformHeights[0] - 50),
        addScore: addScore,
        removeLives: removeLives);
    add(player);

// Start the game with one mewski
    Mewski mewski =
        Mewski(position: Vector2(-size.x / 4 - 70, platformHeights[0] - 50));
    add(mewski);

// Generate intitial entities.
    generateInitialFloors();
    generateDoors(-size.x, size.x);
    generateItems(-size.x, size.x);
    generateRoof(-size.x, size.x);
  }

  // Define functions for the player constructor's parameters. (Also see the player class onCollision method)
  void addScore({int amount = 1}) => scoreNotifier.value += amount;
  void removeLives({int amount = 1}) => livesNotifier.value -= amount;

  @override
  void update(double dt) {
    super.update(dt);

    // Update the play time and spawn timer.
    if (livesNotifier.value > 0) {
      _playTimeInSeconds += dt;
      spawnTimer += dt;
    }

    // End the games when we are out of lives.
    if (livesNotifier.value == 0 && !gameOverExecuted) {
      game.endGame();
      gameOverExecuted = true; // Ensure the game over logic runs only once
      return;
    }

    // Variables to track the right edge, and help us generate new elements offscreen.
    final double rightEdge = size.x / 2;
    final double endOfTheWorld = rightEdge * 2;

    // Add new elements to the world and spawn enemies every 15 seconds.
    if (spawnTimer >= 15) {
      _generateOffscreenElements(rightEdge, endOfTheWorld);
      spawnEnemy(-rightEdge / 4 - 70,
          platformHeights[random.nextInt(platformHeights.length - 1)] - 50);
      spawnTimer = 0;
    }
  }

  // Periodically generate new  elements off-screen which will enter the visible area as the player progresses:
  // - startingX is the current rightmost visible point of the screen where new elements should start appearing.
  // - endingX is the point one full screen width away where generation should stop,
  void _generateOffscreenElements(double startingX, double endingX) {
    for (int i = 0; i < platformHeights.length - 1; i++) {
      generateFloor(startingX, endingX, platformHeights[i],
          trampolineChance: 0.25, minGap: 3);
      // For some reason, calling the methods below outside of this for loop doesn't work. TODO: FIX.
      generateRoof(startingX, endingX);
      generateDoors(startingX, endingX);
      generateItems(startingX, startingX);
    }
  }

  void generateInitialFloors() {
    for (int i = 0; i < platformHeights.length - 1; i++) {
      generateFloor(-size.x, size.x, platformHeights[i],
          trampolineChance: 0.25, minGap: 3);
    }
    generateRoof(-size.x, size.x);
  }

  void generateFloor(double startingX, double endingX, double yPos,
      {required double trampolineChance, required int minGap}) {
    double platformWidth = 46.0;
    double lastTrampolinePos = -double.infinity;

    // List to keep track of trampoline positions
    List<double> trampolinesBelow = [];

    while (startingX < endingX) {
      // Check if there's a trampoline directly below this position
      bool isTrampolineBelow = trampolinesBelow.any(
          (trampolineX) => (startingX - trampolineX).abs() < platformWidth);

      if (isTrampolineBelow) {
        // Skip generating a platform at the same x position as a trampoline (creating the gap)
        startingX += platformWidth;
        continue;
      }

      // Chance of placing a trampoline, making sure it respects the minGap constraint
      bool placeTrampoline = random.nextDouble() < trampolineChance &&
          (startingX - lastTrampolinePos >= platformWidth * minGap);

      if (placeTrampoline) {
        spawnTrampoline(startingX, yPos);
        trampolinesBelow.add(startingX); // Add trampoline position to the list
        lastTrampolinePos = startingX; // Update last trampoline position
      } else {
        spawnPlatform(startingX, yPos); // Place a normal platform
      }

      startingX += platformWidth;
    }
  }

  // Method to generate the roof
  void generateRoof(double startingX, double endingX) {
    double platformWidth = 46.0;
    double yPos = platformHeights[3];

    while (startingX < endingX) {
      spawnPlatform(startingX, yPos);
      startingX += platformWidth;
    }
  }

  void generateDoors(double startingX, double endingX) {
    double platformWidth = 46.0;
    double doorChance = 0.05;

    for (double yPos in platformHeights) {
      if (yPos == platformHeights[3]) continue; // Skip the highest platform

      double tempStartingX = startingX; // Reset startingX for each floor

      while (tempStartingX < endingX) {
        if (_hasPlatform(tempStartingX, yPos) &&
            random.nextDouble() < doorChance) {
          Door door = Door(position: Vector2(tempStartingX, yPos - 95));
          add(door);
        }
        tempStartingX += platformWidth; // Increment for next door spawn
      }
    }
  }

  // Method to add items to the game world
  void generateItems(double startingX, double endingX) {
    double platformWidth = 46.0;
    double itemChance = 0.25;

    for (double yPos in platformHeights) {
      if (yPos == platformHeights[3]) continue; // Skip the highest platform

      double lastItemPos = -double.infinity;
      double tempStartingX = startingX; // Reset startingX for each floor

      while (tempStartingX < endingX) {
        if (_hasPlatform(tempStartingX, yPos)) {
          if (tempStartingX - lastItemPos >= platformWidth * 2) {
            bool hasDoor = _hasDoor(tempStartingX, yPos);
            bool hasTrampoline = _hasTrampoline(tempStartingX, yPos);

            if (!hasDoor &&
                !hasTrampoline &&
                random.nextDouble() < itemChance) {
              Item item = Item(
                  position:
                      Vector2(tempStartingX + platformWidth / 4, yPos - 35));
              add(item);
              lastItemPos = tempStartingX;
            }
          }
        }
        tempStartingX +=
            platformWidth; // Increment starting position for each item spawn
      }
    }
  }

  void spawnEnemy(double xPosition, double yPosition) {
    int currentEnemyCount =
        children.query<Mewski>().length + children.query<Goro>().length;

// Add an enemy with a random chance if there are less than 5 enemies.
    if (currentEnemyCount < 5) {
      if (random.nextDouble() < 0.25) {
        Goro goro = Goro(position: Vector2(xPosition, yPosition));
        add(goro);
      } else {
        Mewski mewski = Mewski(position: Vector2(xPosition, yPosition));
        add(mewski);
      }
    }
  }

  void spawnPlatform(double startingX, double yPos) {
    Platform platform = Platform(position: Vector2(startingX, yPos));
    add(platform);
  }

  void spawnTrampoline(double startingX, double yPos) {
    Trampoline trampoline = Trampoline(position: Vector2(startingX, yPos));
    add(trampoline);
  }

  bool _hasTrampoline(double startingX, double yPos) {
    return children
        .whereType<Trampoline>()
        .any((t) => t.position == Vector2(startingX, yPos));
  }

  bool _hasPlatform(double startingX, double yPos) {
    return children
        .whereType<Platform>()
        .any((p) => p.position == Vector2(startingX, yPos));
  }

  bool _hasDoor(double startingX, double yPos) {
    return children
        .whereType<Door>()
        .any((d) => d.position == Vector2(startingX, yPos));
  }

// Detect screen taps (used for jumping to platforms in the world, screen taps for doors are in door class)
  @override
  void onTapDown(TapDownEvent event) {
    final tapPosition = event.localPosition;

    if (player.current == PlayerState.jumping ||
        player.current == PlayerState.falling) {
      Platform? closestPlatform = _findClosestPlatform(tapPosition);

// Move the player to the platform, and ensure it is a valid platform.
      if (closestPlatform != null &&
          closestPlatform.x > player.x &&
          closestPlatform.y > platformHeights[3] + 50 &&
          closestPlatform.x - player.x < 150) {
        player.moveToPlatform(closestPlatform);
      }
    }
  }

// Find the closest platform to the screen tap
  Platform? _findClosestPlatform(Vector2 tapPosition) {
    Platform? closestPlatform;
    double closestDistance = double.infinity;

    for (var platform in children.whereType<Platform>()) {
      double distance = (tapPosition - platform.position).length;
      if (distance < closestDistance) {
        closestDistance = distance;
        closestPlatform = platform;
      }
    }
    return closestPlatform;
  }
}
