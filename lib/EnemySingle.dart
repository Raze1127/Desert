import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/line_path_component.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:koleso_fortune/sounds.dart';

import 'game_sprite_sheet.dart';

class SingleEnemy extends RotationEnemy
    with ObjectCollision, UseBarLife, MoveToPositionAlongThePath {
  final int id;
  var io = 0;
  final String nick;
  late TextPaint textConfig;
  Vector2 sizeTextNick = Vector2.zero();
  final String gameId;
  final String skinMain;

  SingleEnemy(Vector2 position, this.nick, this.id, this.gameId, this.skinMain)
      : super(
    animIdle: _getSoldierSprite(skinMain),
    animRun: _getSoldierSprite(skinMain),
    size: Vector2(75, 41.25),
    position: position,
    life: 200,
    speed: 80,
  ) {
    angle = 0;

    textConfig = TextPaint(
      style: const TextStyle(
        fontSize: 10,
        color: Colors.white,
      ),
    );
    sizeTextNick = textConfig.measureText(nick);

    /// here we configure collision of the player
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.circle(radius: 17, align: Vector2(-2, 4)),
          CollisionArea.circle(radius: 17, align: Vector2(30, 4)),
        ],
      ),
    );
    setupBarLife(
      size: Vector2(70, 10),
      borderRadius: BorderRadius.circular(2),
      borderWidth: 2,
    );
    setupMoveToPositionAlongThePath(
      pathLineColor: Colors.lightBlueAccent.withOpacity(0),
      barriersCalculatedColor: Colors.blue.withOpacity(0),
      pathLineStrokeWidth: 0,
    );
  }

  @override
  void render(Canvas canvas) {
    renderNickName(canvas);

    super.render(canvas);
  }

  static Future<SpriteAnimation> _getSoldierSprite(String skin) {
    var skinMain = skin;
    return Sprite.load('player/${skinMain}tank.png').toAnimation();
  }

  @override
  bool checkCanReceiveDamage(AttackFromEnum attacker) {
    return super.checkCanReceiveDamage(attacker);
  }

  void renderNickName(Canvas canvas) {
    textConfig.render(
      canvas,
      nick,
      Vector2(
        position.x + ((width - sizeTextNick.x) / 2),
        position.y - sizeTextNick.y + 30,
      ),
    );
  }

  void actionAttack() {
    Vector2 centerOffset = Vector2.zero();
    switch (lastDirection) {
      case Direction.left:
        centerOffset = Vector2(0, -0);
        break;
      case Direction.right:
        centerOffset = Vector2(0, 0);
        break;
      case Direction.up:
        centerOffset = Vector2(0, 0);
        break;
      case Direction.down:
        centerOffset = Vector2(-0, 0);
        break;
      case Direction.upLeft:
        centerOffset = Vector2(0, 0);
        break;
      case Direction.upRight:
        centerOffset = Vector2(0, 0);
        break;
      case Direction.downLeft:
        centerOffset = Vector2(-0, 0);
        break;
      case Direction.downRight:
        centerOffset = Vector2(-0, 0);
        break;
    }
    simpleAttackRangeByAngle(
      id: id,
      attackFrom: AttackFromEnum.ENEMY,
      angle: angle,
      size: Vector2(12, 8),
      centerOffset: centerOffset,
      marginFromOrigin: 8,
      speed: 210,
      animationDestroy: GameSpriteSheet.fireBallExplosion(),
      onDestroy: () {
        var box = Hive.box('Settings');
        var sound = box.get('sound');
        if (sound == true) {
          Sounds.explosion();
        }
      },
      animation: Sprite.load('bullet.png').toAnimation(),
      damage: 30,
    );
  }

  @override
  void receiveDamage(AttackFromEnum attacker, double damage, dynamic identify) {
    //('$attacker, $damage, $identify');
    super.receiveDamage(attacker, damage, identify);
  }

  var checkLife = 200.0;
  var collidable = true;

  @override
  bool onCollision(GameComponent component, bool active) {
    if (collidable) {
      return super.onCollision(component, active);
    } else {
      return false;
    }
  }

  @override
  Future<void> onLoad() {
    return super.onLoad();
  }

  Future delPath() async {

  }

  var posCheckX;
  var posCheckY;
  bool moveScheduled = false;
  var going = false;
  var l = 1;

  Future<void> moveEnemy() async {
    while (i == 1) {
      var playerX = gameRef.player?.position.x;
      var playerY = gameRef.player?.position.y;
      if (posCheckX == null) posCheckX = playerX;
      if (posCheckY == null) posCheckY = playerY;

      double tankX = position.x;
      double tankY = position.y;

      double distanceToPlayer =
      sqrt(pow(playerX! - tankX, 2) + pow(playerY! - tankY, 2));

      if (distanceToPlayer >= visibilityRadius) {
        if (playerX != null && playerY != null && !going) {
          if (((playerX - posCheckX).abs() > 0 ||
              (playerY - posCheckY).abs() > 0)) {
            //('playerpos $playerX');
            posCheckX = playerX;
            posCheckY = playerY;
            stopMoveAlongThePath();
            //get player collision
            var playerCollision =
            await gameRef
                .collisions()
                .first
                .collisionConfig
                ?.collisions;

            //(playerCollision);
            var path = await moveToPositionAlongThePath(
                Vector2(playerX.roundToDouble(), playerY.roundToDouble()),
                ignoreCollisions: [playerCollision], onFinish: () {
              going = false;
            });
            if (path.isNotEmpty) {
              going = true;
            }
          }
        }
      }else{
        stopMoveAlongThePath();
        speed = 80;
        seeAndMoveToPlayer(
          closePlayer: (player) {

          },

          radiusVision: 250,

        );
      }
      i = 2;
      Future.delayed(Duration(milliseconds: 20), () {
        i = 0;
      });
    }
  }

  var i = 0;

  double getDirectionAngle(Vector2 direction) {
    return atan2(direction.y, direction.x);
  }

  Vector2? getRandomSpawnPoint() {
    List<Vector2> availableSpawnPoints = []; // Доступные точки респавна
    List<Vector2> mapSpawnPoints = [
      Vector2(120, 400),
      Vector2(60, 160),
      Vector2(500, 800)
    ];
    List<String> coordinates = [
      '120/400',
      '60/160',
      '500/800',
      '850/600',
      '850/200'
    ];
    // Проверяем каждую точку на карте
    for (final spawnPoint in mapSpawnPoints) {
      Rect spawnRect = Rect.fromLTWH(spawnPoint.x, spawnPoint.y, 10, 70);
      // Проверяем, есть ли коллизия с объектами в этой точке
      bool hasCollision = gameRef.collisions().any((object) {
        return object.isObjectCollision() &&
            (object).rectCollision.overlaps(spawnRect);
      });

      if (!hasCollision) {
        availableSpawnPoints
            .add(spawnPoint); // Добавляем доступную точку респавна
      }
    }

    if (availableSpawnPoints.isNotEmpty) {
      Random random = Random();
      int randomIndex = random.nextInt(availableSpawnPoints.length);
      return availableSpawnPoints[randomIndex];
    }

    return null; // Если нет доступных точек респавна без коллизий
  }

  void respawn() {
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    var uid = user!.uid;
    ref.child("Users/$uid/Single/kills").get().then((DataSnapshot data) {
      ref
          .child("Users/$uid/Single/kills")
          .set(int.parse(data.value.toString()) + 1);
    });

    Vector2? spawnPoint = getRandomSpawnPoint();
    if (spawnPoint != null) {
      updateLife(200);
      position.setFrom(spawnPoint);
    }
  }

  Vector2? lastPosition;
  double targetAngle = 0;
  double rotationSpeed = 0.09;
  double visibilityRadius = 250; // Радиус видимости танка
  var canFire = true;

  @override
  void update(double dt) {
    if (life < 20) {
      updateLife(200);
      addLife(210);
      respawn();
      return;
    }
    if (i == 0) {
      i = 1;
      moveEnemy();
    }
    double playerX = gameRef.player!.position.x;
    double playerY = gameRef.player!.position.y;
    double tankX = position.x;
    double tankY = position.y;

    double distanceToPlayer =
    sqrt(pow(playerX - tankX, 2) + pow(playerY - tankY, 2));

    if (distanceToPlayer <= visibilityRadius) {
      // Игрок в радиусе видимости
      targetAngle = getDirectionAngle(gameRef.player!.position - position);
      double dispersionRange = 0.11; // Разброс в радианах
      double dispersion =
          Random().nextDouble() * dispersionRange - dispersionRange / 2;
      targetAngle += dispersion;
      if (canFire) {
        canFire = false;
        Future.delayed(Duration(milliseconds: 800), () {
          canFire = true;
        });
        actionAttack();
      }
    } else {
      // Игрок не в радиусе видимости
      if (lastPosition != null) {
        Vector2 direction = position - lastPosition!;
        targetAngle = getDirectionAngle(direction);
      }
    }
    lastPosition = position.clone();

    // Плавное изменение угла
    double diff = ((targetAngle - angle + pi) % (2 * pi) - pi);
    if (diff < -pi) diff += 2 * pi;
    angle += diff * rotationSpeed;
    delPath();

    super.update(dt);
  }

  @override
  void die() {


  }
}
