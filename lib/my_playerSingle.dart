import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:async';
import 'package:bonfire/bonfire.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:koleso_fortune/sounds.dart';
import 'package:koleso_fortune/player_sprite_sheet.dart';

import 'game_sprite_sheet.dart';

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

Future<int> GetSkin() async {
  final ref = FirebaseDatabase.instance.ref();
  final User? user = FirebaseAuth.instance.currentUser;
  var uid = user!.uid;
  final skin = (await ref.child('Users/$uid/SelectedSkin').get()).value.toString();
  if(skin == "null"){
    return 0;
  }else{
    return int.parse(skin)+1;
  }
}


Future<int> GetDeaths(String id) async {
  final ref = FirebaseDatabase.instance.ref();
  final User? user = FirebaseAuth.instance.currentUser;
  var uid = user!.uid;
  final curGame = (await ref.child('Users/$uid/CurGame').get()).value.toString();
  final kills = (await ref.child('Games/$curGame/Players/$id/deaths').get()).value.toString();

  return int.parse(kills);
}

class MyPlayerSingle  extends RotationPlayer with ObjectCollision, UseBarLife {
  final int id;
  var io = 0;
  final String nick;
  late TextPaint textConfig;
  Vector2 sizeTextNick = Vector2.zero();
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  final String gameId;



  MyPlayerSingle(Vector2 position, this.nick, this.id, this.gameId)
      : super(
    animIdle: _getSoldierSprite(),
    animRun: _getSoldierSprite(),
    size: Vector2(75, 41.25),
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

  static Future<SpriteAnimation> _getSoldierSprite() async {
    var skin = await GetSkin();
    return Sprite.load('player/${skin}tank.png').toAnimation();
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
        position.x + ((width - sizeTextNick.x) /  2),
        position.y - sizeTextNick.y - 25,
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
  var canShoot = true;
  void actionAttack() {
    if (immortal == false && dead == false && canShoot == true) {
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
        animationDestroy: GameSpriteSheet.fireBallExplosion(),
        onDestroy: () {
          Sounds.explosion();
        },
        animation: Sprite.load('bullet.png').toAnimation(),
        damage: 30,
        id: id,
        attackFrom: AttackFromEnum.PLAYER_OR_ALLY,
      );

      canShoot = false;
      Future.delayed(const Duration(milliseconds: 500), () {
        canShoot = true;
      });

    }

      fire++;

  }


  bool hasReceivedDamage = true;
  @override
  void receiveDamage(AttackFromEnum attacker, double damage, dynamic identify) {
    if(life <= 20 && hasReceivedDamage == true){
        hasReceivedDamage = false;
    }
    if(life >= 30 && hasReceivedDamage == false){
      hasReceivedDamage = true;

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
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    var uid = user!.uid;
    ref.child("Users/$uid/$gameId/isDead").set(true);
    //removeFromParent();
    hasReceivedDamage = true;
    super.die();
  }



  var immortal = false;
  var dead = false;

  @override
  void update(double dt) {



    if(immortal == true){
      addLife(200.0);
    }

    if(life <= 0){
      speed = 0;
      opacity = 0.4;
      if(life == -10){
        addLife(10.0);
      }
      dead = true;
    }else{
      dead = false;
      opacity = 1;
    }



    if(io == 0){
      final User? user = FirebaseAuth.instance.currentUser;
      var uid = user!.uid;
      DatabaseReference reff =
      FirebaseDatabase.instance.ref('Users/$uid/$gameId/isImmortal');
      reff.onValue.listen((DatabaseEvent event) async {
        final data = event.snapshot.value as bool;
        immortal=data;
      });
      speed = 0;
      angle = 0;

      io++;
    }
    super.update(dt);
  }


}

