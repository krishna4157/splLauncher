import 'dart:async';

import 'package:Smart_Power_Launcher/main.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touchable_opacity/touchable_opacity.dart';
import 'package:battery/battery.dart';

int batteryPercentage = 0;

class Charging extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: MyAnimation(),
      backgroundColor: Colors.black,
    ));
  }
}

// class MyAnimation extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MyClipPath();
//   }
// }

// class MyClipPath extends StatelessWidget{
class MyClipPath extends AnimatedWidget {
  final Animation<double> animation;
  final int batteryPercentage;

  final double height;

  MyClipPath(this.animation, this.height, this.batteryPercentage)
      : super(listenable: animation);
  final Color backgroundColor = Colors.green;
  @override
  Widget build(BuildContext context) {
    void setInitialValue() async {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('prevChargeState', 'charge').then((value) =>
          Navigator.pushReplacement(
              context,
              PageTransition(
                  type: PageTransitionType.fade,
                  duration: Duration(milliseconds: 500),
                  child: CountingApp())));
    }

    return TouchableOpacity(
      onTap: () {
        setInitialValue();
      },
      child: Stack(children: <Widget>[
        Column(
          children: [
            // SizedBox(height: 50),
            // Text(
            //   'Charging',
            //   textAlign: TextAlign.center,
            //   style: TextStyle(fontSize: 30.0),
            // ),
            // Padding(
            //   padding: const EdgeInsets.all(28.0),
            //   child: FlutterLogo(size: 200.0),
            // ),
            Expanded(
              flex: 1,
              child: Stack(children: [
                Positioned(
                  bottom: -130,
                  right: animation.value,
                  child: ClipPath(
                    clipper: BottomWaveClipper(),
                    child: Opacity(
                      opacity: 1,
                      child: AnimatedContainer(
                        duration: Duration(seconds: 2),
                        color: batteryPercentage < 15
                            ? Colors.red
                            : batteryPercentage < 75
                                ? Colors.orange
                                : batteryPercentage == 100
                                    ? Colors.blueAccent
                                    : Colors.green,
                        width: 3000,
                        height: 200,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -130,
                  left: animation.value,
                  child: ClipPath(
                    clipper: BottomWaveClipper(),
                    child: Opacity(
                      opacity: 0.5,
                      child: AnimatedContainer(
                        duration: Duration(seconds: 2),
                        color: batteryPercentage < 15
                            ? Colors.red
                            : batteryPercentage < 75
                                ? Colors.orange
                                : batteryPercentage == 100
                                    ? Colors.blueAccent
                                    : Colors.green,
                        width: 4000,
                        height: 200,
                      ),
                    ),
                  ),
                ),
              ]),
            ),

            Expanded(
                flex: 0,
                child: AnimatedContainer(
                  decoration: new BoxDecoration(
                    border: new Border.all(
                        width: 1,
                        color: Colors
                            .transparent), //color is transparent so that it does not blend with the actual color specified
                    borderRadius:
                        const BorderRadius.all(const Radius.circular(0.0)),
                    color: batteryPercentage < 15
                        ? Colors.red
                        : batteryPercentage < 75
                            ? Colors.orange
                            : batteryPercentage == 100
                                ? Colors.blueAccent
                                : Colors
                                    .green, // Specifies the background color and the opacity
                  ),
                  // color: batteryPercentage < 15
                  //     ? Colors.red
                  //     : batteryPercentage < 75
                  //         ? Colors.orange
                  //         : batteryPercentage == 100
                  //             ? Colors.blueAccent
                  //             : Colors.green,
                  height: (height - 40) * (batteryPercentage / 100),
                  duration: Duration(seconds: 2),
                )),
          ],
        ),
        Center(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$batteryPercentage',
                    style: TextStyle(
                      color: Colors.white,
                      // fontWeight: FontWeight.normal,
                      fontSize: 120,
                    )),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
                  child: Text('%',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 50,
                          fontFamily: 'Quicksand-Light')),
                )
              ],
            ),
            Icon(
              Icons.flash_on_outlined,
              color: Colors.yellow,
              size: 30,
            ),
            Padding(
                padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
                child: Text('tap to dismiss',
                    style: TextStyle(color: Colors.white, fontSize: 15.0)))
          ],
        ))
      ]),
    );
  }
}

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = new Path();

    path.lineTo(0.0, 40.0);
    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 40.0);

    for (int i = 0; i < 10; i++) {
      if (i % 2 == 0) {
        path.quadraticBezierTo(
            size.width - (size.width / 16) - (i * size.width / 8),
            0.0,
            size.width - ((i + 1) * size.width / 8),
            size.height - 160);
      } else {
        path.quadraticBezierTo(
            size.width - (size.width / 16) - (i * size.width / 8),
            size.height - 120,
            size.width - ((i + 1) * size.width / 8),
            size.height - 160);
      }
    }

    path.lineTo(0.0, 40.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class MyAnimation extends StatefulWidget {
  @override
  _MyAnimationState createState() => _MyAnimationState();
}

class _MyAnimationState extends State<MyAnimation>
    with SingleTickerProviderStateMixin {
  final Battery _battery = new Battery();
  StreamSubscription<BatteryState> _batteryStateSubscription;
  Animation<double> animation;

  AnimationController _controller;
  @override
  void initState() {
    super.initState();
    setupState();
    // Future.delayed(Duration(seconds: 2), () {
    //   setStateIfMounted(() {
    //     batteryPercentage = batteryPercentage;
    //   });
    // });
    _controller =
        AnimationController(duration: Duration(seconds: 10), vsync: this)
          ..repeat();
    animation = Tween<double>(begin: -1260, end: 0).animate(_controller);
    _batteryStateSubscription =
        _battery.onBatteryStateChanged.listen((BatteryState state) {
      if (state == BatteryState.charging) {
        // setStateIfMounted(() {
        //   batteryPercentage = batteryPercentage;
        // });
        setupState().then((value) => setStateIfMounted(() {
              batteryPercentage = batteryPercentage;
            }));
      }
      // else {
      //   // resetChargeValue();
      // }
      // return state;
    });
  }

  resetChargeValue() async {
    final prefs = await SharedPreferences.getInstance();
    // var showChargeAtFirstTime = prefs.getInt('startCount');
    // prefs.setInt('startCount', 0);
    prefs.setString('prevChargeState', 'charge').then((value) =>
        Navigator.pushReplacement(
            context,
            PageTransition(
                type: PageTransitionType.fade,
                duration: Duration(milliseconds: 500),
                child: CountingApp())));
    // Navigator.pushReplacement(
    //     context,
    //     PageTransition(
    //         type: PageTransitionType.fade,
    //         duration: Duration(milliseconds: 500),
    //         child: CountingApp()));
    // });
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  Future setupState() async {
    var setupResult = await _battery.batteryLevel;
    // setStateIfMounted(() {
    batteryPercentage = setupResult;
    // });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    if (_batteryStateSubscription != null) {
      _batteryStateSubscription.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    return MyClipPath(animation, height, batteryPercentage);
  }
}
