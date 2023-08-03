import 'package:bonfire/bonfire.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:koleso_fortune/Home.dart';


import 'EnemySingle.dart';
import 'my_playerSingle.dart';

class SinglePlayer extends StatefulWidget {
  const SinglePlayer({Key? key}) : super(key: key);

  @override
  _SinglePlayer createState() => _SinglePlayer();
}

class _SinglePlayer extends State<SinglePlayer> {
  var killsMain = 0;
  var deathsMain = 0;
  var iou = 1;
  var resp = '';
  final GameController _controller = GameController();
  var secondsLeft = 0;

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

    DatabaseReference reff =
        FirebaseDatabase.instance.ref('Users/$uid/$idGame/isDead');

    reff.onValue.listen((DatabaseEvent event) async {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as bool;
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
          Future.delayed(const Duration(milliseconds: 5000), () async {
            setState(() {
              secondsLeft = 1;
            });

            DatabaseReference ref = FirebaseDatabase.instance.ref();
            ref.child('Users/$uid/$idGame/isDead').set(false);
            ref.child('Users/$uid/$idGame/deaths').set(deathsMain + 1);

            var deathssss =
                (await ref.child('Users/$uid/deaths').get()).value.toString();

            ref.child('Users/$uid/deaths').set(int.parse(deathssss) + 1);

            _controller.player!.addLife(200.0);
          });
          Future.delayed(const Duration(milliseconds: 5050), () {
            setState(() {
              secondsLeft = 3;
              resp = 'You are immortal for';
              _controller.player!.addLife(200);
              ref.child('Users/$uid/$idGame/isImmortal').set(true);
              Future.delayed(const Duration(milliseconds: 1000), () {
                setState(() {
                  secondsLeft = 2;
                });
              });
              Future.delayed(const Duration(milliseconds: 2000), () {
                setState(() {
                  secondsLeft = 1;
                });
              });
              Future.delayed(const Duration(milliseconds: 3000), () {
                setState(() {
                  _controller.player!.addLife(200.0);
                  secondsLeft = 0;
                  ref.child('Users/$uid/$idGame/isImmortal').set(false);

                  resp = '';
                });
              });
            });
          });
        }
      }
    });
  }

  void getKD() async {
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    var uid = user!.uid;
    final idGame =
        (await ref.child('Users/$uid/CurGame').get()).value.toString();
    DatabaseReference killsRef =
        FirebaseDatabase.instance.ref('Users/$uid/$idGame/kills');
    DatabaseReference deathsRef =
        FirebaseDatabase.instance.ref('Users/$uid/$idGame/deaths');
    killsRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as int;
      if (killsMain != data) {
        setState(() {
          killsMain = data;
        });
      }
    });
    deathsRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as int;
      if (deathsMain != data) {
        setState(() {
          deathsMain = data;
        });
      }
    });
  }

  var box = Hive.box('Settings');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([]),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            return BonfireWidget(
              gameController: _controller,
              map: WorldMapByTiled(
                'tiled/tanki2023.json',
                forceTileSize: Vector2(32, 32),
              ),
              showCollisionArea: false,
              joystick: Joystick(
                keyboardConfig: KeyboardConfig(),
                directional: JoystickDirectional(
                  isFixed: !box.get('joystick', defaultValue: true),
                  size: 100,
                ),
                actions: [
                  JoystickAction(
                    size: 75,
                    actionId: 1,
                    margin: const EdgeInsets.all(60),
                  ),
                ],
              ),
              cameraConfig: CameraConfig(moveOnlyMapArea: true, zoom: 0.75),
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
                              child: Column(
                                children: [
                                  Text(
                                    (resp),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                        secondsLeft > 0 ? "$secondsLeft" : ""),
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
                      Container(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 25, right: 10),
                          child: Material(
                            color: Colors.transparent,
                            child: IconButton(
                                color: Colors.white,
                                icon: const Icon(Icons.logout),
                                onPressed: () {
                                  final ref = FirebaseDatabase.instance.ref();
                                  final User? user =
                                      FirebaseAuth.instance.currentUser;
                                  final uid = user?.uid;

                                  ref.child('Users/$uid').update({
                                    'CurGame': null,
                                  });
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const Home()));
                                }),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
              initialActiveOverlays: const ['KD'],
              player: MyPlayerSingle(Vector2(120, 400), "You", 1, "Single"),
              enemies: [
                SingleEnemy(Vector2(500, 800), "Enemy", 1, "Single", '1'),
              ],
              lightingColorGame: Colors.transparent,
              backgroundColor: const Color.fromARGB(255, 132, 101, 77),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
