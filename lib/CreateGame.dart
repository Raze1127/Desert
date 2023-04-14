import 'dart:collection';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nanoid/nanoid.dart';

import 'GamePageOld.dart';
import 'GameTanks.dart';

class CreateGame extends StatefulWidget {
  const CreateGame({Key? key}) : super(key: key);

  @override
  _CreateGameState createState() => _CreateGameState();
}

class _CreateGameState extends State<CreateGame> {
  String players = "";
  String GameCode = nanoid(5);

  final scaffoldKey = GlobalKey<ScaffoldState>();
  var iop = 0;
  var value = 1;

  Future<String> GetFriends() async {
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    Map<String, int> friends = {};
    final uid = user?.uid;
    final snapshot = await ref.child('Users/$uid/friends/friendsUID').get();
    var str = snapshot.value.toString();
    if (str == 'null' || str == '') {
      print(str);
      return '';
    } else {
      List<String> uids = str.split("|");
      var friend = "";
      for (var i = 0; i < uids.length; i++) {
        final point = await ref.child('Users/${uids[i]}/Points').get();
        int p = int.parse(point.value.toString());
        friends[uids[i]] = p;
      }

      final friendsSorted = SplayTreeMap<String, int>.from(friends,
              (keys1, keys2) => friends[keys2]!.compareTo(friends[keys1]!));

      print(friendsSorted);

      print("$friends 1ФФФФФФФФФФФФФФФФФ");
      for (var i = 0; i < friendsSorted.length; i++) {
        var uid = friendsSorted.keys.elementAt(i);
        final name = await ref.child('Users/$uid/Name').get();
        final photo = await ref.child('Users/$uid/photo').get();
        final point = await ref.child('Users/$uid/Points').get();
        if (name.value.toString() != "null") {
          friend +=
          "|${name.value.toString()}|${photo.value.toString()}|${point.value.toString()}";
        }
      }
      if (friend.toString() == "|null|null|null" || friend.toString() == "") {
        iop = friendsSorted.length - 1;
      } else {
        iop = friendsSorted.length;
      }
      print(friend);
      return friend.toString();
    }
  }

  Future<void> _removeItem(int index, List<String> friend) async {
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    var friends = {};
    final uid = user?.uid;
    final snapshot = await ref.child('Users/$uid/friends/friendsUID').get();
    var str = snapshot.value.toString();
    if (str == 'null' || str == '') {
      print(str);
    } else {
      List<String> uids = str.split("|");

      for (var i = 0; i < uids.length; i++) {
        final point = await ref.child('Users/${uids[i]}/Points').get();
        int p = int.parse(point.value.toString());
        friends[uids[i]] = p;
      }

      FirebaseDatabase database = FirebaseDatabase.instance;
      final friendsSorted = SplayTreeMap<String, int>.from(friends,
          (keys1, keys2) => friends[keys2]!.compareTo(friends[keys1]!));
      var onlyKey = friendsSorted.entries.toList();
      var olik = onlyKey[index].key;

      database.ref("Users/$olik/").update({
        "answer": "",
        "request": "$GameCode/$uid",
      });
      DatabaseReference starCountRef =
          FirebaseDatabase.instance.ref('Users/$olik/answer');
      starCountRef.onValue.listen((DatabaseEvent event) {
        var data = event.snapshot.value;
        if (data == "yes") {
          if (players == "") {
            players = olik;
          } else {
            players += "|$olik";
          }

          _key.currentState!.removeItem(index, (_, animation) {
            return SizeTransition(
              sizeFactor: animation,

              child: Card(
                margin: const EdgeInsets.all(10),
                elevation: 10,
                color: Colors.grey[800],
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      Padding(
                        padding:
                        const EdgeInsets.all(4.0),
                        child: Text(
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

                                fontSize: 15,

                              )),
                          "${index + 1}.",
                        ),
                      ),

                      Text(
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

                              fontSize: 15,

                            )),
                        friend[(1 + index * 3)],
                      ),
                      Padding(
                        padding:
                        const EdgeInsets.fromLTRB(
                            30, 0, 0, 0),
                        child: Text(
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

                                fontSize: 15,

                              )),

                          'LVL: ${friend[(3 + index * 3)]}',
                        ),
                      ),
                      Row(

                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {

                              _removeItem(index, friend);
                              setState(() {});
                            },
                            icon: const Icon(
                                Icons.add_circle),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }, duration: const Duration(days: 100000000000000000));
        }
        if (data == "no") {
          database.ref("Users/$olik/").update({
            "answer": "",
            "request": "",
          });
          _key.currentState!.removeItem(index, (_, animation) {
            return SizeTransition(
              sizeFactor: animation,
              child: Card(
                margin: const EdgeInsets.all(10),
                elevation: 10,
                color: Colors.grey[800],
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      Padding(
                        padding:
                        const EdgeInsets.all(4.0),
                        child: Text(
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

                                fontSize: 15,

                              )),
                          "${index + 1}.",
                        ),
                      ),

                      Text(
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

                              fontSize: 15,

                            )),
                        friend[(1 + index * 3)],
                      ),
                      Padding(
                        padding:
                        const EdgeInsets.fromLTRB(
                            30, 0, 0, 0),
                        child: Text(
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

                                fontSize: 15,

                              )),

                          'LVL: ${friend[(3 + index * 3)]}',
                        ),
                      ),
                      Row(

                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {

                              _removeItem(index, friend);
                              setState(() {});
                            },
                            icon: const Icon(
                                Icons.call_missed_outgoing),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }, duration: const Duration(days: 100000000000000000));
        }
      });
    }
  }

  final GlobalKey<AnimatedListState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xffE0E3E7),
        body: FutureBuilder(
            future: Future.wait([
              GetFriends(),
            ]),
            builder:
                (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
              if (snapshot.hasData) {
                return Scaffold(

                    backgroundColor: const Color(0xffE0E3E7),
                    body: Container(
                      height: double.infinity,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/background.png"),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                           Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                'Create Game',
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
                                      fontSize: 25,
                                    ))
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 7, 0, 0),
                            child: SizedBox(
                              width: 350,
                              height: 350,
                              child: AnimatedList(
                                key: _key,
                                initialItemCount: iop,
                                padding: const EdgeInsets.all(10),
                                itemBuilder: (_, index, animation) {
                                  List<String> friend =
                                  snapshot.data![0].toString().split("|");
                                  print(friend);
                                  if (friend[(2 + index * 3)] == "null") {  //Если друга нет
                                    return const Text("");
                                  } else {  //Если друг есть
                                    print(friend);
                                    return SizeTransition(
                                      key: UniqueKey(),
                                      sizeFactor: animation,
                                      child: SizedBox(
                                        height: 80,
                                        child: Card(
                                          margin: const EdgeInsets.all(10),
                                          elevation: 10,
                                          color: Colors.grey[800],
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.all(4.0),
                                                  child: Text(
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

                                                          fontSize: 15,

                                                        )),
                                                    "${index + 1}.",
                                                  ),
                                                ),

                                                Text(
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

                                                        fontSize: 15,

                                                      )),
                                                  friend[(1 + index * 3)],
                                                ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.fromLTRB(
                                                      30, 0, 0, 0),
                                                  child: Text(
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

                                                          fontSize: 15,

                                                        )),

                                                    'LVL: ${friend[(3 + index * 3)]}',
                                                  ),
                                                ),
                                                Row(

                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  children: [
                                                    IconButton(
                                                      onPressed: () {

                                                        _removeItem(index, friend);
                                                        setState(() {});
                                                      },
                                                      icon: const Icon(
                                                          Icons.add_circle_outline_sharp),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[800]),
                                    onPressed: () {
                                      print(players)  ;
                                      List<String> uids = players.split("|");
                                      gameCreation(players);
                                    },
                                    child:  Text(
                                      'Start Game',
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

                                            fontSize: 20,

                                          )),
                                    )),
                              ),
                            ),
                          ),
                        ],
                      )),
                    ));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }));
  }
  void gameCreation(String players2){
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    if (players2 == "") {
      players2 = uid!;
    } else {
      players2 += "|$uid";
    }

    List<String> players = players2.split("|");


    print(players.length);
    print(players); //Список игроков
    List<String> coordinates = ['120/400','20/140','500/800','850/600', '850/200'];
    var last = players.length;
    players.forEachIndexed((i, element) async {
      final nick =
      (await ref.child('Users/$element/Name').get()).value.toString();

      var cords = coordinates[i];
      List<String> xy = cords.split("/");
      print("$nick $xy");
      if (nick == 'null') {
        print('null');
      }else {
        ref.child('Games/$GameCode/Players/${i + 1}').update({
          'uid': element,
          'life': 200,
          'name': nick,
          'x': xy[0],
          'y': xy[1],
          'isFire': 0,
          'speed': 0,
          'angle': 0
        }
        );

        ref.child('Users/$element').update({
          'player': i + 1,
          'CurGame': GameCode,
        }
        );

        if(last == i+1){
          ref.child('Games/$GameCode').update({
            'isStart': 1,
          }
          ).then((value) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const SimpleExampleGame())) );
        }
      }
    });


  }
}
