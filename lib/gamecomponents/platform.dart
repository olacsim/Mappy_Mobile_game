import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:mappy_adventure/gamecomponents/endlessworld.dart';

class Platform extends SpriteComponent
    with HasWorldReference<EndlessWorld>, TapCallbacks {
  Platform({
    super.position,
  }) : super(
            size: Vector2(
                46, 10)); //Set the scale we size the sprites to (46 * 10)

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Load platform sprite
    final sprite = await Sprite.load('world/platform.png');
    this.sprite = sprite;

    // Add a hitbox to the platform for collision detection TODO: make the hitbox also expand beneath the hitbox to better detect when we hit one when jumping and switch to falling
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Move the platform based on the world’s speed
    position.x -= world.speed * dt;

    // Remove the platform when it moves off-screen
    if (position.x + size.x < -world.size.x / 2) {
      removeFromParent();
    }
  }
}
