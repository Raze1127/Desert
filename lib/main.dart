import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:koleso_fortune/GameTanks.dart';
import 'package:koleso_fortune/Home.dart';
import 'Login.dart';
import 'Register.dart';
import 'firebase_options.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  print('background message ${message.notification!.body}');
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_messageHandler);


  //password for site r8Y.q3T%v2
  //password for admin@desertsteel.online j2F)x0E^g4


    Future<InitializationStatus> _initGoogleMobileAds() {
      // TODO: Initialize Google Mobile Ads SDK
      return MobileAds.instance.initialize();
    }
    await _initGoogleMobileAds();
    runApp(
      MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.black,
          accentColor: Colors.black,
        ),
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

class mainPage extends StatelessWidget {
  const mainPage({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);


    return Scaffold(
      body: StreamBuilder<User?>(


          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {

            if (snapshot.hasData) {
              //FlutterNativeSplash.remove();
              return const Home();
            } else {
              //FlutterNativeSplash.remove();
              return const Login();
            }
          }
      ),
    );
  }
}