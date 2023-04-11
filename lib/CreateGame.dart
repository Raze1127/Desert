import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nanoid/nanoid.dart';

import 'GamePageOld.dart';

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
    FirebaseDatabase database = FirebaseDatabase.instance;

    database.ref("Games/$GameCode").update({
      "admin": uid.toString(),
    });

    final snapshot = await ref.child('Users/$uid/friends/friendsUID').get();
    var str = snapshot.value.toString();
    if (str == 'null' || str == '') {
      print(str);
      return 'null';
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
      print("${iop}HBLJHFC");
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
        "request": GameCode,
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
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                          "${index + 1}.",
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 4, 10, 4),
                        child: CircleAvatar(
                          backgroundImage:
                              NetworkImage(friend[(2 + index * 3)]),
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
                        padding: const EdgeInsets.fromLTRB(14, 0, 0, 0),
                        child: Text(
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                          friend[(3 + index * 3)],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(CupertinoIcons.add_circled_solid),
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
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                          "${index + 1}.",
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 4, 10, 4),
                        child: CircleAvatar(
                          backgroundImage:
                              NetworkImage(friend[(2 + index * 3)]),
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
                        padding: const EdgeInsets.fromLTRB(14, 0, 0, 0),
                        child: Text(
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                          friend[(3 + index * 3)],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.call_missed),
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
                    body: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Text(
                              'Create Game',
                              style: TextStyle(
                                  color: Color(0xff4c505b), fontSize: 40),
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
                                print(snapshot.data.toString());
                                List<String> friend =
                                    snapshot.data.toString().split("|");
                                if (friend[(2 + index * 3)] == "null") {
                                  return const Text("");
                                } else {
                                  print(friend);
                                  return SizeTransition(
                                    key: UniqueKey(),
                                    sizeFactor: animation,
                                    child: SizedBox(
                                      height: 80,
                                      child: Card(
                                        margin: const EdgeInsets.all(10),
                                        elevation: 10,
                                        color: Colors.white,
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Text(
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                  ),
                                                  "${index + 1}.",
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 4, 10, 4),
                                                child: CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                      friend[(2 + index * 3)]),
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
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        14, 0, 0, 0),
                                                child: Text(
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                  ),
                                                  friend[(3 + index * 3)],
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      _removeItem(
                                                          index, friend);
                                                      setState(() {});
                                                    },
                                                    icon: const Icon(Icons.add),
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
                                      backgroundColor: Colors.green),
                                  onPressed: () {
                                    FirebaseDatabase database =
                                        FirebaseDatabase.instance;
                                    final User? user =
                                        FirebaseAuth.instance.currentUser;
                                    final uid = user?.uid;

                                    database.ref("Users/$uid/").update({
                                      "CurGame": GameCode,
                                    });

                                    List<String> uids = players.split("|");
                                    for (var i = 0; i < uids.length; i++) {
                                      database.ref("Users/${uids[i]}/").update({
                                        "player": i+1,
                                        "CurGame": GameCode,
                                      });

                                      database.ref("Games/$GameCode/players/${i+1}").update({
                                        'uid': uids[i],
                                        "x": i*100,
                                        "y": i*100,
                                        "isFire": false,
                                      });
                                    }


                                    var time =
                                    ((DateTime.now().millisecondsSinceEpoch) / 1000).floor();

                                    database.ref("Games/$GameCode").update({
                                      "time": time.toString(),
                                    });


                                  },
                                  child: const Text(
                                    'Start Game',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 35,
                                    ),
                                  )),
                            ),
                          ),
                        ),
                      ],
                    )));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }));
  }
}
