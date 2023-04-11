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
import 'package:image_picker/image_picker.dart';
import 'package:koleso_fortune/CreateGame.dart';

import 'package:path/path.dart';

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

  Future<String> GetPoints() async {
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    final name = await ref.child('Users/$uid/Points').get();

    return name.value.toString();
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


      final friendsSorted = SplayTreeMap<String, int>.from(
          friends, (keys1, keys2) =>
          friends[keys2]!.compareTo(friends[keys1]!));

      print(friendsSorted);

      print("$friends 1ФФФФФФФФФФФФФФФФФ");
      for (var i = 0; i < friendsSorted.length; i++) {
        var uid = friendsSorted.keys.elementAt(i);
        final name = await ref.child('Users/$uid/Name').get();
        final photo = await ref.child('Users/$uid/photo').get();
        final point = await ref.child('Users/$uid/Points').get();
        if (name.value.toString() != "null") {
          friend +=
          "|${name.value.toString()}|${photo.value.toString()}|${point.value
              .toString()}";
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



  Future<String> GetCode() async {
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    final snapshot = await ref.child('Users/$uid/code').get();

    DatabaseReference starCountRef =
    FirebaseDatabase.instance.ref('Users/$uid/request');





    starCountRef.onValue.listen((DatabaseEvent event) async {
      final data = event.snapshot.value;
      if (data != "null") {
        final uidNick = (await ref.child('Games/$data/admin').get()).value
            .toString();
        final nick = (await ref.child('Users/$uidNick/Name').get()).value
            .toString();
        var players = (await ref.child('Games/$data/players').get()).value
            .toString();
        if (nick != "null") {


        if (players == "null") {
          players = "";
        }
        showDialog(
            context: this.context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Request for a game"),
                content: Text("$nick wants to play with you"),
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
                      child: Text("Отклонить")),
                  TextButton(
                      onPressed: () {


              database.ref("Users/$uid/").update({
              "answer": "yes",
              });
              database.ref("Users/$uid/").update({
              "request": "",
              });
              }





    return snapshot.value.toString();
  }

  Future<void> addFriend(String code) async {
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    final snapshot =
    await ref.child("Users/").orderByChild("code").equalTo(code).get();
    String fullCode = snapshot.value.toString();
    FirebaseDatabase database = FirebaseDatabase.instance;

    var uidFriend = fullCode.substring(
        1, fullCode.length - (fullCode.length - fullCode.indexOf(":")));

    // final name = await ref.child('Users/$uidFriend/Name').get();
    // final points = await ref.child('Users/$uidFriend/Points').get();
    // final photo = await ref.child('Users/$uidFriend/photo').get();
    final snapshot23 = (await ref.child("Users/$uid/friends/friendsUID").get())
        .value
        .toString();
    final snapshotFriend =
    (await ref.child("Users/$uidFriend/friends/friendsUID").get())
        .value
        .toString();
    if (uidFriend != uid) {
      if (snapshotFriend == "null") {
        codeController.clear();
        database.ref("Users/$uidFriend/friends").update({
          "friendsUID": "$uid",
        });
      } else {
        List<String> mylist = snapshotFriend.split("|");

        if (mylist.contains(uid)) {
          print("already");
        } else {
          database.ref("Users/$uidFriend/friends").update({
            "friendsUID": "|$snapshotFriend$uid",
          });
          codeController.clear();
        }
      }

      if (snapshot23 == "null" || snapshot23 == "") {
        database.ref("Users/$uid/friends").update({
          "friendsUID": "$uidFriend",
        });
        codeController.clear();
      } else {
        print(snapshot23);
        List<String> mylist = snapshot23.split("|");

        if (mylist.contains(uidFriend)) {
          codeController.clear();
          print("already");
        } else {
          print(uid! + " " + uidFriend);
          if(snapshot23 ==  ""){
            database.ref("Users/$uid/friends").update({
              "friendsUID": "|$uidFriend",
            });
            codeController.clear();
          }else{
            database.ref("Users/$uid/friends").update({
              "friendsUID": "$snapshot23|$uidFriend",
            });
            codeController.clear();
          }

        }
      }
    }
    setState(() {

    });
  }

  Future<void> _removeItem(int index) async {

    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    var friends = {};
    final uid = user?.uid;
    final snapshot = await ref.child('Users/$uid/friends/friendsUID').get();
    List<String> uids = snapshot.value.toString().split("|");
    var uids2 = "";
    for (var i = 0; i < uids.length; i++) {
      final point = await ref.child('Users/${uids[i]}/Points').get();
      friends.addAll({uids[i]: int.parse(point.value.toString())});
    }
    var friendsSorted = Map.fromEntries(friends.entries.toList()
      ..sort((e1, e2) => e1.value.compareTo(e2.value)));
    var delfr = friendsSorted.keys.elementAt(index);

    for(var i = 0; i < friendsSorted.length; i++){
      if(friendsSorted.keys.elementAt(i) == delfr){

      }
      else{
        if(friendsSorted.keys.elementAt(i) == ""){
          uids2 += "";
        }else{
          uids2 += "${friendsSorted.keys.elementAt(i)}|";
        }

      }
    };
    if (uids2.isNotEmpty) {
      uids2 = uids2.substring(0, uids2.length - 1);
    }
    ref.child('Users/$uid/friends/').update({
      "friendsUID": uids2,
    });
    _key.currentState!.removeItem(index, (_, animation) {
      return SizeTransition(
        sizeFactor: animation,
        child: const Card(
          margin: EdgeInsets.all(8),
          elevation: 10,
          color: Colors.white,
          child: ListTile(
            contentPadding: EdgeInsets.all(7),
            title: Text("Goodbye", style: TextStyle(fontSize: 20)),
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
              GetPhoto(),
              GetPoints(),
              GetFriends(),
            ]),
            builder:
                (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
              print("${snapshot.data}ПРИВЕЕЕт");
              if (snapshot.hasData) {


                return SafeArea(
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                             Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                          style: const TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          snapshot.data![0].toString()),
                                      GestureDetector(
                                        child: Text(
                                          'Invite code: ${snapshot.data![1].toString()}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                        onLongPress: () {
                                          Clipboard.setData(ClipboardData(
                                              text: snapshot.data![1]
                                                  .toString()));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            content: Text("Скопировано"),
                                          ));
                                        },
                                      ),
                                    ])
                              ],
                            ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        0, 50, 200, 0),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        style: const TextStyle(
                                          fontSize: 26,
                                        ),
                                        "Points: ${snapshot.data![3].toString()}",
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        0, 10, 230, 20),
                                    child: Align(
                                      alignment:
                                      AlignmentDirectional.centerStart,
                                      child: Text(
                                        style: const TextStyle(
                                          fontSize: 26,
                                        ),
                                        "Top: ${snapshot.data![3].toString()}",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0, 2, 210, 0),
                                child: Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Text(
                                    style: TextStyle(
                                      fontSize: 26,
                                    ),
                                    "Friends",
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 350,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0, 20, 20, 0),
                                    child: Container(
                                      width: 220,
                                      child: TextField(
                                        controller: codeController,
                                        decoration: const InputDecoration(
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
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0, 20, 0, 0),
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(25)),
                                          ),
                                        ),
                                        onPressed: () {
                                          if (codeController.text.isNotEmpty) {
                                            addFriend(codeController.text);
                                            print(snapshot.data![4]);
                                            setState(() {});
                                          }
                                        },
                                        child: const Text(
                                          "Add",
                                          style: TextStyle(
                                            fontSize: 20,
                                          ),
                                        )),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 7, 0, 0),
                            child: SizedBox(
                              width: 350,
                              height: 200,

                              child: AnimatedList(
                                key: _key,
                                initialItemCount: iop,
                                padding: const EdgeInsets.all(10),
                                itemBuilder: (_, index, animation) {
                                  print(snapshot.data![4].toString());
                                  List<String> friend = snapshot.data![4].toString().split("|");
                                  if(friend[(2 + index * 3)] == "null"){
                                    return const Text("");
                                  }else {
                                    print(friend);
                                    return SizeTransition(
                                      key: UniqueKey(),
                                      sizeFactor: animation,
                                      child: SizedBox(
                                        height: 80,
                                        child: Card(
                                          margin: const EdgeInsets.all(
                                              10),
                                          elevation: 10,
                                          color: Colors.white,
                                          child: Padding(
                                            padding: const EdgeInsets.all(
                                                4.0),
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .all(4.0),
                                                  child:
                                                  Text(
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                    ),
                                                    "${index + 1}.",
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .fromLTRB(
                                                      0, 4, 10, 4),
                                                  child: CircleAvatar(
                                                    backgroundImage: NetworkImage(
                                                        friend[(2 +
                                                            index * 3)]),
                                                    radius: 25,
                                                  ),
                                                ),

                                                Text(
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                  ),
                                                  friend[(1 + index * 3)],
                                                ),

                                                Padding(
                                                  padding: const EdgeInsets
                                                      .fromLTRB(
                                                      14, 0, 0, 0),
                                                  child: Text(
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                    ),
                                                    friend[(3 +
                                                        index * 3)],
                                                  ),
                                                ),

                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
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
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),

                        ],
                      ),

                    ),
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            })
    );
  }
}
