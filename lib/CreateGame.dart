import 'dart:async';
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
  String playersNo = "";
  String GameCode = nanoid(5);
  final GlobalKey<AnimatedListState> _key = GlobalKey();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  var iop = 0;
  var value = 1;
  var add = const Icon(
      Icons.add);

  var no = const Icon(
    Icons.call_missed_outgoing
  );
  var yes = const Icon(
    Icons.check
  );

  Future<List> GetFriends() async {

    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    final snapshot = await ref.child('Users/$uid/friends/friendsUID').get();
    final friends = snapshot.value.toString().split("//");
    return friends;
  }

  void check(item) async {

    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    var name  = (await ref.child('Users/$uid/Name').get()).value.toString();

      FirebaseDatabase database = FirebaseDatabase.instance;

      database.ref("Users/$item/").update({
        "answer": "",
        "request": "$GameCode/$name",
      });
      DatabaseReference starCountRef =
          FirebaseDatabase.instance.ref('Users/$item/answer');
      starCountRef.onValue.listen((DatabaseEvent event) {
        var data = event.snapshot.value;

        if (data == "yes") {
          if (players == "") {
            players = item;
          } else {
            players += "|$item";
          }

          setState(() {
            add = yes;
          });
        }
        if (data == "no") {
          if (playersNo == "") {
            playersNo = item;
          } else {
            playersNo += "|$item";
          }
          database.ref("Users/$item/").update({
            "answer": "",
            "request": "",
          });
          setState(() {
            add = no;
          });
        }
      });

  }

  Future<List<String>> getFriendData(String uid) async {
    final ref = FirebaseDatabase.instance.ref();
    final name = await ref.child('Users/$uid/Name').get();
    final xp = await ref.child('Users/$uid/Points').get();

    return [name.value.toString(), xp.value.toString()];
  }



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
                (BuildContext context,  snapshot) {
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
                                initialItemCount: (snapshot.data![0]).length,
                                itemBuilder: (BuildContext context, int index, Animation<double> animation) {
                                  final item = (snapshot.data![0])[index];


                                  return FutureBuilder(
                                      future: getFriendData(item),
                                      builder: (context, snapshot) {


                                        if (snapshot.hasData) {
                                          List<String> playersnono = playersNo.split("|");
                                          List<String> playersyes = players.split("|");
                                          final userData = snapshot.data as List;
                                          var name = userData[0];
                                          var xp = userData[1];
                                          if(playersnono.contains(item)){
                                            add = no;
                                          }else{
                                          if(playersyes.contains(item)){
                                            add = yes;
                                          }else{
                                            add = const Icon(
                                                Icons.add);
                                          }
                                          }

                                          return Card(
                                            margin: const EdgeInsets.all(10),
                                            elevation: 10,
                                            color: Colors.grey[800],
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                  4.0),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets.all(4.0),
                                                    child: Text(
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
                                                      "${index + 1}.",
                                                    ),
                                                  ),

                                                  Text(
                                                    style: GoogleFonts
                                                        .pressStart2p(
                                                        textStyle: const TextStyle(
                                                          shadows: [
                                                            Shadow(
                                                              // bottomLeft
                                                                offset: Offset(
                                                                    -1.5, -1.5),
                                                                color: Colors
                                                                    .black),
                                                            Shadow(
                                                              // bottomRight
                                                                offset: Offset(
                                                                    1.5, -1.5),
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
                                                                    -1.5, 1.5),
                                                                color: Colors
                                                                    .black),
                                                          ],
                                                          color: Colors.white,

                                                          fontSize: 15,

                                                        )),
                                                    name.toString(),
                                                  ),
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets.fromLTRB(
                                                        9, 0, 0, 0),
                                                    child: Text(
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

                                                      'LVL: ${xp.toString()}',
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                    children: [
                                                      IconButton(
                                                        onPressed: () {

                                                          check(item);
                                                          setState(() {});
                                                        },
                                                        icon: add,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        } else {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                      }
                                  );
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
          'angle': 0,
          'kills': 0,
          'deaths': 0,
          'isDead': false,
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
                  builder: (context) =>  const SimpleExampleGame())) );
        }
      }
    });


  }
}
