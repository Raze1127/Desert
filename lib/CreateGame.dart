import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nanoid/nanoid.dart';
import 'package:http/http.dart' as http;

import 'GamePageOld.dart';
import 'GameTanks.dart';
import 'GameTanksSingle.dart';

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
  final GlobalKey<AnimatedListState> _key2 = GlobalKey();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  var iop = 0;
  var value = 1;
  var t=0;
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
    if(snapshot.value.toString() == "null"){
      return [];
    }else{
      return friends;
    }


  }
  void sendPushMessage(String body, String title, String token) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
          'key=AAAAxkBoobs:APA91bEOkequ3bZVO0Wh3njtyM8huxybgpJ2G2lBXSYpBrsiuhZ4IijJiqARKAGg_IzbrWrLfnESXw0zKn0ukjkfc9hQ8WTc-h6-Ws9YTdxqLS9dGdBc7S643pa12RKVoGZNOyVDf2u0',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': body,
              'title': title,
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to": token,
          },
        ),
      );
      print('done');
      print(token);
    } catch (e) {
      print("error push notification");
    }
  }

  void check(item, int index) async {

    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    var name  = (await ref.child('Users/$uid/Name').get()).value.toString();
    var fcm  = (await ref.child('Users/$item/fcmToken').get()).value.toString();
    sendPushMessage("You have a new game request from $name", "New Game Request", fcm);
      FirebaseDatabase database = FirebaseDatabase.instance;

      database.ref("Users/$item/").update({
        "answer": "",
        "request": "$GameCode/$name",
      });
      DatabaseReference starCountRef =
          FirebaseDatabase.instance.ref('Users/$item/answer');
      starCountRef.onValue.listen((DatabaseEvent event) {
        var data = event.snapshot.value;

        if (data == "yes" && !players.contains(item)) {
          if (players == "") {
            setState(() {
              idFriend= item;
              players = item;
              _key2.currentState!.insertItem(0);
              _key.currentState!.removeItem(index, (context, animation) => Container());
            });

          } else {
            setState(() {
              players += "|$item";
              idFriend= item;
              t++;
              _key2.currentState!.insertItem(t);
              _key.currentState!.removeItem(index, (context, animation) => Container());
            });

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
  int playe(){
    if(players == ""){
      return 0;
    }else{
      return players.split("|").length;
    }
  }

  Future<List<String>> getFriendData(String uid) async {
    final ref = FirebaseDatabase.instance.ref();
    final name = await ref.child('Users/$uid/Name').get();
    final xp = await ref.child('Users/$uid/Points').get();

    return [name.value.toString(), xp.value.toString()];
  }
 var idFriend;


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
                            padding: EdgeInsets.all(15.0),
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
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child:
                                  Text(
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
                                    "${playe()  }/4",
                                  ),
                                ),

                              Padding(padding:  EdgeInsets.all(10),
                                child: SizedBox(
                                  width: 350,
                                  height: 200,
                                  child: AnimatedList(
                                    key: _key2,
                                    initialItemCount: players.length,
                                    itemBuilder: (BuildContext context, int index, Animation<double> animation) {
                                      var item = idFriend;
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
                                    }
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child:
                                Text(
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
                                  "Friends",
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 7, 0, 0),
                                child: SizedBox(
                                  width: 350,
                                  height: 200,
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


                                                              if(players.length == 4 ){

                                                              }else{
                                                                check(item, index);
                                                                setState(() {});
                                                              }
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




                            ],
                          ),

                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                child: Column(
                                  children: [
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey[800]),
                                        onPressed: () {
                                          print(players)  ;
                                          List<String> uids = players.split("|");
                                          gameCreation(players);
                                        },
                                        child:  Text(
                                          'Start with friends',
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
                                                wordSpacing: -3,
                                                fontSize: 15,

                                              )),
                                        )),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey[800]),
                                        onPressed: () {
                                          gameCreationSingle();
                                        },
                                        child:  Text(
                                          'Singleplayer',
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
                                                wordSpacing: 1,
                                                fontSize: 15,

                                              )),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                    ));
              } else {
                return  Center(
                  child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/images/background.png"),
                            fit: BoxFit.fill),
                      ),
                      child: const Center(child: CircularProgressIndicator())),
                );
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
    List<String> coordinates = ['120/400','60/160','500/800','850/600', '850/200'];
    var last = players.length;
    players.forEachIndexed((i, element) async {
      var skinchik = 1;
      final nick =
      (await ref.child('Users/$element/Name').get()).value.toString();
      final skin =
      (await ref.child('Users/$element/SelectedSkin').get()).value.toString();
      if(skin == 'null'){
        ref.child('Users/$element').update({
          'SelectedSkin': '1',
        }
        );
      }else{
        skinchik = int.parse(skin)+1;
      }


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
          'kills': 0,
          'deaths': 0,
          'isDead': false,
          'Skin': skinchik.toString(),
        }
        );

        ref.child('Users/$element').update({
          'player': i + 1,
          'CurGame': GameCode,
        }
        ).then((value) => {
        if(last == i+1){
            ref.child('Games/$GameCode').update({
          'isStart': 1,
        }
        ).then((value) => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>  const SimpleExampleGame())) )
      }
        });


      }
    });
  }


  void gameCreationSingle(){
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;


        ref.child('Users/$uid/Single').update({
          'kills': 0,
          'deaths': 0,
          'isDead': false,
          'isImmortal': false,
        }
        );

        ref.child('Users/$uid').update({
          'CurGame': "Single",
        }
        ).then((value) => {
          Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>  const SinglePlayer()))

        });




  }


}
