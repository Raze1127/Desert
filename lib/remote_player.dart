import 'dart:convert';
import 'dart:typed_data';

import 'package:bonfire/bonfire.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';




class RemotePlayer extends RotationEnemy with ObjectCollision, UseBarLife {
  final int id;
  var io = 0;
  final String nick;
  late TextPaint textConfig;
  Vector2 sizeTextNick = Vector2.zero();
  final String gameId;

  RemotePlayer(Vector2 position, this.nick, this.id, this.gameId )
      : super(
    animIdle: _getSoldierSprite(),
    animRun: _getSoldierSprite(),
    size: Vector2.all(160),
    position: position,
    life: 200,

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
          CollisionArea.rectangle(size: Vector2(65, 35),
              align: Vector2(43, 65)),
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
      attackFrom: AttackFromEnum.ENEMY,
      angle: angle,
      size: Vector2(12, 8),
      centerOffset: centerOffset,
      marginFromOrigin: 8,
      speed: 210,
      animation: Sprite.load('bullet.png').toAnimation(),
      damage: 30,
    );
  }
  @override
  void receiveDamage(AttackFromEnum attacker, double damage, dynamic identify) {

    showDamage(
      damage,
      config: const TextStyle(
        color: Colors.red,
        fontSize: 14,
      ),
    );

    print('$attacker, $damage, $identify');
    super.receiveDamage(attacker, damage, identify);

  }
  var angle1 = 0.0;
  var speed1 = 0.0;

  void movement() {

    DatabaseReference XYRef =
    FirebaseDatabase.instance.ref('Games/$gameId/Players/$id/data');

    DatabaseReference SPEEDandleRef =
    FirebaseDatabase.instance.ref('Games/$gameId/Players/$id/dataMain');

    XYRef.onValue.listen((DatabaseEvent event) async {
      final encodedData = event.snapshot.value as String;
      final decodedBytes = base64.decode(encodedData);
      final numbers = <double>[];
      for (var i = 0; i < decodedBytes.length; i += 8) {
        numbers.add(ByteData.view(decodedBytes.buffer).getFloat64(i, Endian.big));
      }
      print(numbers[0]);
      position.x = numbers[0];
      position.y = numbers[1];
    });

    SPEEDandleRef.onValue.listen((DatabaseEvent event) async {
      final encodedData = event.snapshot.value as String;
      final decodedBytes = base64.decode(encodedData);
      final numbers = <double>[];
      for (var i = 0; i < decodedBytes.length; i += 8) {
        numbers.add(ByteData.view(decodedBytes.buffer).getFloat64(i, Endian.big));
      }
      print(numbers[1]);
      angle1 = numbers[1];
      speed1 = numbers[0];
      angle = angle1;
    });



  }

  void fire() {


    DatabaseReference angleRef =
    FirebaseDatabase.instance.ref('Games/$gameId/Players/$id/isFire');
    angleRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as int;


          actionAttack();

    });


  }
  void health() {


    DatabaseReference angleRef =
    FirebaseDatabase.instance.ref('Games/$gameId/Players/$id/life');
    angleRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as num?;
      print('LOOOL');


      if(life != data!.toDouble()){
        if(data.toDouble() < life){

          receiveDamage(AttackFromEnum.ENEMY, life - data.toDouble(), 1);
          updateLife(data.toDouble());
        }
        else{


          addLife(data.toDouble()-life);
        }
      }

    });


  }
  @override
  bool checkCanReceiveDamage(AttackFromEnum attacker, double damage, from) {
    return false;
  }

  @override
  void update(double dt) {

    if(io == 0){
      io++;
      health();
      movement();
      fire();
    }
    else{
      moveFromAngle(speed1, angle1);
    }

    //
    super.update(dt);
  }

  @override
  void die() {
    removeFromParent();
    super.die();
  }
}