import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:koleso_fortune/GameTanks.dart';
import 'package:koleso_fortune/Home.dart';
import 'Login.dart';
import 'Register.dart';
import 'firebase_options.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'main',
      // theme: ThemeData(
      //   fontFamily: 'FiraSans',
      // ),
      routes: {
        'main': (context) => const mainPage(),
        'login': (context) => const Login(),
        'register': (context) => const Register(),
        'home': (context) => const Home(),

      },
    ),
  );

}

class mainPage extends StatelessWidget{
  const mainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
    body:
    StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData){
            //FlutterNativeSplash.remove();
            return const Home();

          }else{
            //FlutterNativeSplash.remove();
            return const Login();
          }

        }
    ),
  );
}