import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:koleso_fortune/Home.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  StreamController<int> selected = StreamController<int>();
  final bidController = TextEditingController();
  var points = 100;
  var _start = "0";
  var stratTime;
  late Timer _timer;
  var win;
  var bid = "0";
  var type;
  var io = "null";

  @override
  void dispose() {
    selected.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = <String>[
      'X1',
      'X2',
      'X1',
      'X2',
      'X10',
      'X1',
      'X2',
      'X5',
      'X1',
      'X2',
      'X1',
      'x5',
      'X1',
      'X10',
      'X1',
      'X2',
      'X1',
      'X5',
      'X1',
      'X2'
    ];

    Future<String> GetPoints() async {
      final ref = FirebaseDatabase.instance.ref();
      final User? user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid;
      final name = await ref.child('Users/$uid/Points').get();

      return name.value.toString();
    }

    Future<void> SetPoints(int winw) async {
      final ref = FirebaseDatabase.instance.ref();
      final User? user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid;
      print("КУКУУУУ");
      FirebaseDatabase database =
          FirebaseDatabase.instance;
      database.ref("Users/$uid").update({
        "Points": winw,
      });

    }


    Future<String>GetTime() async {
      if(stratTime == null){
        final ref = FirebaseDatabase.instance.ref();
        final User? user = FirebaseAuth.instance.currentUser;
        final uid = user?.uid;
        final game = await ref.child('Users/$uid/CurGame').get();
        final time = await ref.child('Games/${game.value.toString()}/time').get();
        stratTime = time.value.toString();
      }

        var timenow = ((DateTime.now().millisecondsSinceEpoch) / 1000).floor();
        var timeleft =  timenow - int.parse(stratTime);
        var timeSync = timeleft ~/ 27;
        var timeSync2 = (timeSync * 27) - timeleft;

        var timerResult = ((26+(timeSync2))-6);


        print(timerResult);
        return timerResult.toString();

    }


    Future<String> GetWin() async {
      final ref = FirebaseDatabase.instance.ref();
      final User? user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid;
      final game = await ref.child('Users/$uid/CurGame').get();
      final wine = await ref.child('Games/${game.value.toString()}/win').get();
      win = wine.value.toString();
      return win;
    }

    _timer = Timer.periodic(const Duration(milliseconds: 500), (Timer t) async {
      var result = await GetTime();

      if(int.parse(result) == 5 ){
        GetWin();
      }

      if(int.parse(result) == 0 ){
        var res = Fortune.randomInt(1, 19);
        selected.add(int.parse(win));

      }
      if(int.parse(result) == 19 ){

        if(io != "null") {
          io = "null";
          var wining = await int.parse(await GetWin());
          var points = int.parse(await GetPoints());
          if(type == "X1"){
            print("X1");
            if(wining == 0 || wining == 2 || wining == 5 || wining == 8 || wining == 10 || wining == 12 || wining == 14 || wining == 16 || wining == 18 ){
              points = points + int.parse(bid);
              SetPoints(points);

            }
            else{
              points = points - int.parse(bid);
              SetPoints(points);
            }


          }
          if(type == "X2"){
            print("X2");
            if(wining == 1 || wining == 3 || wining == 6 || wining == 9 || wining == 15 || wining == 19  ){
              points = points + int.parse(bid)*2;
              SetPoints(points);
            }
            else{
              points = points - int.parse(bid);
              print(bid);
              print("Я ТУУУУУУТ");
              SetPoints(points);
            }
          }
          if(type == "X5"){
            print("X5");
            if(wining == 7 || wining == 11 || wining == 17  ){
              points = points + int.parse(bid)*5;
              SetPoints(points);
            }
            else{
              points = points - int.parse(bid);
              SetPoints(points);
            }
          }
          if(type == "X10"){
            print("X10");
            if(wining == 4 || wining == 13 ){
              points = points + int.parse(bid)*10;
              SetPoints(points);
            }
            else{
              points = points - int.parse(bid);
              SetPoints(points);
            }
          }

        }




        var res = Fortune.randomInt(1, 19);
        final ref = FirebaseDatabase.instance.ref();
        final User? user = FirebaseAuth.instance.currentUser;
        final uid = user?.uid;
        FirebaseDatabase database =
            FirebaseDatabase.instance;
        final game = await ref.child('Users/$uid/CurGame').get();
        database.ref("Games/${game.value.toString()}").update({
          "win": res,
        });


      }
      if(int.parse(result) < 0 ){

        if(_start != "0"){
          setState(() {
            _start = "0";
          });
        }

      }
      else{
        if(_start != result){
        setState(() {
          _start = result;
        });
        }
      }
    });





    final GlobalKey<AnimatedListState> _key = GlobalKey();
    var iop = 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
          future: Future.wait([
            GetPoints(),
            GetTime(),
          ]),
        builder:  (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
            if(snapshot.hasData) {

              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                child: SingleChildScrollView(
            child: Center(
                child: Column(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                              width: 200,
                              height: 70,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.lightBlue,
                                  width: 5,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  snapshot.data![0],
                                  style: const TextStyle(
                                      color: Colors.green, fontSize: 40),
                                ),
                              )),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(30, 0, 0, 20),
                          child: Text(
                            "$_start",
                            style: TextStyle(color: Colors.green, fontSize: 30),
                          ),
                        ),
                      ]),
                      Container(
                        padding: const EdgeInsets.only(top: 15),
                        height: 300,
                        child: FortuneWheel(
                          duration: const Duration(seconds: 8),
                          selected: selected.stream,
                          items: [
                            for (var it in items)
                              FortuneItem(
                                  child: Text(
                                it,
                                textAlign: TextAlign.left,
                              )),
                          ],
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                              onPressed: () {
                            // startTimer();
                            bidController.text = "100";
                              },
                              child: const Text(
                            '100',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                            child: Container(
                                child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                              onPressed: () {
                                bidController.text = "200";
                              },
                              child: const Text(
                                '200',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            )),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: Container(
                                child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                              onPressed: () {
                                bidController.text = "500";
                              },
                              child: const Text(
                                '500',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            )),
                          ),
                        ],
                      ),
                      Container(
                        width: 320,
                        padding: EdgeInsets.only(left: 0, top: 20),
                        child: TextField(
                          controller: bidController,
                          cursorColor: const Color(0xff4c505b),
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            fillColor: Colors.grey.shade100,
                            filled: true,
                            hintText: 'Bid',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xff4c505b)),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                            child: Container(
                                child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                              onPressed: () {
                                if(bidController.text !=""){
                                  bid = bidController.text;
                                  type = "X1";
                                  io = "ставка";
                                }else {
                                  bid = "0";
                                  io = "null";
                                }
                              },
                              child: const Text(
                                'X1',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            )),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                            child: Container(
                                child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                              onPressed: () {
                                if(bidController.text !=""){
                                  bid = bidController.text;
                                  type = "X2";
                                  io = "ставка";
                                }else {
                                  bid = "0";
                                  io = "null";
                                }
                              },
                              child: const Text(
                                'X2',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            )),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 20, 20, 0),
                            child: Container(
                                child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                              onPressed: () {
                                if(bidController.text !=""){
                                  type = "X5";
                                  bid = bidController.text;
                                  io = "ставка";
                                }else {
                                  bid = "0";
                                  io = "null";
                                }
                              },
                              child: const Text(
                                'X5',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            )),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                            child: Container(
                                child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                              onPressed: () {
                                if(bidController.text !=""){
                                  type = "X10";
                                  bid = bidController.text;
                                  io = "ставка";
                                }else {
                                  bid = "0";
                                  io = "null";
                                }
                              },
                              child: const Text(
                                'X10',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            )),
                          ),
                        ],
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
                              List<String> friend = snapshot.data![4].toString().split("|");
                              if(friend[(2 + index * 3)] == "null"){
                                return const Text("");
                              }else {
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

                      Padding(
                        padding: const EdgeInsets.only(
                          left: 0,
                          top: 20,
                        ),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green),
                                onPressed: () {

                                  Future<void> exit() async {
                                    final ref = FirebaseDatabase.instance.ref();
                                    final User? user = FirebaseAuth.instance.currentUser;
                                    final uid = user?.uid;
                                    FirebaseDatabase database =
                                        FirebaseDatabase.instance;

                                    database.ref("Users/$uid").update({
                                      "CurGame": "",
                                      "Answer": "",
                                      "request": "",
                                    });
                                  }
                                  exit();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const Home()),
                                  );
                                },
                                child: const Text(
                                  'Exit',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 35,
                                  ),
                                )),
                          ),
                        ),
                      ),
                    ]),
            ),
          ),
              );
            }
            else{
              return const Center(child: CircularProgressIndicator());
            }
        }
      ),
    );
  }
}
