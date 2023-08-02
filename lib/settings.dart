import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:koleso_fortune/Login.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import 'package:url_launcher/url_launcher.dart';

class settings extends StatefulWidget {
  const settings({Key? key}) : super(key: key);

  @override
  _settingsState createState() => _settingsState();
}

class _settingsState extends State<settings> {
  StreamController<int> controller = StreamController<int>();

  Future<int> GetADTanks() async {
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    final lvl = int.parse(
        (await ref.child('Users/$uid/Points').get()).value.toString());
    return lvl;
  }

  final controllerConfet = ConfettiController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  GlobalKey scaffoldKey = GlobalKey();
  bool light = true;

  Future<void> _launchUrl() async {
    const url =
        'https://doc-hosting.flycricket.io/desert-steel-privacy-policy/5869bbdd-f778-47d4-ad63-6415c407c7aa/privacy';
    final _url = Uri.parse(url);
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  void deleteAccount() {
    //TODO: Delete account from firebase
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    user?.delete().then((value) => ref.child('Users/$uid').remove().then((value) => logout()));

  }

  void changeName(String name) {
    final ref = FirebaseDatabase.instance.ref();
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    ref.child('Users/$uid/Name').set(name);
  }

  void logout() {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context,
    MaterialPageRoute(builder: (context) => const Login()));
  }

  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: scaffoldKey,
      backgroundColor: const Color(0xffE0E3E7),
      body: FutureBuilder(
          future: Future.wait([
            GetADTanks(),
          ]),
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
                    SizedBox(
                      height: height * 0.06,
                    ),
                    Text(
                      "Settings",
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
                      )),
                    ),
                    SizedBox(
                      height: height * 0.06,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: width * 0.7,
                            child: TextField(
                              controller: nameController,
                              maxLength: 8,
                              decoration: InputDecoration(
                                fillColor: Colors.grey.shade100,
                                filled: true,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xff4c505b)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xff4c505b)),
                                ),
                                hintText: 'New nickname',
                                hintStyle:
                                    const TextStyle(color: Color(0xff4c505b)),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 20.0, left: 10.0),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: const Color(0xff4c505b),
                              child: IconButton(
                                color: Colors.white,
                                onPressed: () {
                                  if (nameController.text.isNotEmpty) {
                                    changeName(nameController.text);
                                  }
                                },
                                icon: const Icon(Icons.arrow_forward),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    SizedBox(
                      height: height * 0.06,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Row(
                        children: [
                          Text("Sound effects",
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
                                fontSize: 18,
                              ))),
                          SizedBox(
                            width: width * 0.1,
                          ),
                          ValueListenableBuilder(
                            valueListenable: Hive.box('Settings').listenable(),
                            builder: (context, box, widget) {
                              if (box.get('sound') == null) {
                                box.put('sound', true);
                              }
                              return RoundCheckBox(
                                isChecked: box.get('sound'),
                                isRound: true,
                                border: Border.all(color: Colors.black),
                                size: 45,
                                uncheckedColor: Colors.grey,
                                checkedColor: Colors.white,
                                checkedWidget: const Icon(
                                  Icons.music_note_sharp,
                                  color: Colors.black,
                                ),
                                uncheckedWidget: const Icon(
                                  Icons.music_off_sharp,
                                  color: Colors.white,
                                ),
                                onTap: (selected) {
                                  box.put('sound', selected);
                                  //(box.get('sound'));
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: height * 0.06,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Row(
                        children: [
                          Text("Joystick mode",
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
                                fontSize: 18,
                              ))),
                          SizedBox(
                            width: width * 0.1,
                          ),
                          ValueListenableBuilder(
                            valueListenable: Hive.box('Settings').listenable(),
                            builder: (context, box, widget) {
                              if (box.get('joystick') == null) {
                                box.put('joystick', true);
                              }
                              return RoundCheckBox(
                                isChecked: box.get('joystick'),
                                isRound: true,
                                border: Border.all(color: Colors.black),
                                size: 45,
                                uncheckedColor: Colors.grey,
                                checkedColor: Colors.white,
                                checkedWidget: const Icon(
                                  Icons.lock_open,
                                  color: Colors.black,
                                ),
                                uncheckedWidget: const Icon(
                                  Icons.lock,
                                  color: Colors.white,
                                ),
                                onTap: (selec) {
                                  box.put('joystick', selec);
                                  //(box.get('joystick'));
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        height: height * 0.42,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueGrey[900],
                                      //add radius to button
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    onPressed: () {
                                      deleteAccount();
                                    },
                                    child: Text("Delete account",
                                        style: GoogleFonts.pressStart2p(
                                            textStyle: const TextStyle(
                                          wordSpacing: 0,
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
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueGrey[900],
                                      //add radius to button
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    onPressed: () {
                                      logout();
                                    },
                                    child: Text("Log out",
                                        style: GoogleFonts.pressStart2p(
                                            textStyle: const TextStyle(
                                          wordSpacing: 0,
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
                                ]),
                            SizedBox(
                              height: height * 0.03,
                            ),
                            GestureDetector(
                              onTap: () {
                                _launchUrl();
                              },
                              child: Text("Privacy policy",
                                  style: GoogleFonts.pressStart2p(
                                      textStyle: const TextStyle(
                                    decoration: TextDecoration.underline,
                                    wordSpacing: 0,
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
                          image: AssetImage("assets/images/background.png"),
                          fit: BoxFit.fill),
                    ),
                    child: const Center(child: CircularProgressIndicator())),
              );
            }
          }),
    );
  }
}
