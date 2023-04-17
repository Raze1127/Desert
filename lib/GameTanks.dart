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
class SimpleExampleGame extends StatefulWidget {
  const SimpleExampleGame({Key? key}) : super(key: key);

  @override
  _SimpleExampleGameState createState() => _SimpleExampleGameState();
}

class _SimpleExampleGameState extends State<SimpleExampleGame> {
  var killsMain = 0;
  var deathsMain = 0;
  var iou = 1;
  var resp = '';
  final GameController _controller = GameController();
  var secondsLeft = 0;

  Future<List<RemotePlayer>> getEver() async {
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;

    List<RemotePlayer> players = [];
    var i = 1;
    var uid = user!.uid;

    final id = (await ref.child('Users/$uid/CurGame').get()).value.toString();
    final myname = (await ref.child('Users/$uid/Name').get()).value.toString();

    while (i > -1) {
      final name = await ref.child('Games/$id/Players/$i/name').get();
      final x = await ref.child('Games/$id/Players/$i/x').get();
      final y = await ref.child('Games/$id/Players/$i/y').get();

      if (name.value == myname) {
        i++;
      } else {
        if (name.exists) {
          players.add(RemotePlayer(Vector2(double.parse(x.value.toString()), double.parse(y.value.toString())), name.value.toString(), i, id));
          //subscribeRemotePlayers(id, i, double.parse(x.value.toString()), double.parse(y.value.toString()), name.value.toString() );
          i++;
        } else {
          i = -2;
        }
      }
    }
    if (players == null) {
      return [];
    } else {
      return players;
    }
  }

  Future<List<double>> getCords() async {
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    var uid = user!.uid;
    final idGame =
        (await ref.child('Users/$uid/CurGame').get()).value.toString();
    final id = (await ref.child('Users/$uid/player').get()).value.toString();
    var x =
        (await ref.child('Games/$idGame/Players/$id/x').get()).value.toString();
    var y =
        (await ref.child('Games/$idGame/Players/$id/y').get()).value.toString();

    return [double.parse(x), double.parse(y)];
  }

  Future<int> getID() async {
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    var uid = user!.uid;
    var id = (await ref.child('Users/$uid/player').get()).value.toString();

    return int.parse(id);
  }

  Future<String> getGame() async {
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    var uid = user!.uid;
    final idGame =
        (await ref.child('Users/$uid/CurGame').get()).value.toString();
    return idGame;
  }

  Future<String> getName() async {
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    var uid = user!.uid;
    var name = (await ref.child('Users/$uid/Name').get()).value.toString();

    return name;
  }



  @override
  void initState() {
    super.initState();
    _subscribeToIsDeadChanges();
    getKD();
  }

  Future<void> _subscribeToIsDeadChanges() async {
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    var uid = user!.uid;
    final idGame =
        (await ref.child('Users/$uid/CurGame').get()).value.toString();
    final player =
        (await ref.child('Users/$uid/player').get()).value.toString();
    final nick = (await ref.child('Users/$uid/player').get()).value.toString();
    final x = (await ref.child('Games/$idGame/Players/$player/x').get())
        .value
        .toString();
    final y = (await ref.child('Games/$idGame/Players/$player/y').get())
        .value
        .toString();

    DatabaseReference reff =
        FirebaseDatabase.instance.ref('Games/$idGame/Players/$player/isDead');

    reff.onValue.listen((DatabaseEvent event) async {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as bool;
        print(data);
        if (data == true) {

          Future.delayed(const Duration(milliseconds: 1000), () {
            setState(() {
              resp = 'Respawning in';
              secondsLeft = 5;
            });

          });

          Future.delayed(const Duration(milliseconds: 2000), () {
            setState(() {
              secondsLeft = 4;
            });
          });
          Future.delayed(const Duration(milliseconds: 3000), () {
            setState(() {
              secondsLeft = 3;
            });
          });
          Future.delayed(const Duration(milliseconds: 4000), () {
            setState(() {
              secondsLeft = 2;
            });
          });
          Future.delayed(const Duration(milliseconds: 5000), () {
            setState(() {
              secondsLeft = 1;
            });
            resp = '';

            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SimpleExampleGame()));
            DatabaseReference ref = FirebaseDatabase.instance.ref();
            ref.child('Games/$idGame/Players/$player/isDead').set(false);
            ref.child('Games/$idGame/Players/$player/deaths').set(deathsMain+1);

          });

        }
      }
    });
  }

  void getKD() async {
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    var uid = user!.uid;
    var id = (await ref.child('Users/$uid/player').get()).value.toString();
    final idGame =
        (await ref.child('Users/$uid/CurGame').get()).value.toString();
    DatabaseReference killsRef =
        FirebaseDatabase.instance.ref('Games/$idGame/Players/$id/kills');
    DatabaseReference deathsRef =
        FirebaseDatabase.instance.ref('Games/$idGame/Players/$id/deaths');
    killsRef.onValue.listen((DatabaseEvent event) async {
      final data = event.snapshot.value as int;
      setState(() {
        killsMain = data;
      });
    });
    deathsRef.onValue.listen((DatabaseEvent event) async {
      final data = event.snapshot.value as int;
      setState(() {
        deathsMain = data;
      });
    });
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
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            List<double>? Cords = snapshot.data![1] as List<double>?;
            var id = snapshot.data![2] as int;

            return BonfireWidget(
              gameController: _controller,
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
                'KD': (BuildContext context, snapshot) {
                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 80),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DefaultTextStyle(
                              style: GoogleFonts.pressStart2p(
                                textStyle: const TextStyle(
                                  shadows: [
                                    Shadow(
                                      offset: Offset(-1.5, -1.5),
                                      color: Colors.black,
                                    ),
                                    Shadow(
                                      offset: Offset(1.5, -1.5),
                                      color: Colors.black,
                                    ),
                                    Shadow(
                                      offset: Offset(1.5, 1.5),
                                      color: Colors.black,
                                    ),
                                    Shadow(
                                      offset: Offset(-1.5, 1.5),
                                      color: Colors.black,
                                    ),
                                  ],
                                  color: Colors.white,
                                  fontSize: 24,
                                ),
                              ),
                              child:
                                  Column(
                                    children: [
                                      Text((resp), style: const TextStyle(fontSize: 10),),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(secondsLeft > 0 ? "$secondsLeft" : ""),
                                      ),
                                    ],
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 35, left: 20),
                        child: Column(
                          children: [
                            DefaultTextStyle(
                              style: GoogleFonts.pressStart2p(
                                  textStyle: const TextStyle(
                                shadows: [
                                  Shadow(
                                      // bottomLeft
                                      offset: Offset(-1.5, -1.5),
                                      color: Colors.black),
                                  Shadow(
                                      // bottomRight
                                      offset: Offset(1.5, -1.5),
                                      color: Colors.black),
                                  Shadow(
                                      // topRight
                                      offset: Offset(1.5, 1.5),
                                      color: Colors.black),
                                  Shadow(
                                      // topLeft
                                      offset: Offset(-1.5, 1.5),
                                      color: Colors.black),
                                ],
                                color: Colors.white,
                                fontSize: 10,
                              )),
                              child: Text(
                                'Kills: $killsMain',
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: DefaultTextStyle(
                                style: GoogleFonts.pressStart2p(
                                    textStyle: const TextStyle(
                                  shadows: [
                                    Shadow(
                                        // bottomLeft
                                        offset: Offset(-1.5, -1.5),
                                        color: Colors.black),
                                    Shadow(
                                        // bottomRight
                                        offset: Offset(1.5, -1.5),
                                        color: Colors.black),
                                    Shadow(
                                        // topRight
                                        offset: Offset(1.5, 1.5),
                                        color: Colors.black),
                                    Shadow(
                                        // topLeft
                                        offset: Offset(-1.5, 1.5),
                                        color: Colors.black),
                                  ],
                                  color: Colors.white,
                                  fontSize: 10,
                                )),
                                child: Text(
                                  'Deaths: $deathsMain',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              },
              initialActiveOverlays: const ['KD'],
              player: MyPlayer(
                  Vector2(Cords![0], Cords[1]),
                  (snapshot.data![3] as String),
                  id,
                  snapshot.data![4] as String),
              enemies: snapshot.data![0] as List<RemotePlayer>,
              lightingColorGame: Colors.transparent,
              backgroundColor: const Color.fromARGB(255, 132, 101, 77),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
