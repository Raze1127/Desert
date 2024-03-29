import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';

import 'ad_helper.dart';

class inventory extends StatefulWidget {
  const inventory({Key? key}) : super(key: key);

  @override
  _inventoryState createState() => _inventoryState();
}

class _inventoryState extends State<inventory> {
  StreamController<int> controller = StreamController<int>();

  Future<int> GetADTanks() async {
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    final lvl = int.parse(
        (await ref.child('Users/$uid/Points').get()).value.toString());
    return lvl;
  }

  Future<int> XPe() async {
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    final kills =
        int.parse((await ref.child('Users/$uid/kills').get()).value.toString());
    final deaths = int.parse(
        (await ref.child('Users/$uid/deaths').get()).value.toString());
    var Prize =
        (await ref.child('Users/$uid/wonPrizesXP').get()).value.toString();
    var PrizeXP = 0;
    if (Prize == "null") {
      PrizeXP = 0;
    } else {
      PrizeXP = int.parse(Prize);
    }
    var xp = (kills * 80 - deaths * 30) + PrizeXP;

    return xp;
  }

  Future<int> prizeXP() async {
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    var Prize =
        (await ref.child('Users/$uid/wonPrizesXP').get()).value.toString();
    var PrizeXP = 0;
    if (Prize == "null") {
      PrizeXP = 0;
    } else {
      PrizeXP = int.parse(Prize);
    }
    return PrizeXP;
  }

  Future<int> skinSelected() async {
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    final skin =
        (await ref.child('Users/$uid/SelectedSkin').get()).value.toString();

    if (skin == "null") {
      return 0;
    } else {
      return int.parse(skin);
    }
  }

  Future<int> rocket() async {
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    final abil =
    (await ref.child('Users/$uid/rocket').get()).value.toString();

    if (abil == "null") {
      return 0;
    } else {
      return int.parse(abil);
    }
  }

  Future<int> shield() async {
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    final abil =
    (await ref.child('Users/$uid/shield').get()).value.toString();

    if (abil == "null") {
      return 0;
    } else {
      return int.parse(abil);
    }
  }

  Future<int> aid() async {
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    final abil =
    (await ref.child('Users/$uid/aid').get()).value.toString();

    if (abil == "null") {
      return 0;
    } else {
      return int.parse(abil);
    }
  }

  Future<String> wonPrizes() async {
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    final skin =
        (await ref.child('Users/$uid/wonPrizes').get()).value.toString();
    if (skin == "null") {
      return "";
    } else {
      return skin;
    }
  }

  Widget invent(int id, int i, int selected, String prize) {
    var lvl = i;
    var iconSelect = Icons.done_outline;
    var priz = prize;
    if (selected == id) {
      iconSelect = Icons.done;
    }
    if (id == 4) {
      //(prize);
      if (priz == "") {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock,
              size: 25,
              color: Colors.white70,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text("Spin to unlock",
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
                      fontSize: 8,
                    ))),
              ),
            ),
          ],
        );
      } else {
        return GestureDetector(
          onTap: () {
            final ref = FirebaseDatabase.instance.ref();
            final User? user = FirebaseAuth.instance.currentUser;
            final uid = user?.uid;
            ref.child('Users/$uid/SelectedSkin').set(4);
            setState(() {
              iconSelect = Icons.done;
            });
          },
          child: Icon(
            iconSelect,
            size: 30,
            color: Colors.white70,
          ),
        );
      }
    } else {
      if (id == 0) {
        return GestureDetector(
          onTap: () {
            final ref = FirebaseDatabase.instance.ref();
            final User? user = FirebaseAuth.instance.currentUser;
            final uid = user?.uid;
            ref.child('Users/$uid/SelectedSkin').set(id);
            setState(() {
              iconSelect = Icons.done;
            });
          },
          child: Icon(
            iconSelect,
            size: 30,
            color: Colors.white70,
          ),
        );
      } else {
        if (id * 5 <= lvl) {
          return GestureDetector(
            onTap: () {
              final ref = FirebaseDatabase.instance.ref();
              final User? user = FirebaseAuth.instance.currentUser;
              final uid = user?.uid;
              ref.child('Users/$uid/SelectedSkin').set(id);
              setState(() {
                iconSelect = Icons.done;
              });
            },
            child: Icon(
              iconSelect,
              size: 30,
              color: Colors.white70,
            ),
          );
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock,
                size: 25,
                color: Colors.white70,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("${id * 5} lvl ",
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
            ],
          );
        }
      }
    }
  }

  final scaffoldKey = GlobalKey<ScaffoldState>();

  RewardedAd? _rewardedAd;

  // TODO: Implement _loadRewardedAd()
  void _loadRewardedAd(lol) {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              setState(() {
                ad.dispose();
                _rewardedAd = null;
                setState(() async {
                  if (lol == 0) {
                    var prize = Random().nextInt(9);
                    var prizes = await wonPrizes();

                    if (prize == 0) {
                      final ref = FirebaseDatabase.instance.ref();
                      final User? user = FirebaseAuth.instance.currentUser;
                      final uid = user?.uid;
                      if (prizes == "") {
                        ref.child('Users/$uid/wonPrizes').set("5");
                      } else {
                        ref.child('Users/$uid/wonPrizes').set("$prizes//5");
                      }
                    }
                    if (prize == 1) {
                      final ref = FirebaseDatabase.instance.ref();
                      final User? user = FirebaseAuth.instance.currentUser;
                      final uid = user?.uid;
                      ref
                          .child('Users/$uid/wonPrizesXP')
                          .set((await prizeXP()) + 225);
                    }
                    if (prize == 2) {
                      final ref = FirebaseDatabase.instance.ref();
                      final User? user = FirebaseAuth.instance.currentUser;
                      final uid = user?.uid;
                      ref
                          .child('Users/$uid/wonPrizesXP')
                          .set((await prizeXP()) + 75);
                    }
                    if (prize == 3) {
                      final ref = FirebaseDatabase.instance.ref();
                      final User? user = FirebaseAuth.instance.currentUser;
                      final uid = user?.uid;
                      ref
                          .child('Users/$uid/wonPrizesXP')
                          .set((await prizeXP()) + 450);
                    }
                    if (prize == 4) {
                      final ref = FirebaseDatabase.instance.ref();
                      final User? user = FirebaseAuth.instance.currentUser;
                      final uid = user?.uid;
                      ref
                          .child('Users/$uid/wonPrizesXP')
                          .set((await prizeXP()) + 350);
                    }
                    if (prize == 5) {
                      final ref = FirebaseDatabase.instance.ref();
                      final User? user = FirebaseAuth.instance.currentUser;
                      final uid = user?.uid;
                      ref
                          .child('Users/$uid/wonPrizesXP')
                          .set((await prizeXP()) + 250);
                    }
                    if (prize == 6) {
                      final ref = FirebaseDatabase.instance.ref();
                      final User? user = FirebaseAuth.instance.currentUser;
                      final uid = user?.uid;
                      ref
                          .child('Users/$uid/wonPrizesXP')
                          .set((await prizeXP()) + 200);
                    }
                    if (prize == 7) {
                      final ref = FirebaseDatabase.instance.ref();
                      final User? user = FirebaseAuth.instance.currentUser;
                      final uid = user?.uid;
                      ref
                          .child('Users/$uid/wonPrizesXP')
                          .set((await prizeXP()) + 50);
                    }
                    if (prize == 8) {
                      final ref = FirebaseDatabase.instance.ref();
                      final User? user = FirebaseAuth.instance.currentUser;
                      final uid = user?.uid;
                      ref
                          .child('Users/$uid/wonPrizesXP')
                          .set((await prizeXP()) + 300);
                    }
                    if (prize == 9) {
                      final ref = FirebaseDatabase.instance.ref();
                      final User? user = FirebaseAuth.instance.currentUser;
                      final uid = user?.uid;
                      ref
                          .child('Users/$uid/wonPrizesXP')
                          .set((await prizeXP()) + 100);
                    }

                    //(prize);
                    controller.add(prize);
                  }
                  if (lol == 1) {
                    final ref = FirebaseDatabase.instance.ref();
                    final User? user = FirebaseAuth.instance.currentUser;
                    final uid = user?.uid;
                    ref.child('Users/$uid/shield').set(1);

                  }
                  if (lol == 2) {
                    final ref = FirebaseDatabase.instance.ref();
                    final User? user = FirebaseAuth.instance.currentUser;
                    final uid = user?.uid;
                    ref.child('Users/$uid/aid').set(1);

                  }
                  if (lol == 3) {
                    final ref = FirebaseDatabase.instance.ref();
                    final User? user = FirebaseAuth.instance.currentUser;
                    final uid = user?.uid;
                    ref.child('Users/$uid/rocket').set(1);

                  }
                  Future.delayed(const Duration(seconds: 4), () {
                    controllerConfet.play();
                  });
                  Future.delayed(const Duration(seconds: 7), () {
                    controllerConfet.stop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const inventory(),
                      ),
                    );
                  });
                });
              });
              //_loadRewardedAd();
            },
          );

          setState(() {
            _rewardedAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          //('Failed to load a rewarded ad: ${err.message}');
        },
      ),
    );
  }



  final controllerConfet = ConfettiController();
  int shieldCount = 0;
  int healthCount = 0;
  int rocketCount = 0;

  @override
  void initState() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      _loadRewardedAd(0);

    }
    super.initState();
  }

  @override
  void dispose() {
    controllerConfet.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Stack(
      alignment: Alignment.center,
      children: [
        Scaffold(
            key: scaffoldKey,
            backgroundColor: const Color(0xffE0E3E7),
            body: FutureBuilder(
                future:
                    Future.wait([GetADTanks(), skinSelected(), wonPrizes(), aid(), shield(), rocket()]),
                builder: (BuildContext context, snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                      height: double.infinity,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/images/background.png"),
                            fit: BoxFit.fill),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 50),
                            child: Center(
                              child: FortuneBar(
                                height: 120,
                                animateFirst: false,
                                selected: controller.stream,
                                items: [
                                  FortuneItem(
                                    style: const FortuneItemStyle(
                                      color: Colors.red,
                                      // <-- custom circle slice fill color
                                      borderColor: Colors.green,
                                      // <-- custom circle slice stroke color
                                      borderWidth:
                                          3, // <-- custom circle slice stroke width
                                    ),
                                    child: Image.asset(
                                      'assets/images/player/5tank.png',
                                      height: 80,
                                      width: 80,
                                    ),
                                  ),
                                  FortuneItem(
                                      style: const FortuneItemStyle(
                                        color: Color(0xFF6699CC),
                                        borderColor: Colors.black,
                                      ),
                                      child: Center(
                                          child: Text("225 xp",
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
                                                fontSize: 10,
                                              ))))),
                                  FortuneItem(
                                      style: const FortuneItemStyle(
                                        color: Color(0xFF6699CC),
                                        borderColor: Colors.black,
                                      ),
                                      child: Center(
                                          child: Text("75 xp",
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
                                                fontSize: 10,
                                              ))))),
                                  FortuneItem(
                                      style: const FortuneItemStyle(
                                        color: Color(0xFF6699CC),
                                        borderColor: Colors.black,
                                      ),
                                      child: Center(
                                          child: Text("450 xp",
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
                                                fontSize: 10,
                                              ))))),
                                  FortuneItem(
                                      style: const FortuneItemStyle(
                                        color: Color(0xFF6699CC),
                                        borderColor: Colors.black,
                                      ),
                                      child: Center(
                                          child: Text("350 xp",
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
                                                fontSize: 10,
                                              ))))),
                                  FortuneItem(
                                      style: const FortuneItemStyle(
                                        color: Color(0xFF6699CC),
                                        borderColor: Colors.black,
                                      ),
                                      child: Center(
                                          child: Text("250 xp",
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
                                                fontSize: 10,
                                              ))))),
                                  FortuneItem(
                                      style: const FortuneItemStyle(
                                        color: Color(0xFF6699CC),
                                        borderColor: Colors.black,
                                      ),
                                      child: Center(
                                          child: Text("200 xp",
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
                                                fontSize: 10,
                                              ))))),
                                  FortuneItem(
                                      style: const FortuneItemStyle(
                                        color: Color(0xFF6699CC),
                                        borderColor: Colors.black,
                                      ),
                                      child: Center(
                                          child: Text("50 xp",
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
                                                fontSize: 10,
                                              ))))),
                                  FortuneItem(
                                      style: const FortuneItemStyle(
                                        color: Color(0xFF6699CC),
                                        borderColor: Colors.black,
                                      ),
                                      child: Center(
                                          child: Text("300 xp",
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
                                                fontSize: 10,
                                              ))))),
                                  FortuneItem(
                                      style: const FortuneItemStyle(
                                        color: Color(0xFF6699CC),
                                        borderColor: Colors.black,
                                      ),
                                      child: Center(
                                          child: Text("100 xp",
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
                                                fontSize: 10,
                                              ))))),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey[900],
                                //add radius to button
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {
                                if (defaultTargetPlatform ==
                                    TargetPlatform.android) {
                                  _loadRewardedAd(0);
                                  _rewardedAd?.show(
                                      onUserEarnedReward: (AdWithoutView ad,
                                          RewardItem rewardItem) {});
                                }
                              },
                              child: Text("Watch ad to get a spin!",
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
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 30, left: 20, right: 20),
                            child: SizedBox(
                              width: width * 0.9,
                              height: height * 0.32,
                              child: GridView.count(
                                crossAxisCount: 2,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 15,
                                children: [
                                  Container(
                                    height: 30, // высота контейнера
                                    width: 30, // ширина контейнера
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: const Offset(0,
                                              3), // changes position of shadow
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(20),
                                      image: const DecorationImage(
                                          image: AssetImage(
                                              "assets/images/backk.png"),
                                          fit: BoxFit.fill),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 25.0),
                                          child: Center(
                                              child: Image.asset(
                                                  'assets/images/player/1tank.png')),
                                        ),
                                        invent(
                                            0,
                                            int.parse(
                                                (snapshot.data![0]).toString()),
                                            int.parse(
                                                (snapshot.data![1]).toString()),
                                            (snapshot.data![2]).toString()),
                                      ],
                                    ),
                                  ),

                                  //SECOND TANK
                                  Container(
                                      height: 30, // высота контейнера
                                      width: 30, // ширина контейнера
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: const Offset(0,
                                                3), // changes position of shadow
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(20),
                                        image: const DecorationImage(
                                            image: AssetImage(
                                                "assets/images/backk.png"),
                                            fit: BoxFit.fill),
                                      ),
                                      child: Stack(
                                        children: [
                                          Center(
                                              child: Image.asset(
                                                  'assets/images/player/2tank.png')),
                                          Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 2.0),
                                                  child: invent(
                                                      1,
                                                      int.parse(
                                                          (snapshot.data![0])
                                                              .toString()),
                                                      int.parse(
                                                          (snapshot.data![1])
                                                              .toString()),
                                                      (snapshot.data![2])
                                                          .toString()),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),

                                  //THIRD TANK
                                  Container(
                                      height: 30, // высота контейнера
                                      width: 30, // ширина контейнера
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: const Offset(0,
                                                3), // changes position of shadow
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(20),
                                        image: const DecorationImage(
                                            image: AssetImage(
                                                "assets/images/backk.png"),
                                            fit: BoxFit.fill),
                                      ),
                                      child: Stack(
                                        children: [
                                          Center(
                                              child: Image.asset(
                                                  'assets/images/player/3tank.png')),
                                          Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 2.0),
                                                  child: invent(
                                                      2,
                                                      int.parse(
                                                          (snapshot.data![0])
                                                              .toString()),
                                                      int.parse(
                                                          (snapshot.data![1])
                                                              .toString()),
                                                      (snapshot.data![2])
                                                          .toString()),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),
                                  Container(
                                      height: 30, // высота контейнера
                                      width: 30, // ширина контейнера
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: const Offset(0,
                                                3), // changes position of shadow
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(20),
                                        image: const DecorationImage(
                                            image: AssetImage(
                                                "assets/images/backk.png"),
                                            fit: BoxFit.fill),
                                      ),
                                      child: Stack(
                                        children: [
                                          Center(
                                              child: Image.asset(
                                                  'assets/images/player/4tank.png')),
                                          Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 2.0),
                                                  child: invent(
                                                      3,
                                                      int.parse(
                                                          (snapshot.data![0])
                                                              .toString()),
                                                      int.parse(
                                                          (snapshot.data![1])
                                                              .toString()),
                                                      (snapshot.data![2])
                                                          .toString()),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),
                                  //FORTH TANK
                                  Container(
                                      height: 30, // высота контейнера
                                      width: 30, // ширина контейнера
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 5,
                                            blurRadius: 4,
                                            offset: const Offset(0,
                                                3), // changes position of shadow
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(20),
                                        image: const DecorationImage(
                                            image: AssetImage(
                                                "assets/images/backk.png"),
                                            fit: BoxFit.fill),
                                      ),
                                      child: Stack(
                                        children: [
                                          Center(
                                              child: Image.asset(
                                                  'assets/images/player/5tank.png')),
                                          Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 2.0),
                                                  child: invent(
                                                      4,
                                                      int.parse(
                                                          (snapshot.data![0])
                                                              .toString()),
                                                      int.parse(
                                                          (snapshot.data![1])
                                                              .toString()),
                                                      (snapshot.data![2])
                                                          .toString()),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            child: Text("Abilities:",
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
                          Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Image.asset(
                                          'assets/images/abilities/Shield.png',
                                          height: 100,
                                          width: 100,
                                        ),

                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blueGrey[900],
                                            //add radius to button
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10)),
                                          ),
                                          onPressed: () {
                                            if (defaultTargetPlatform ==
                                                TargetPlatform.android) {
                                              _loadRewardedAd(1);
                                              _rewardedAd?.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {  });
                                            }
                                          },
                                          child: Text('${snapshot.data![4]}/1',
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
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Image.asset(
                                          'assets/images/abilities/aptechka.png',
                                          height: 100,
                                          width: 100,
                                        ),

                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blueGrey[900],
                                            //add radius to button
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10)),
                                          ),
                                          onPressed: () {
                                            if (defaultTargetPlatform ==
                                                TargetPlatform.android) {
                                              _loadRewardedAd(2);
                                              _rewardedAd?.show(
                                                  onUserEarnedReward: (AdWithoutView ad,
                                                      RewardItem rewardItem) {});
                                            }
                                          },
                                          child: Text('${snapshot.data![3]}/1',
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
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Image.asset(
                                          'assets/images/abilities/rocket.png',
                                          height: 100,
                                          width: 100,),

                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.blueGrey[900],
                                            //add radius to button
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                          onPressed: () {
                                            if (defaultTargetPlatform ==
                                                TargetPlatform.android) {
                                              _loadRewardedAd(3);
                                              _rewardedAd?.show(
                                                  onUserEarnedReward: (AdWithoutView ad,
                                                      RewardItem rewardItem) {});
                                            }

                                          },
                                          child: Text('${snapshot.data![5]}/1',
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
                                                fontSize: 10,
                                              ))),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Center(
                      child: Container(
                          height: double.infinity,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                                image:
                                    AssetImage("assets/images/background.png"),
                                fit: BoxFit.fill),
                          ),
                          child:
                              const Center(child: CircularProgressIndicator())),
                    );
                  }
                })),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ConfettiWidget(
                confettiController: controllerConfet,
                shouldLoop: false,
                blastDirectionality: BlastDirectionality.explosive,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
