import 'package:bonfire/bonfire.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/material.dart';
import 'package:koleso_fortune/remote_player.dart';

import 'my_player.dart';

///
/// Created by
///
/// ─▄▀─▄▀
/// ──▀──▀
/// █▀▀▀▀▀█▄
/// █░░░░░█─█
/// ▀▄▄▄▄▄▀▀
///
/// Rafaelbarbosatec
/// on 19/10/21
class SimpleExampleGame extends StatelessWidget {
  const SimpleExampleGame({Key? key}) : super(key: key);



  Future<List<RemotePlayer>> getEver() async {

    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;

    List <RemotePlayer> players = [];

      final name = await ref.child('Games/gay228/players/1/name').get();
      final x = await ref.child('Games/gay228/players/1/x').get();
      final y = await ref.child('Games/gay228/players/1/y').get();
      players = [RemotePlayer(Vector2(double.parse(x.value.toString()), double.parse(y.value.toString())), name.value.toString(), 1)];

    return players;

  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([
        getEver(),
    ]),
    builder:
    (BuildContext context, snapshot) {
      if (snapshot.hasData) {

        return BonfireWidget(
          map: WorldMapByTiled(
            'tiled/tanki2023.json',
            forceTileSize: Vector2(32, 32),

          ),
          showCollisionArea: false,

          joystick: Joystick(
            keyboardConfig: KeyboardConfig(),
            directional: JoystickDirectional(),
            actions: [
              JoystickAction(
                actionId: 1,
                margin: const EdgeInsets.all(60),
              ),
            ],
          ),
          cameraConfig: CameraConfig(moveOnlyMapArea: true, zoom: 0.83),

          player: MyPlayer(Vector2(850, 200), 'Vova', 2),

          //enemies: snapshot.data![0],
          lightingColorGame: Colors.transparent,
          backgroundColor: const Color.fromARGB(255,132,101,77),
        );
      }else {
        return const Center(child: CircularProgressIndicator());
      }
    }
    );
  }

// 120:400    20:140   500,800      850,600   850,200

}


