import 'package:bonfire/bonfire.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:koleso_fortune/Home.dart';
import 'package:koleso_fortune/remote_player.dart';


import 'my_player.dart';


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

    while (i > -1) {
      final uidl = await ref.child('Games/$id/Players/$i/uid').get();
      final name = await ref.child('Games/$id/Players/$i/name').get();
      final x = await ref.child('Games/$id/Players/$i/x').get();
      final y = await ref.child('Games/$id/Players/$i/y').get();
      final skin = await ref.child('Games/$id/Players/$i/Skin').get();
      if (uidl.value == uid) {
        i++;
      } else {
        if (name.exists) {
          players.add(RemotePlayer(
              Vector2(double.parse(x.value.toString()),
                  double.parse(y.value.toString())),
              name.value.toString(),
              i,
              id, skin.value.toString()));

          i++;
        } else {
          i = -2;
        }
      }
    }
    // ignore: unnecessary_null_comparison
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

    DatabaseReference reff =
        FirebaseDatabase.instance.ref('Games/$idGame/Players/$player/isDead');

    reff.onValue.listen((DatabaseEvent event) async {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as bool;
        //(data);
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
            ref.child('Games/$idGame/Players/$player/isDead').set(false);
            ref
                .child('Games/$idGame/Players/$player/deaths')
                .set(deathsMain + 1);

            var deathssss = (await ref.child('Users/$uid/deaths').get()).value.toString();

            ref.child('Users/$uid/deaths').set(int.parse(deathssss)+1);

            _controller.player!.addLife(200.0);
          });
          Future.delayed(const Duration(milliseconds: 5050), () {
            setState(() {
              secondsLeft = 3;
              resp = 'You are immortal for';
              _controller.player!.addLife(200);
              ref.child('Games/$idGame/Players/$player/isImmortal').set(true);
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
                  ref.child('Games/$idGame/Players/$player/isImmortal').set(false);

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
    var id = (await ref.child('Users/$uid/player').get()).value.toString();
    final idGame =
        (await ref.child('Users/$uid/CurGame').get()).value.toString();
    DatabaseReference killsRef =
        FirebaseDatabase.instance.ref('Games/$idGame/Players/$id/kills');
    DatabaseReference deathsRef =
        FirebaseDatabase.instance.ref('Games/$idGame/Players/$id/deaths');
    killsRef.onValue.listen((DatabaseEvent event)  {
      final data = event.snapshot.value as int;
      if(killsMain != data){
        setState(()  {

          killsMain = data;
        });
      }

    });
    deathsRef.onValue.listen((DatabaseEvent event)  {
      final data = event.snapshot.value as int;
      if(deathsMain != data){
        setState(()  {
          deathsMain = data;
        });
      }

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
            var gamecode = snapshot.data![4] as String;
            var box =  Hive.boxExists('Settings');
            // ignore: unused_local_variable, prefer_typing_uninitialized_variables
            var sound;
            bool joystick;

            if(box == true){
              sound = Hive.box('Settings').get('sound', defaultValue: true);
              joystick = !Hive.box('Settings').get('joystick', defaultValue: true);
            }else{
              sound = true;
              joystick = true;
            }

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
                  isFixed: joystick,
                  size: 100,
                ),
                actions: [
                  JoystickAction(
                    size: 75,
                    actionId: 1,
                    margin: const EdgeInsets.all(60),
                  ),
                  JoystickAction(
                    size: 50,
                    actionId: 2,
                    margin: const EdgeInsets.only(bottom: 150, right: 80)
                  ),
                  JoystickAction(
                    size: 50,
                    actionId: 3,
                    margin: const EdgeInsets.all(140),
                  ),
                  JoystickAction(
                    size: 50,
                    actionId: 4,
                    margin: const EdgeInsets.only(bottom: 150, right: 20)
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
                          padding: const EdgeInsets.only(top: 25, right: 10)  ,
                          child: Material(
                            color: Colors.transparent,
                            child: IconButton(
                              color: Colors.white,
                              icon: const Icon(Icons.logout),
                              onPressed: ()  {
                                final ref = FirebaseDatabase.instance.ref();
                                final User? user = FirebaseAuth.instance.currentUser;
                                final uid = user?.uid;
                                ref.child('Games/$gamecode/Players/$id').update({
                                  'logout': true,
                                });
                                ref.child('Users/$uid').update({
                                  'CurGame': null,
                                });
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Home()));
                              }
                            ),
                          ),
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
