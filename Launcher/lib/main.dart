import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:Smart_Power_Launcher/Charging.dart';
import 'package:battery/battery.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touchable_opacity/touchable_opacity.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:focus_detector/focus_detector.dart';
import 'alphabetListView.dart';

// import 'package:hardware_buttons/hardware_buttons.dart';
var charging = false;
var isNotPresent = false;
var isVisible = false;
var batteryPercentage;
var batterySaverMode = 'off';
var switchState = 'on';
StreamSubscription _volumeButtonSubscription;
var onChangeIcon = false;
var i = 0;
List strList = [];
void main() {
  // GestureBinding.instance.resamplingEnabled = true;
  runApp(Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
      },
      child: MaterialApp(home: CountingApp(), // becomes the route named '/'
          routes: <String, WidgetBuilder>{
            '/appsDrawer': (BuildContext context) => AppsDrawer(),
            '/charging': (BuildContext context) => Charging(),
          })));
}

_launchCaller(val) async {
  var url = "tel:$val";
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

_textMe() async {
  // Android
  // const uri = 'sms:+39 348 060 888?body=hello%20there';
  const uri = 'sms:';

  if (await canLaunch(uri)) {
    await launch(uri);
  } else {
    // iOS
    const uri = 'sms:';
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }
}

class CountingApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'SPL Launcher',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: StartPage(title: 'SPL Launcher'));
  }
}

class StartPage extends StatefulWidget {
  StartPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage>
    with SingleTickerProviderStateMixin {
  int _counter = 0;
  Animation<double> animation;
  AnimationController controller;
  Animation<double> animation2;

  void _submit({int counter}) {
    setStateIfMounted(() {
      animcolor = Colors.black;
    });
    _navigateToNewPage(counter);
  }

  void _navigateToNewPage(counter) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AppsDrawer()));
    // PageTransition(
    //     type: PageTransitionType.bottomToTop,
    //     duration: Duration(microseconds: 10),
    //     child: MainApp()));
  }

  startTimer() async {
    timer = Timer.periodic(
        Duration(seconds: 10), (Timer t) => checkInstalledApps());
  }

  void setPrevChargeState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('prevChargeState', 'disCharge');
  }

  checkBatterylevel() async {
    final prefs = await SharedPreferences.getInstance();
    final Battery _battery = new Battery();
    var batteryLevel = await _battery.batteryLevel;
    prefs.setInt('BatteryLevel', batteryLevel);
    var batterySaverMode = prefs.getString('BatterySaverMode');

    setStateIfMounted(() {
      batteryPercentage = batteryLevel;
      batterySaverMode = batterySaverMode;
    });
  }

  setBatterySavorMode() async {
    final prefs = await SharedPreferences.getInstance();
    var prevbatterySaverMode = prefs.getString('BatterySaverMode');
    if (prevbatterySaverMode == null || prevbatterySaverMode == 'off') {
      await prefs.setString('BatterySaverMode', 'on');
      switchState = 'off';
    } else {
      await prefs.setString('BatterySaverMode', 'off');
      switchState = 'on';
    }
    batterySaverMode = await batterySaverMode;
    setStateIfMounted(() {
      batterySaverMode = batterySaverMode;
      switchState = switchState;
    });
  }

  StreamSubscription<BatteryState> _batteryStateSubscription;
  var _battery = new Battery();
  Timer timer;
  int counter = 0;
  var animcolor = Colors.black;
  String formattedDate = '';
  String isAmPm = '';

  @override
  void initState() {
    super.initState();
    checkInstalledApps();
    checkBatterylevel();
    // changeColor();
    // startTimer();
    Timer.periodic(Duration(seconds: 1), (timer) {
      setTime();
    });
    // checkInstalledApps();
    setState(() {
      onChangeIcon = false;
    });

    _batteryStateSubscription =
        _battery.onBatteryStateChanged.listen((BatteryState state) {
      if (state == BatteryState.charging) {
        setState(() {
          charging = true;
        });
      } else {
        setToDefault();
      }
    });
    controller =
        AnimationController(duration: const Duration(seconds: 7), vsync: this);
    animation = Tween<double>(begin: 0, end: 400).animate(controller);
    animation2 = Tween<double>(begin: 0, end: 300).animate(controller)
      ..addListener(() {
        // #enddocregion addListener
        setState(() {
          // The state that has changed here is the animation object’s value.
        });
        // #docregion addListener
      });
    // #enddocregion addListener
    controller.forward();
  }

  changeColor() {
    Future.delayed(Duration(seconds: 1), () {
      var colorsList = [
        Colors.red,
        Colors.green,
        Colors.blue,
        Colors.orange,
        Colors.purple
      ];
      var _randomColor = new Random();

      var element = colorsList[_randomColor.nextInt(colorsList.length)];
      setStateIfMounted(() {
        animcolor = element;
      });
    });
  }

  resetColorAndChange() {
    setStateIfMounted(() {
      animcolor = Colors.black;
    });
    changeColor();
  }

  changeMenu(event) async {
    // print(event);
  }

  setToDefault() async {
    setStateIfMounted(() {
      charging = false;
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('prevChargeState', 'disCharge');
  }

  Future<List> getUserInfo(menus) async {
    List<dynamic> userMap;

    final String userStr = menus;
    if (userStr != null) {
      userMap = jsonDecode(userStr) as List<dynamic>;
    }
    if (userMap != null) {
      final List<dynamic> usersList = userMap;

      return usersList;
    }
    return null;
  }

  Future checkInstalledApps() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('loading', false);
    var menus = prefs.getString('menus');
    if (strList.length != 0) {
      var v = await getUserInfo(menus);
      Future<List<Application>> apps = DeviceApps.getInstalledApplications(
          includeAppIcons: true, includeSystemApps: true);

      List futureList = [];
      var appsList = await apps;
      v.forEach((i) {
        var index = appsList.indexWhere((element) =>
            element.appName.toLowerCase().toString() ==
            i['appName'].toLowerCase().toString());
        if (index == -1) {
          // var s = {
          //   'appName': i['appName'],
          //   'packageName': i['packageName'],
          //   'icon': i['icon']
          // };
          prefs.setString('removedAppName', i['appName']);
          // v.removeWhere((element) => element['appName'] == s['appName']);
          prefs.setString('menus', jsonEncode(v));
          // print(result);

          prefs.setBool('loading', true);
          prefs.setBool('isRecentAppInstalled', true);
        }
      });

      for (var i in appsList) {
        bool isSystemApp = await InstalledApps.isSystemApp(i.packageName);
        if (isSystemApp == false || i.appName.toLowerCase() == "phone") {
          var index = v.indexWhere((element) =>
              element['appName'].toLowerCase().toString() ==
              i.appName.toLowerCase().toString());

          if (index == -1) {
            print('tusk 123');
            prefs.setBool('loading', true);

            var s = {
              'appName': i.appName,
              'packageName': i.packageName,
              'icon': i is ApplicationWithIcon ? i.icon : null
            };
            prefs.setString('newApp', jsonEncode(s));
            futureList.add(s);
            if (futureList.length != 0) {
              v.add(futureList[0]);

              v.sort((a, b) => a['appName']
                  .toString()
                  .toLowerCase()
                  .compareTo(b['appName'].toString().toLowerCase()));

              prefs.setInt(
                  'newAppIndex',
                  v.indexWhere(
                      (element) => element['appName'] == s['appName']));
              prefs.setBool('loading', false);
            }
            prefs.setBool('isRecentAppInstalled', true);
          }
        }
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
    _volumeButtonSubscription?.cancel();
    _batteryStateSubscription.cancel();
  }

  remainSamePage() async {
    return false;
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  navigateToCharging() async {
    final prefs = await SharedPreferences.getInstance();
    var isPrevCharge = prefs.getString('prevChargeState');
    if ((isPrevCharge == "disCharge" && charging == true) ||
        isPrevCharge == null) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.fade,
              duration: Duration(seconds: 2),
              child: Charging()));
      // prefs.setInt('startCount', 1);
    }
  }

  setTime() {
    DateTime now = DateTime.now();
    formattedDate = DateFormat('h:mm').format(now);
    isAmPm = DateFormat('aa').format(now);

    setStateIfMounted(() {
      formattedDate = formattedDate;
      isAmPm = isAmPm;
    });
  }

  @override
  Widget build(BuildContext context) {
    // MediaQueryData queryData;
    // queryData = MediaQuery.of(context);

    return WillPopScope(
        // ignore: missing_return
        onWillPop: () {
          return remainSamePage();
        },
        child: FocusDetector(
            onFocusLost: () {
              print(
                'Focus Lost.'
                '\nTriggered when either [onVisibilityLost] or [onForegroundLost] '
                'is called.'
                '\nEquivalent to onPause() on Android or viewDidDisappear() on '
                'iOS.',
              );
            },
            onFocusGained: () {
              resetColorAndChange();
              checkInstalledApps();
              checkBatterylevel();
            },
            onVisibilityLost: () {
              print(
                'Visibility Lost.'
                '\nIt means the widget is no longer visible within your app.',
              );
            },
            onForegroundLost: () {
              print(
                'Foreground Lost.'
                '\nIt means, for example, that the user sent your app to the '
                'background by opening another app or turned off the device\'s '
                'screen while your widget was visible.',
              );
            },
            child: TouchableOpacity(
                onDoubleTap: () {
                  if (charging) {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.fade,
                            duration: Duration(milliseconds: 300),
                            child: Charging()));
                  } else {
                    return false;
                  }
                },
                child: Scaffold(
                    resizeToAvoidBottomInset: true,
                    backgroundColor: Colors.black,
                    body: AnimatedContainer(
                        curve: Curves.decelerate,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                stops: [
                              0.7,
                              0.72,
                              0.79,
                              0.95,
                              1
                            ],
                                colors: [
                              Colors.black,
                              Colors.black,
                              Colors.black,
                              animcolor,
                              animcolor
                            ])
                            // RadialGradient(
                            //   colors: [
                            //     Colors.black,
                            //     Colors.black,
                            //     animcolor,
                            //     Colors.black
                            //   ],
                            //   // radius: 10,
                            //   stops: [0.6, 0.7, 0.8, 1],
                            //   radius: 2,
                            //   center: Alignment(2.5, -1.5),
                            //   // focal: Alignment(-0.1, 0.9s),
                            //   focalRadius: 2,
                            // ),
                            ),
                        // RadialGradient(
                        //     radius: 5,
                        //     center: Alignment(6, -5),
                        //     // begin: Alignment.topRight,
                        //     // end: Alignment.bottomLeft,
                        //     stops: [0.2, 0.3, 0.4, 0.5],
                        //     focal: Alignment(0.1, 0.3),
                        //     colors: [
                        //       Colors.black,
                        //       animcolor,
                        //       Colors.black,
                        //       Colors.black
                        //     ])),
                        duration: Duration(milliseconds: 899),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(40, 80, 0, 0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '$formattedDate',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 58,
                                              fontFamily: 'Montserrat'),
                                        ),
                                        Text(
                                          ' $isAmPm',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontFamily: 'Montserrat'),
                                        )
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            ConstrainedBox(
                                              constraints:
                                                  BoxConstraints.tightFor(
                                                      width: 60, height: 60),
                                              child: ElevatedButton(
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            Icon(
                                                              Icons.phone,
                                                              size: 25,
                                                              color: Colors
                                                                  .blueAccent,
                                                            ),
                                                          ]),
                                                    ]),
                                                onPressed: () {
                                                  _launchCaller("");
                                                },
                                                onLongPress: () {
                                                  _launchCaller('');
                                                },
                                                style: ButtonStyle(
                                                  shape: MaterialStateProperty
                                                      .all<RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30.0),
                                                  )),
                                                  backgroundColor:
                                                      MaterialStateProperty
                                                          .resolveWith<Color>(
                                                    (Set<MaterialState>
                                                        states) {
                                                      if (states.contains(
                                                          MaterialState
                                                              .pressed))
                                                        return Colors
                                                            .blueAccent;
                                                      return Colors
                                                          .black; // Use the component's default.
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),

                                            //menu button
                                            Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  // if ((batteryPercentage != 0 &&
                                                  //         batteryPercentage < 20) ||
                                                  //     (switchState == 'off' &&
                                                  //         batteryPercentage != 0))
                                                  //   ElevatedButton(
                                                  //     onPressed: () {
                                                  //       setBatterySavorMode();
                                                  //     },
                                                  //     style: ButtonStyle(
                                                  //         shape: MaterialStateProperty.all<
                                                  //                 RoundedRectangleBorder>(
                                                  //             RoundedRectangleBorder(
                                                  //           borderRadius:
                                                  //               BorderRadius.circular(
                                                  //                   18.0),
                                                  //         )),
                                                  //         backgroundColor:
                                                  //             MaterialStateProperty
                                                  //                 .resolveWith<Color>(
                                                  //                     (states) =>
                                                  //                         Colors.red)),
                                                  //     child: Text(
                                                  //       'Turn $switchState power saver mode',
                                                  //       style: TextStyle(
                                                  //           color: Colors.white),
                                                  //     ),
                                                  //   ),
                                                  ConstrainedBox(
                                                    constraints:
                                                        BoxConstraints.tightFor(
                                                            width: onChangeIcon
                                                                ? 80
                                                                : 50,
                                                            height: onChangeIcon
                                                                ? 80
                                                                : 50),
                                                    child: ElevatedButton(
                                                      child:
                                                          onChangeIcon == true
                                                              ? Image.asset(
                                                                  'assets/images/ga1.png',
                                                                  height: 80,
                                                                  width: 80,
                                                                  fit: BoxFit
                                                                      .contain,
                                                                )
                                                              : AppDrawerIcon(),
                                                      onLongPress: () => {
                                                        setState(() {
                                                          onChangeIcon = true;
                                                        }),
                                                        Future.delayed(
                                                            Duration(
                                                                seconds: 1),
                                                            () {
                                                          DeviceApps.openApp(
                                                              "com.google.android.apps.googleassistant");
                                                          setState(() {
                                                            onChangeIcon =
                                                                false;
                                                          });
                                                        })
                                                      },
                                                      onPressed: () => _submit(
                                                          counter: _counter),
                                                      style: ButtonStyle(
                                                        shape: MaterialStateProperty.all<
                                                                RoundedRectangleBorder>(
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      30.0),
                                                        )),
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .resolveWith<
                                                                    Color>(
                                                          (Set<MaterialState>
                                                              states) {
                                                            if (states.contains(
                                                                MaterialState
                                                                    .pressed))
                                                              return Colors.red;
                                                            return Colors
                                                                .transparent; // Use the component's default.
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ]),
                                            //
                                            ConstrainedBox(
                                              constraints:
                                                  BoxConstraints.tightFor(
                                                      width: 60, height: 60),
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  _textMe();
                                                },
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.message,
                                                      color:
                                                          Colors.orangeAccent,
                                                    )
                                                  ],
                                                ),
                                                style: ButtonStyle(
                                                  shape: MaterialStateProperty
                                                      .all<RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30.0),
                                                  )),
                                                  backgroundColor:
                                                      MaterialStateProperty
                                                          .resolveWith<Color>(
                                                    (Set<MaterialState>
                                                        states) {
                                                      if (states.contains(
                                                          MaterialState
                                                              .pressed))
                                                        return Colors.orange;
                                                      return Colors
                                                          .black; // Use the component's default.
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                ]),
                          ),
                        ))))));
  }
}

class AppDrawerIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Icon(
                  Icons.circle,
                  size: 5,
                  color: Colors.transparent,
                ),
                Icon(
                  Icons.circle,
                  size: 5,
                ),
                Icon(
                  Icons.circle,
                  size: 5,
                  color: Colors.transparent,
                ),
              ]),
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.circle,
                  size: 5,
                ),
                Icon(
                  Icons.circle,
                  size: 5,
                ),
                Icon(
                  Icons.circle,
                  size: 5,
                ),
              ]),
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.circle,
                  size: 5,
                ),
                Icon(
                  Icons.circle,
                  size: 5,
                ),
                Icon(
                  Icons.circle,
                  size: 5,
                ),
              ]),
        ]);
  }
}
