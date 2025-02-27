import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:mappy_adventure/audiomanager.dart';
import 'package:mappy_adventure/gamecomponents/background.dart';
import 'package:mappy_adventure/gamecomponents/door.dart';
import 'package:mappy_adventure/gamecomponents/endlessworld.dart';
import 'package:mappy_adventure/gamecomponents/goro.dart';
import 'package:mappy_adventure/gamecomponents/item.dart';
import 'package:mappy_adventure/gamecomponents/platform.dart';
import 'package:mappy_adventure/gamecomponents/trampoline.dart';
import 'package:mappy_adventure/gamecomponents/mewski.dart';
import 'package:mappy_adventure/pages/playgame.dart';

// States the player can be in
enum PlayerState {
  running,
  jumping,
  falling,
  lifeLoss,
}

class Player extends SpriteAnimationGroupComponent<PlayerState>
    with
        CollisionCallbacks,
        HasWorldReference<EndlessWorld>,
        HasGameReference<PlayGame> {
  Background background;

  Player({
    required this.background,
    required this.addScore,
    required this.removeLives,
    super.position,
  }) : super(
            size: Vector2.all(50),
            priority:
                1); // Priority 1 means we render it above all other game objects. Size scales it to 50 * 50 pixels

  final void Function({int amount}) addScore;
  final void Function({int amount}) removeLives;

  @override
  Future<void> onLoad() async {
    super.onLoad();

// Load the sprites for each state and make animations where needed.
    animations = {
      PlayerState.running: await game.loadSpriteAnimation(
        'mappy/run.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          textureSize: Vector2.all(16),
          stepTime: 0.15,
        ),
      ),
      PlayerState.jumping: SpriteAnimation.spriteList(
        [await game.loadSprite('mappy/jump.png')],
        stepTime: double.infinity,
      ),
      PlayerState.falling: SpriteAnimation.spriteList(
        [await game.loadSprite('mappy/jump.png')],
        stepTime: double.infinity,
      ),
      PlayerState.lifeLoss: await game.loadSpriteAnimation(
        'mappy/life_loss.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          textureSize: Vector2.all(16),
          stepTime: 0.15,
        ),
      ),
    };

    // Default State
    current = PlayerState.running;

    // Hitbox for collisions.
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // If jumping move up
    if (current == PlayerState.jumping) {
      position.y -= 30 * dt;
    }

    // If falling move down
    if (current == PlayerState.falling) {
      position.y += 30 * dt;
    }
    // We dont need to account for changing player position in the running state because the world and it's entities move around us.
  }

// Method to move the player to a platform after a jump (see the endless world class on tap down method as well)
  void moveToPlatform(Platform platform) {
    position.x = platform.position.x;
    position.y = platform.position.y -
        50; // Offset because mappy's sprite is 50 pixels tall

    // After moving to the platform resume game movement
    world.speed = 30;
    background.resumeMovement();
    current = PlayerState.running;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Door) {
      // After running into a door, move back slightly, and after a short delay move forward again.
      if (!other.isOpen) {
        world.speed = -10;
        background.stopMovement();
        Future.delayed(Duration(milliseconds: 200), () {
          world.speed = 30;
          background.resumeMovement();
        });
      }
      // After running into an enemy, transition to the life loss state, lose a life (see endless world class removeLives method), and play a sound effect.
      // If we are out of lives, end the game (see playgame  endGame method), otherwise resume playing after a short delay.
    } else if (other is Mewski || other is Goro) {
      if (current == PlayerState.running) {
        current = PlayerState.lifeLoss;
        other.removeFromParent();
        AudioManager().playSfx('sfx/life_loss.mp3');
        removeLives();
        world.speed = 0;
        background.stopMovement();

        Future.delayed(Duration(seconds: 1), () {
          current = PlayerState.running;
          world.speed = 30;
          background.resumeMovement();
        });
      }
    } else if (other is Item) {
      AudioManager().playSfx('sfx/pickup.mp3');
      addScore(amount: other.points);
      other.removeFromParent();
    } else if (other is Trampoline) {
      // Move to the center of the trampoline
      position.x = other.position.x + (other.size.x - size.x) / 2;
      AudioManager().playSfx('sfx/bounce.mp3');
      background.stopMovement();
      world.speed = 0;
      current = PlayerState.jumping;
    } else if (other is Platform) {
      // If jumping, transition to falling when platform is hit
      if (current == PlayerState.jumping) {
        current = PlayerState.falling;
      } else {
        current = PlayerState.running;
      }
    } else {
      // If no collision and we were running, transition to falling (We fall through a gap between platforms)
      if (current == PlayerState.running) {
        current = PlayerState.falling;
      }
    }
  }
}
