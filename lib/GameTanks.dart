import 'dart:ffi';

import 'package:bonfire/bonfire.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    var i = 1;
    var uid = user!.uid;

    final id = (await ref.child('Users/$uid/CurGame').get()).value.toString();
    final myname = (await ref.child('Users/$uid/Name').get()).value.toString();

      while(i > -1) {
        final name = await ref.child('Games/$id/Players/$i/name').get();
        final x = await ref.child('Games/$id/Players/$i/x').get();
        final y = await ref.child('Games/$id/Players/$i/y').get();
        if(name.value ==  myname ){
          i++;
        }else{
          if(name.exists){
            players.add(RemotePlayer(Vector2(double.parse(x.value.toString()), double.parse(y.value.toString())), name.value.toString(), i, id));
            i++;
          }else{
            i = -2;
          }
        }

      }



      print(players);
      print("AAAAAAAAAAAAAAAAAAAAAAAAAAAA");
    if(players == null){
      return [];
    }else {
      return players;
    }


  }

  Future<List<double>> getCords() async{
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    var uid = user!.uid;
    final idGame = (await ref.child('Users/$uid/CurGame').get()).value.toString();
    final id = (await ref.child('Users/$uid/player').get()).value.toString();
    var x = (await ref.child('Games/$idGame/Players/$id/x').get()).value.toString();
    var y = (await ref.child('Games/$idGame/Players/$id/y').get()).value.toString();

    return [double.parse(x),double.parse(y)];
  }

  Future<int> getID() async{
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    var uid = user!.uid;
    var id = (await ref.child('Users/$uid/player').get()).value.toString();

    return int.parse(id);
  }

  Future<String> getGame() async{
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    var uid = user!.uid;
    final idGame = (await ref.child('Users/$uid/CurGame').get()).value.toString();
    return idGame;
  }

  Future<String> getName() async{
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    var uid = user!.uid;
    var name = (await ref.child('Users/$uid/Name').get()).value.toString();

    return name;
  }




  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([
          getEver(),
          getCords(),
          getID(),
          getName(),
          getGame(),
    ]),
    builder:
    (BuildContext context, snapshot) {
      print(snapshot.data);
      if (snapshot.hasData) {
        List<double>? Cords = snapshot.data![1] as List<double>?;

        var id = snapshot.data![2] as int;
        return  BonfireWidget(
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
              overlayBuilderMap: {
                'buttons': (BuildContext context, snapshot) {
                  return  Padding(
                    padding: const EdgeInsets.only(top: 20, left: 20),
                    child: Text(
                      'Kills:\nDeaths:',
                      style: GoogleFonts
                          .pressStart2p(
                          textStyle: const TextStyle(
                            shadows: [
                              Shadow(
                                // bottomLeft
                                  offset: Offset(
                                      -1.5,
                                      -1.5),
                                  color: Colors
                                      .black),
                              Shadow(
                                // bottomRight
                                  offset: Offset(
                                      1.5,
                                      -1.5),
                                  color: Colors
                                      .black),
                              Shadow(
                                // topRight
                                  offset: Offset(
                                      1.5, 1.5),
                                  color: Colors
                                      .black),
                              Shadow(
                                // topLeft
                                  offset: Offset(
                                      -1.5,
                                      1.5),
                                  color: Colors
                                      .black),
                            ],
                            color: Colors.white,

                            fontSize: 15,

                          )),
                    ),
                  );
                }
              },
          initialActiveOverlays: ['buttons'],

            player: MyPlayer(Vector2(Cords![0], Cords[1]), (snapshot.data![3] as String), id, snapshot.data![4] as String),

            enemies: snapshot.data![0] as List<RemotePlayer>,
            lightingColorGame: Colors.transparent,
            backgroundColor: const Color.fromARGB(255,132,101,77),
          );

      }else {
        return const Center(child: CircularProgressIndicator());
      }
    }
    );
  }


}


