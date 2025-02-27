import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:mappy_adventure/gamecomponents/endlessworld.dart';
import 'package:mappy_adventure/pages/playgame.dart';

class Trampoline extends SpriteComponent
    with HasGameReference<PlayGame>, HasWorldReference<EndlessWorld> {
  Trampoline({
    super.position,
  }) : super(
            size: Vector2(
                46, 10)); //Set the scale we size the sprites to (46 * 10)

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Load trampoline sprite
    final sprite = await Sprite.load('world/trampoline.png');
    this.sprite = sprite;

// Add a slightly raised hitbox above the trampoline to ensuring player and enemies transition to 'jumping' before fully overlapping the trampoline's surface.
    add(RectangleHitbox(position: Vector2(0, -10), size: Vector2(width, 10)));
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move the trampoline based on the world's speed
    position.x -= world.speed * dt;

    // Remove the trampoline when it moves off-screen
    if (position.x + size.x < -world.size.x / 2) {
      removeFromParent();
    }
  }
}
