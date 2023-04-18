import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'dart:async';

import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koleso_fortune/CreateGame.dart';

import 'package:path/path.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import 'GameTanks.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  var value = 1;
  var iop = 0;

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  Future<String> GetName() async {
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    final name = await ref.child('Users/$uid/Name').get();

    return name.value.toString();
  }
  Future<List<String>> getFriendData(String uid) async {

    final name = await ref.child('Users/$uid/Name').get();
    final xp = await ref.child('Users/$uid/Points').get();

    return [name.value.toString(), xp.value.toString()];
  }

  Future<List> GetPoints() async {
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    final kills = int.parse((await ref.child('Users/$uid/kills').get()).value.toString());
    final deaths = int.parse((await ref.child('Users/$uid/deaths').get()).value.toString());
    var xp = (kills*80-deaths*30);
    print(xp);
    if(xp<=0){
      xp=1;
    }
    int currentLevel = 1; // текущий уровень
    int xpForCurrentLevel = 300; // количество xp для текущего уровня
    int xpForNextLevel = xpForCurrentLevel + 200; // количество xp для следующего уровня

    while (xpForNextLevel <= xp) {
      currentLevel++;
      xpForCurrentLevel = xpForNextLevel;
      xpForNextLevel += 200;
    }
    print("Текущий уровень: $currentLevel");
    print("Количество xp для текущего уровня: $xpForCurrentLevel");
    print("Количество xp для следующего уровня: $xpForNextLevel");
    var perc = xp/xpForNextLevel;
    print(perc);
    print("$xpForNextLevel LOLOLO $xp");
    return [kills, deaths, xp, currentLevel, xpForNextLevel, perc];
  }

  Future<String> GetPhoto() async {
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    final relat = await ref.child('Users/$uid/photo').get();

    if (relat.exists) {
      return relat.value.toString();
    } else {
      return relat.value.toString();
    }
  }

  Future<List> GetFriends() async {

    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    final snapshot = await ref.child('Users/$uid/friends/friendsUID').get();
    final friends = snapshot.value.toString().split("//");
    return friends;
  }

  Future<String> GetCode() async {
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    final snapshot = await ref.child('Users/$uid/code').get();


    return snapshot.value.toString();
  }
  @override
  void initState(){


    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    DatabaseReference starCountRef =
    FirebaseDatabase.instance.ref('Users/$uid/request');
    starCountRef.onValue.listen((DatabaseEvent event) async {
      final data = event.snapshot.value;
      if (data != null) {
        List<String> pringls = data.toString().split("/");
        if (pringls[1] != "null") {

          showDialog(
              context: this.context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Colors.blueGrey[900],
                  title:  Text("Request for a game",
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
                            fontSize: 13,
                          ))),
                  content: Text("${pringls[1]} wants to play with you",
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
                            fontSize: 12,
                          ))),
                  actions: [
                    TextButton(
                        onPressed: () {
                          database.ref("Users/$uid/").update({
                            "answer": "no",
                          });
                          database.ref("Users/$uid/").update({
                            "request": "",
                          });
                          Navigator.pop(context);
                        },
                        child:  Text("Отклонить",
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
                                )))),
                    TextButton(
                      child:  Text("Принять",
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
                              ))),
                      onPressed: () {

                        database.ref("Users/$uid/").update({
                          "answer": "yes",
                        }).then((value) => database.ref("Users/$uid/").update({
                          "request": "",
                        }).then((value) => showDialog(
                            context: this.context,
                            builder: (BuildContext context) {
                              DatabaseReference start =
                              FirebaseDatabase.instance.ref('Games/${pringls[0]}/isStart');
                              start.onValue.listen((DatabaseEvent event)  {
                                final data = event.snapshot.value;
                                if (data != null) {
                                  if (data == 1) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const SimpleExampleGame()));
                                  }
                                }
                              });
                              return AlertDialog(
                                backgroundColor: Colors.blueGrey[900],
                                title:  Text(" Waiting for the start of the game...",
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
                                          fontSize: 13,
                                        ))),
                                content:
                                Container(width: 50, height: 50, child: CircularProgressIndicator()),


                              );
                            })


                        )
                        );

                      },
                    ),
                  ],
                );
              });
        }
      }
    });
    super.initState();
  }

  void addFriend(String code) async {
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    final equal =
    await ref.child("Users/").orderByChild("code").equalTo(code).get();

    final Frienduid = equal.children.first.key;

    final FriendsFriends =
    await ref.child("Users/$Frienduid/friends/friendsUID").get();
    final MyFriends = await ref.child("Users/$uid/friends/friendsUID").get();

    List<String> MyFriendsList = MyFriends.value.toString().split("//");
    List<String> FriendsFriendsList = FriendsFriends.value.toString().split("//");
    if (FriendsFriendsList.contains(uid)) {
      print("Уже друзья");
    } else {
      if (MyFriendsList.contains(Frienduid)) {
        print("Уже друзья");
      } else {
        if(FriendsFriends.value.toString() != "null") {
          database.ref("Users/$Frienduid/friends/").update({
            "friendsUID": "${FriendsFriends.value}//$uid",
          });
        }else{
          database.ref("Users/$Frienduid/friends/").update({
            "friendsUID": "$uid",
          });
        }

        if(MyFriends.value.toString() != "null") {
          database.ref("Users/$uid/friends/").update({
            "friendsUID": "${MyFriends.value}//$Frienduid",
          });
        }else{
          database.ref("Users/$uid/friends/").update({
            "friendsUID": "$Frienduid",
          });
        }


      }
    }

  }

  Future<void> _removeItem(int index) async {
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    var friends = {};
    final uid = user?.uid;
    final snapshot = await ref.child('Users/$uid/friends/friendsUID').get();
    List<String> uids = snapshot.value.toString().split("//");
    uids.removeAt(index);
    String result = uids.join('//');
    ref.child('Users/$uid/friends/').update({
      "friendsUID": result,
    });
    _key.currentState!.removeItem(index, (_, animation) {
      return SizeTransition(
        sizeFactor: animation,
        child:  Card(
          margin: EdgeInsets.all(8),
          elevation: 10,
          color: Colors.white,
          child: ListTile(
            contentPadding: EdgeInsets.all(7),
            title: Text("Goodbye",
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
                    ))),
          ),
        ),
      );
    }, duration: const Duration(milliseconds: 500));
  }

  final codeController = TextEditingController();
  FirebaseDatabase database = FirebaseDatabase.instance;
  final ref = FirebaseDatabase.instance.ref();
  final User? user = FirebaseAuth.instance.currentUser;
  final GlobalKey<AnimatedListState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xffE0E3E7),
        body: FutureBuilder(
            future: Future.wait([
              GetName(),
              GetCode(),
              GetFriends(),
              GetPoints()
            ]),
            builder:
                (BuildContext context,  snapshot) {
              print(snapshot.data);
              if (snapshot.hasData) {
                List daty = snapshot.data![3] as List;
                GetPoints();
                return Container(
                    height: double.infinity,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/images/background.png"),
                          fit: BoxFit.fill),
                    ),
                    child: SingleChildScrollView(

                      child: Column(children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 43, left: 20),
                              child: Column(
                                children: [
                                  Text(snapshot.data![0] as String,
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
                                          ))),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(snapshot.data![1] as String,
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
                                            ))),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Никнейм и код
                        Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: Text("LVL ${daty[3]}",
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
                                  ))),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Opacity(
                                opacity: 1,
                                child: LinearPercentIndicator(
                                  center: Text("${daty[2]} xp",
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
                                          ))),
                                  width: MediaQuery.of(context).size.width - 30,
                                  animation: true,
                                  lineHeight: 20.0,
                                  percent: daty[5],
                                  barRadius: const Radius.circular(10),
                                  linearStrokeCap: LinearStrokeCap.roundAll,
                                  backgroundColor: Colors.grey,
                                  progressColor:  Colors.blueGrey[900],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: Text("STATS",
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
                                    fontSize: 22,
                                  ))),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10, left: 20, right: 20),
                          child: Opacity(
                            opacity: 0.8,
                            child: Container(
                              color: Colors.grey,
                              child: Card(
                                elevation: 0,
                                color: Colors.transparent,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 30, left: 5),
                                            child: Text("KILLS: ${daty[0]}",
                                                style: GoogleFonts.pressStart2p(
                                                    textStyle: const TextStyle(
                                                      shadows: [
                                                        Shadow(
                                                          // bottomLeft
                                                            offset:
                                                            Offset(-1.5, -1.5),
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
                                                    ))),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 15, left: 10, bottom: 30),
                                            child: Text("DEATHS: ${daty[1]}",
                                                style: GoogleFonts.pressStart2p(
                                                    textStyle: const TextStyle(
                                                      shadows: [
                                                        Shadow(
                                                          // bottomLeft
                                                            offset:
                                                            Offset(-1.5, -1.5),
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
                                                    ))),
                                          )
                                        ])
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        //Статистика
                        Padding(
                          padding: const EdgeInsets.only(top: 25),
                          child: Column(
                            children: [
                              Text("FRIENDS",
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
                                      ))),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 10, left: 20, right: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0, 20, 20, 0),
                                        child: Container(
                                          width: 200,
                                          child: TextField(

                                            controller: codeController,
                                            decoration: const InputDecoration(
                                              fillColor: Colors.grey,
                                              filled: true,
                                              hintText: 'Invite code',
                                              border: OutlineInputBorder(

                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(25.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                          padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0, 20, 0, 0),
                                          child: ElevatedButton(
                                            style:
                                            ElevatedButton.styleFrom(
                                              primary: Colors.blueGrey[900],
                                              shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(25)),
                                              ),
                                            ),
                                            onPressed: () {
                                              if (codeController
                                                  .text.isNotEmpty) {
                                                addFriend(codeController.text);

                                                setState(() {});
                                              }
                                            },
                                            child: Text("ADD",
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

                                                      fontSize: 12,

                                                    ))
                                            ),
                                          )
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(
                                    top: 20, left: 20, right: 20),
                                height: 200,
                                child: AnimatedList(
                                  key: _key,
                                  initialItemCount: (snapshot.data![2] as List).length,
                                  itemBuilder: (BuildContext context, int index, Animation<double> animation) {
                                    final item = (snapshot.data![2] as List)[index];

                                    return FutureBuilder(
                                        future: getFriendData(item),
                                        builder: (context, snapshot) {

                                          if (snapshot.hasData) {
                                            final userData = snapshot.data as List;
                                            var name = userData[0];
                                            var xp = userData[1];
                                            return Card(
                                              margin: const EdgeInsets.all(10),
                                              elevation: 10,
                                              color: Colors.blueGrey[900],
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
                                                            _removeItem(index);
                                                            setState(() {});
                                                          },
                                                          icon: const Icon(
                                                              Icons.delete),
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
                              Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:  Colors.blueGrey[900],
                                    //add radius to button
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (_, __, ___) => CreateGame(),
                                        transitionDuration: Duration(milliseconds: 200),
                                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                          const begin = Offset(0.0, 1.0);
                                          const end = Offset.zero;
                                          final tween = Tween(begin: begin, end: end);
                                          final offsetAnimation = animation.drive(tween);

                                          return SlideTransition(
                                            position: offsetAnimation,
                                            child: child,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Text("CREATE GAME",
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
                                          ))),
                                ),
                              )
                            ],
                          ),
                        ),
                      ]),
                    ));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }));
  }
}
