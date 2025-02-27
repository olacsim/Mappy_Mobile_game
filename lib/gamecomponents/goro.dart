import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:mappy_adventure/gamecomponents/endlessworld.dart';
import 'package:mappy_adventure/gamecomponents/door.dart';
import 'package:mappy_adventure/gamecomponents/item.dart';
import 'package:mappy_adventure/gamecomponents/platform.dart';
import 'package:mappy_adventure/gamecomponents/player.dart';
import 'package:mappy_adventure/gamecomponents/trampoline.dart';
import 'package:mappy_adventure/pages/playgame.dart';

// States the Goro can be in
enum GoroState {
  running,
  jumping,
  falling,
}

class Goro extends SpriteAnimationGroupComponent<GoroState>
    with
        HasWorldReference<EndlessWorld>,
        HasGameReference<PlayGame>,
        CollisionCallbacks {
  double jumpSpeed = 30;
  double moveSpeed = 10; // Move twice as fast as mewski

  late Vector2 targetPosition; // Position of Mappy

  Goro({
    super.position,
  }) : super(
          size: Vector2.all(50),
          priority:
              2, // Priority 2 means it's rendered above most objects except the player. Size scales it to 50 * 50
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Load the animations
    animations = {
      GoroState.running: await game.loadSpriteAnimation(
        'goro/run.png',
        SpriteAnimationData.sequenced(
          amount: 3,
          textureSize: Vector2.all(16),
          stepTime: 0.15,
        ),
      ),
      GoroState.jumping: SpriteAnimation.spriteList(
        [await game.loadSprite('goro/jump.png')],
        stepTime: double.infinity,
      ),
      GoroState.falling: SpriteAnimation.spriteList(
        [await game.loadSprite('goro/jump.png')],
        stepTime: double.infinity,
      ),
    };

    // Default to 'running' state
    current = GoroState.running;

    // Add a collision hitbox
    add(RectangleHitbox());

    // Set target position to Mappy's position
    targetPosition = world.player.position;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Stop horizontal movement during jump
    if (current == GoroState.jumping) {
      // Keep Goro's X position constant while jumping
      position.x = position.x;

      // Handle vertical movement (jumping)
      if (position.y > targetPosition.y) {
        position.y -= jumpSpeed * dt; // Jump upwards
      } else {
        // Once at the target Y position, move to the platform and switch to running state
        Platform? closestPlatform = findClosestPlatform(targetPosition.y);
        if (closestPlatform != null) {
          moveToPlatform(closestPlatform);
        }
        current = GoroState.running;
      }
    } else if (current == GoroState.falling) {
      // Handle falling behavior
      position.x =
          position.x; // Keep the same horizontal position while falling
      if (position.y < targetPosition.y) {
        position.y +=
            jumpSpeed * dt; // Fall down if we are above the target Y position
      }
    } else if (current == GoroState.running) {
      // Move forward towards Mappy's X position
      if (position.x <= targetPosition.x) {
        position.x += moveSpeed * dt;
      } else {
        position.x = position.x; // Stay in place if the X position is reached
      }
      // Remove item from the screen if it goes back to far.
      if (position.x + size.x < -world.size.x / 2) {
        removeFromParent();
      }
    }
  }

  // Method to move Goro to the closest platform at the same y level as mappy.
  void moveToPlatform(Platform platform) {
    position.x = platform.position.x;
    position.y =
        platform.position.y - 50; // Ofset due to size sprite is scaled to.

    current = GoroState.running;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Door) {
      // If we run into a closed door, go back a bit before opening and proceeding through.
      if (!other.isOpen) {
        Future.delayed(Duration(seconds: 1), () {
          position.x -= 25;
          other.toggleDoor();
        });
        // Ignore when the door is already open
      }
    } else if (other is Trampoline) {
      current = GoroState.jumping;
    } else if (other is Platform) {
      // If jumping, transition to falling when platform is hit
      if (current == GoroState.jumping) {
        current = GoroState.falling;
      } else {
        current = GoroState.running;
      }
    } else if (other is Player) {
      // This logic is handled in the player class.
    } else if (other is Item) {
      // New gameplay mechanic: cats steal items 😸 and when they do you lose points.
      other.removeFromParent();
      world.player.addScore(amount: -other.points);
      current = GoroState.running;
    } else if (other is Goro || other is Goro) {
      // Move back slightly
      position.x -= 10;
      current = GoroState.running;
    } else {
      // If no collision and we were running, transition to falling
      if (current == GoroState.running) {
        current = GoroState.falling;
      }
    }
  }

// Method to find the closest platform at the same floor level as Mappy.
  Platform? findClosestPlatform(double targetY) {
    Platform? closestPlatform;
    double closestDistance =
        double.infinity; // Start with an infinitely large distance

    // Loop through all platforms and find the one at the same Y level as Mappy
    for (var platform in world.children.query<Platform>()) {
      // Check if the platform is at the same floor level (Y position)
      if ((platform.position.y - platform.size.y) <= targetY &&
          platform.position.y >= targetY) {
        // Calculate the horizontal distance between Goro and the platform
        double distance = (position.x - platform.position.x).abs();

        // Check if this platform is closer than the previously found one
        if (distance < closestDistance) {
          closestDistance = distance;
          closestPlatform = platform; // Update closest platform
        }
      }
    }
    return closestPlatform; // Return the closest platform
  }
}
