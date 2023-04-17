import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'package:bonfire/bonfire.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:typed_data/typed_buffers.dart';

extension DoubleExtensions on double {
  List<int> toBytes() {
    final byteData = ByteData(8);
    byteData.setFloat64(0, this);
    return byteData.buffer.asUint8List();
  }
}


  Future<int> GetKills(String id) async {
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    var uid = user!.uid;
    final curGame = (await ref.child('Users/$uid/CurGame').get()).value.toString();
    final kills = (await ref.child('Games/$curGame/Players/$id/kills').get()).value.toString();

    return int.parse(kills);
  }
Future<int> GetDeaths(String id) async {
  final ref = FirebaseDatabase.instance.ref();
  final User? user = FirebaseAuth.instance.currentUser;
  var uid = user!.uid;
  final curGame = (await ref.child('Users/$uid/CurGame').get()).value.toString();
  final kills = (await ref.child('Games/$curGame/Players/$id/deaths').get()).value.toString();

  return int.parse(kills);
}

class MyPlayer  extends RotationPlayer with ObjectCollision, UseBarLife {
  final int id;
  var io = 0;
  final String nick;
  late TextPaint textConfig;
  Vector2 sizeTextNick = Vector2.zero();
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  final String gameId;



  MyPlayer(Vector2 position, this.nick, this.id, this.gameId)
      : super(
    animIdle: _getSoldierSprite(),
    animRun: _getSoldierSprite(),
    size: Vector2.all(160),
    position: position,
    life: 200,
  ) {


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
          CollisionArea.rectangle(size: Vector2(50, 20),
            align: Vector2(50, 70)),
        ],
      ),
    );
    setupBarLife(

      size: Vector2(70, 10),
      borderRadius: BorderRadius.circular(2),
      borderWidth: 2,
    );
  }
  @override
  void render(Canvas canvas) {
    renderNickName(canvas);
    super.render(canvas);
  }

  static Future<SpriteAnimation> _getSoldierSprite() {
    return Sprite.load('player/tankRight.png').toAnimation();
  }

  void joystickChangeDirectional(JoystickDirectionalEvent event) {

    speed = 100 * event.intensity;
    super.joystickChangeDirectional(event);
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

  @override
  void joystickAction(JoystickActionEvent event) {
    if ((event.id == 1 || event.id == LogicalKeyboardKey.space.keyId) &&
        event.event == ActionEvent.DOWN) {
      actionAttack();
    }
    super.joystickAction(event);

  }
  var fire = 0;

  void actionAttack() {

    Vector2 centerOffset = Vector2.zero();
    switch (lastDirection) {
      case Direction.left:
        centerOffset = Vector2(0, 0);
        break;
      case Direction.right:
        centerOffset = Vector2(0, 0);
        break;
      case Direction.up:
        centerOffset = Vector2(0, 0);
        break;
      case Direction.down:
        centerOffset = Vector2(0, 0);
        break;
      case Direction.upLeft:
        centerOffset = Vector2(0, 0);
        break;
      case Direction.upRight:
        centerOffset = Vector2(0, 0);
        break;
      case Direction.downLeft:
        centerOffset = Vector2(0, 0);
        break;
      case Direction.downRight:
        centerOffset = Vector2(0, 0);
        break;
    }
    simpleAttackRangeByAngle(

      angle: angle,
      size: Vector2(12, 8),
      centerOffset: centerOffset,
      marginFromOrigin: 27,
      speed: 210,
      animation: Sprite.load('bullet.png').toAnimation(),
      damage: 30,
      id: id,
      attackFrom: AttackFromEnum.PLAYER_OR_ALLY,
    );
    ref.child("Games/$gameId/Players/$id/isFire").set(fire);

    fire++;
  }



  @override
  void receiveDamage(AttackFromEnum attacker, double damage, dynamic identify) {
    if(life <= 30){
      GetKills(identify.toString()).then((value) {

        ref.child("Games/$gameId/Players/$identify/kills").set(value + 1);
      });
      // GetDeaths(id.toString()).then((value) {
      //   ref.child("Games/$gameId/Players/$id/deaths").set(value + 1);
      // });

      ref.child("Games/$gameId/Players/$id/life").set(life.toDouble());
    }
    showDamage(
      damage,
      config: const TextStyle(
        color: Colors.red,
        fontSize: 14,
      ),
    );

    super.receiveDamage(attacker, damage, identify);

  }

  @override
  void die() {
    ref.child("Games/$gameId/Players/$id/life").set(life.toDouble());
    ref.child("Games/$gameId/Players/$id/isDead").set(true);
    removeFromParent();

    super.die();
  }
  var angleCheck = 0.0;
  var speedCheck = 0.0;
  var healthCheck = 200.0;
  DateTime now = DateTime.now();
  var time = DateTime.now().millisecondsSinceEpoch;
  @override
  void update(double dt) {
    if (isDead) return;
    now = DateTime.now();
    int timestamp = now.millisecondsSinceEpoch;

    if((timestamp - time) >= 1500){
      time = timestamp;
      final List<double> numbers = [position.x, position.y];
      final bytes = numbers.fold<List<int>>([], (previousValue, element) => previousValue..addAll(element.toBytes()));
      final encodedData = base64.encode(bytes);
      ref.child("Games/$gameId/Players/$id/data").set(encodedData);
    }

    if(io == 0){


      speed = 0;
      angle = 0;
      speedCheck = speed;
      angleCheck = angle;
      final List<double> numbers = [speed, angle];
      final bytes = numbers.fold<List<int>>([], (previousValue, element) => previousValue..addAll(element.toBytes()));
      final encodedData = base64.encode(bytes);
      ref.child("Games/$gameId/Players/$id/dataMain").set(encodedData);
      io++;
    }

    if(angle != angleCheck || speed != speedCheck){
      final List<double> numbers = [speed, angle];
      final bytes = numbers.fold<List<int>>([], (previousValue, element) => previousValue..addAll(element.toBytes()));
      final encodedData = base64.encode(bytes);
      ref.child("Games/$gameId/Players/$id/dataMain").set(encodedData);
      ref.child("Games/$gameId/Players/$id/life").set(life.toDouble());
      healthCheck = life;
      speedCheck = speed;
      angleCheck = angle;
    }

    if(life != healthCheck){
      ref.child("Games/$gameId/Players/$id/life").set(life.toDouble());
      healthCheck = life;
    }


    super.update(dt);
  }


}

