import 'dart:convert';
import 'dart:typed_data';

import 'package:bonfire/bonfire.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:koleso_fortune/sounds.dart';

import 'game_sprite_sheet.dart';





class RemotePlayer extends RotationEnemy with ObjectCollision, UseBarLife {
  final int id;
  var io = 0;
  final String nick;
  late TextPaint textConfig;
  Vector2 sizeTextNick = Vector2.zero();
  final String gameId;
  final String skinMain;

  RemotePlayer(Vector2 position, this.nick, this.id, this.gameId, this.skinMain )
      : super(
    animIdle: _getSoldierSprite(skinMain),
    animRun: _getSoldierSprite(skinMain),
    size: Vector2(75, 41.25),
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
          CollisionArea.circle(radius: 17,
              align: Vector2(-2, 4)
          ),
          CollisionArea.circle(radius: 17,
              align: Vector2(30, 4)
          ),
        ],
      ),
    );
    setupBarLife(
      margin: 50,
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

  static Future<SpriteAnimation> _getSoldierSprite(String skin)  {
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
        position.x + ((width - sizeTextNick.x) /  2),
        position.y - sizeTextNick.y - 25,
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
    //('$id $angle');
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
        if(sound == true){
          Sounds.explosion();}
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


  void movement() {

    DatabaseReference XYRef =
    FirebaseDatabase.instance.ref('Games/$gameId/Players/$id/data');


    XYRef.onValue.listen((DatabaseEvent event) async {
      final encodedData = event.snapshot.value as String;
      final decodedBytes = base64.decode("$encodedData"+"AAAAAAAA=");
      final numbers = <double>[];
      for (var i = 0; i < decodedBytes.length; i += 8) {
        numbers.add(ByteData.view(decodedBytes.buffer).getFloat64(i, Endian.big));
      }
      position.x = numbers[0];
      position.y = numbers[1];
      angle = numbers[2];
      speed = numbers[3];
    });

   moveFromAngle(speed, angle);


  }

  void fire() {


    DatabaseReference angleRef =
    FirebaseDatabase.instance.ref('Games/$gameId/Players/$id/isFire');
    //('Games/$gameId/Players/$id/isFire');
    angleRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as int;


          actionAttack();

    });


  }
  var checkLife = 200.0;
  var collidable = true;
  void health() {
    if(life !=  checkLife){
      updateLife(checkLife);
    }

    DatabaseReference angleRef =
    FirebaseDatabase.instance.ref('Games/$gameId/Players/$id/life');
    angleRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as num?;



      if(life != data!.toDouble()){




        if(data.toDouble() < life){
          checkLife = life;
          receiveDamage(AttackFromEnum.ENEMY, life - data.toDouble(), 1);
          showDamage(
            life - data.toDouble(),
            config: const TextStyle(
              color: Colors.red,
              fontSize: 14,
            ),
          );
          updateLife(data.toDouble());
        }
        else{


          addLife(data.toDouble()-life);
        }

        if(life<=0){
          opacity = 0.4;
          collidable = false;
        }else{
          collidable = true;
          opacity = 1;
        }

      }

    });


  }
  @override
  bool onCollision(GameComponent component, bool active) {

    if (collidable) {
      return super.onCollision(component, active);
    }else{
      return false;
    }
  }


  @override
  void update(double dt) {
    if (isDead) {


    }else {

      if (io == 0) {
        DatabaseReference logout =
        FirebaseDatabase.instance.ref('Games/$gameId/Players/$id/logout');

        logout.onValue.listen((DatabaseEvent event) async {
          final data = event.snapshot.value as bool;
          //("LOGOUT $data");
          if(data == true){
            removeFromParent();
          }
        });

        io++;
        health();
        movement();
        fire();
      }
      else {
        moveFromAngle(speed, angle);
      }
    }
    //
    super.update(dt);
  }

  @override
  void die() {

    super.die();
  }
}