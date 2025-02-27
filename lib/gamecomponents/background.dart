import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';

// Multiple scrolling images (with layers at different speeds) form a parallax
// This simulates movement and depth in the background.
class Background extends ParallaxComponent {
  late Vector2 baseVelocity;

  // Method to stop parallax movement (Use when mappy is stuck at a closed door or bouncing on a trampoline)
  void stopMovement() {
    baseVelocity = Vector2.zero();
  }

  // Method to resume parallax movement
  void resumeMovement() {
    baseVelocity = Vector2(30, 0); // Resume movement at original speed
  }

  @override
  // Load the parallax layers
  Future<void> onLoad() async {
    final layers = [
      ParallaxImageData('world/layer_1.png'),
      ParallaxImageData('world/layer_2.png'),
      ParallaxImageData('world/layer_3.png'),
      ParallaxImageData('world/layer_4.png'),
      ParallaxImageData('world/layer_5.png'),
      ParallaxImageData('world/layer_6.png'),
      ParallaxImageData('world/layer_7.png'),
    ];

    // Base velocity determines the speed of the farthest back layer
    baseVelocity = Vector2(30, 0);

    // Multiplier for each layer's velocity relative to the previous layer
    final velocityMultiplierDelta = Vector2(1.4, 0);

    // Initialize parallax
    parallax = await game.loadParallax(
      layers,
      baseVelocity: baseVelocity,
      velocityMultiplierDelta: velocityMultiplierDelta,
      filterQuality: FilterQuality.none,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Apply the velocity to the parallax movement (ensuring null saftey)
    parallax?.baseVelocity = baseVelocity;
  }
}
