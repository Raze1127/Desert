import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import "package:firebase_database/firebase_database.dart";
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nanoid/nanoid.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register>{

  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  FirebaseDatabase database = FirebaseDatabase.instance;

  Future LogIn() async{
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim()
    );
      String code = nanoid(5);
      final User? user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid;


      database.ref("Users/$uid").update({
        'SelectedSkin': '1',
        "code": code,
        "Name": nameController.text.trim(),
        "uid": uid,
        "photo": "https://upload.wikimedia.org/wikipedia/commons/9/9a/%D0%9D%D0%B5%D1%82_%D1%84%D0%BE%D1%82%D0%BE.png",
        "Points": 0
      }
      ).then((value) => database.ref("Users/$uid/friends").update({
        "friendsUID": "null",
      }
      ).then((value) => database.ref("Users/$uid").update({
        "kills": 0,
        "deaths": 0,
      }
      ).then((value) => Navigator.pushNamed(context, 'home')) ));




  }


  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.fill),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(
            color: Color(0xff4c505b), //change your color here
          ),
        ),
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Center(
                  child: Container(
                    width: 300,
                    padding: EdgeInsets.only(

                        top: MediaQuery.of(context).size.height * 0.1),

                    child: Column(children: [
                       Text(
                        "Sign Up",
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
                              fontSize: 34,
                            )),
                      ),
                      const SizedBox(
                        height: 100,
                      ),
                      TextField(
                        controller: nameController,
                        maxLength: 8,

                        decoration: InputDecoration(
                          fillColor: Colors.grey.shade100,
                          filled: true,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xff4c505b)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xff4c505b)),
                          ),
                          hintText: 'Nickname',
                          hintStyle: const TextStyle(color: Color(0xff4c505b)),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          fillColor: Colors.grey.shade100,
                          filled: true,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xff4c505b)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xff4c505b)),
                          ),
                          hintText: 'Email',

                          hintStyle: const TextStyle(color: Color(0xff4c505b)),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          fillColor: Colors.grey.shade100,
                          filled: true,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xff4c505b)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xff4c505b)),
                          ),
                          hintText: 'Password',
                          hintStyle: const TextStyle(color: Color(0xff4c505b)),
                        ),
                      ),

                      const SizedBox(
                        height: 65,
                      ),

                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             Text(
                              'Sign in',
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
                            ),
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: const Color(0xff4c505b),
                              child: IconButton(
                                color: Colors.white,
                                onPressed: () {
                                  if(emailController.text.trim() != "" && passwordController.text.trim() != "" && nameController.text.trim() != "" ) {
                                    LogIn();

                                  }
                                },
                                icon: const Icon(Icons.arrow_forward),
                              ),
                            ),
                          ]),

                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, 'login');
                              },
                              child: const Text(
                                '',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontSize: 18,
                                  color: Color(0xff4c505b),
                                ),
                              ),
                            ),
                          ]),

                    ]),
                  )),
        ),
      ),
    );

  }

}

































