import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CountdownTimer extends StatefulWidget {
  final int seconds;
  final Function onTimerFinish;
  final double fontSize;

  CountdownTimer({ required this.seconds, required this.onTimerFinish, required this.fontSize, Key? key }) : super(key: key);

  @override
  _CountdownTimerState createState() => _CountdownTimerState();

  final GlobalKey<_CountdownTimerState> _key = GlobalKey();

  void restartTimer() {
    print("ДАРОВА БАНДИТЫ");

    _key.currentState!.restartTimer();
  }
}

class _CountdownTimerState extends State<CountdownTimer> {
  late int _secondsLeft;
  late Timer _timer;
  static late _CountdownTimerState _countdownTimerState;

  @override
  void initState() {
    super.initState();
    _countdownTimerState = this;
    _secondsLeft = widget.seconds;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsLeft--;
      });

      if (_secondsLeft == 0) {
        _timer.cancel();
        widget.onTimerFinish();
      }
    });
  }

  void restartTimer() {
    print("ДАРОВА БАНДИТЫ");
    _timer.cancel();
    _secondsLeft = widget.seconds;
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: GoogleFonts.pressStart2p(
        textStyle: const TextStyle(
          shadows: [
            Shadow(
              offset: Offset(-1.5, -1.5),
              color: Colors.black,
            ),
            Shadow(
              offset: Offset(1.5, -1.5),
              color: Colors.black,
            ),
            Shadow(
              offset: Offset(1.5, 1.5),
              color: Colors.black,
            ),
            Shadow(
              offset: Offset(-1.5, 1.5),
              color: Colors.black,
            ),
          ],
          color: Colors.white,
          fontSize: 10,
        ),
      ),
      child: Text(_secondsLeft > 0 ? "$_secondsLeft" : ""),
    );
  }
}




