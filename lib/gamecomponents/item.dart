import 'dart:math'; // Import for random number generation
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:mappy_adventure/gamecomponents/endlessworld.dart';

class Item extends SpriteComponent with HasWorldReference<EndlessWorld> {
  static final Random _random = Random(); // Random generator instance

  // Define constants for sprite dimensions (from spritesheet)
  static const double spriteWidth = 16.0;
  static const double spriteHeight = 16.0;

  // Item constructor
  Item({
    super.position,
  }) : super(size: Vector2(36.0, 36.0));

  // Variable to store the points associated with this item
  late int points;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Load the spritesheet for items (16x16 pixels per item)
    final spriteSheet = await Sprite.load('items/items.png');

    // Randomly choose a spriteIndex
    final spriteIndex =
        _random.nextInt(5); // Directly limit to 5 sprite options

    // Extract the correct 16x16 sprite from the spritesheet using spriteIndex
    sprite = Sprite(
      spriteSheet.image,
      srcPosition:
          Vector2(spriteIndex * spriteWidth, 0), // Position in the spritesheet
      srcSize: Vector2(spriteWidth, spriteHeight), // Each item is 16x16
    );

    // Calculate points based on the spriteIndex (from 100 to 500)
    points = 100 + spriteIndex * 100;

    // Add a hitbox for collision detection
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move the item based on world speed and item speed
    position.x -= world.speed * dt;

    // Remove item from the screen once it's out of view
    if (position.x + size.x < -world.size.x / 2) {
      removeFromParent();
    }
  }
}
