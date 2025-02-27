import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:mappy_adventure/audiomanager.dart';
import 'package:mappy_adventure/gamecomponents/endlessworld.dart';
import 'package:mappy_adventure/pages/playgame.dart';

// THE DOOR! THE DOOR! THE DOOR IS EVERYTHING, ALL THAT ONCE WAS AND ALL THAT WILL BE. THE DOOR CONTROLS TIME AND SPACE
// LOVE AND DEATH! THE DOOR CAN SEE INTO YOUR MIND! THE DOOR CAN SEE INTO YOUR SOUL!...
// Really, the door can do all that? HAHA NO! -Charlie the Unicorn

// The [Door] component represents a door that can be opened or closed
// and can block the player, mewskies, and goros from passing through when closed.
class Door extends SpriteComponent
    with
        HasWorldReference<EndlessWorld>,
        HasGameReference<PlayGame>,
        TapCallbacks {
  bool isOpen = false;
  late final Sprite openedSprite;
  late final Sprite closedSprite;
  late final RectangleHitbox hitbox;

  // Constructor
  Door({
    super.position,
  }) : super(size: Vector2(18, 95)); // Default size when closed

  @override
  Future<void> onLoad() async {
    // Load the closed and opened door sprites
    closedSprite = await game.loadSprite('world/door_closed.png');
    openedSprite = await game.loadSprite('world/door_opened.png');

    // Set the initial sprite and add the collision hitbox
    sprite = closedSprite;
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move the door based on the world's speed
    position.x -= world.speed * dt;

    // Remove the door when it moves off-screen
    if (position.x + size.x < -world.size.x / 2) {
      removeFromParent();
    }
  }

  // Toggle the door's state (open or closed) and update its collision type
  void toggleDoor() {
    // Change the door's state.
    isOpen = !isOpen;

    // Update the door's sprite and scaled size based on its state
    sprite = isOpen ? openedSprite : closedSprite;
    size = isOpen ? Vector2(45, 95) : Vector2(18, 95);

    // Play a sound effect based on if opening or closing door
    AudioManager().playSfx(isOpen ? 'sfx/door_open.mp3' : 'sfx/door_close.mp3');
  }

  @override
  void onTapDown(TapDownEvent event) {
    // When the door is tapped, toggle its open/closed state
    toggleDoor();
  }
}
