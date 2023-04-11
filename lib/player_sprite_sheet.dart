import 'package:bonfire/bonfire.dart';

class PlayerSpriteSheet {
  static Future<SpriteAnimation> get idleLeft => SpriteAnimation.load(
        "player/tankLeft.png",
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: 1,
          textureSize: Vector2(100, 100),
        ),
      );

  static Future<SpriteAnimation> get idleRight => SpriteAnimation.load(
        "player/tankRight.png",
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: 1,
          textureSize: Vector2(100, 100),
        ),
      );

  static Future<SpriteAnimation> get idleUp => SpriteAnimation.load(
    "player/tankForward.png",
    SpriteAnimationData.sequenced(
      amount: 1,
      stepTime: 1,
      textureSize: Vector2(100, 100),
    ),
  );
  static Future<SpriteAnimation> get idleDown => SpriteAnimation.load(
    "player/tanktoward.png",
    SpriteAnimationData.sequenced(
      amount: 1,
      stepTime: 1,
      textureSize: Vector2(100, 100),
    ),
  );

  static Future<SpriteAnimation> get runRight => SpriteAnimation.load(
        "player/tankRight.png",
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: 1,
          textureSize: Vector2(100, 100),
        ),
      );

  static Future<SpriteAnimation> get runLeft => SpriteAnimation.load(
        "player/tankLeft.png",
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: 1,
          textureSize: Vector2(100, 100),
        ),
      );

  static Future<SpriteAnimation> get runUp => SpriteAnimation.load(
    "player/tankForward.png",
    SpriteAnimationData.sequenced(
      amount: 1,
      stepTime: 1,
      textureSize: Vector2(100, 100),
    ),
  );

  static Future<SpriteAnimation> get runDown => SpriteAnimation.load(
    "player/tanktoward.png",
    SpriteAnimationData.sequenced(
      amount: 1,
      stepTime: 1,
      textureSize: Vector2(100, 100),
    ),
  );

  static SimpleDirectionAnimation get simpleDirectionAnimation =>
      SimpleDirectionAnimation(
        idleLeft: idleLeft,
        idleDown: idleDown,
        idleUp: idleUp,
        runLeft: runLeft,
        runDown: runDown,
        runUp: runUp,
        idleRight: idleRight,
        runRight: runRight,
      );
}
