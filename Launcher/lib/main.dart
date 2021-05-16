import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:Smart_Power_Launcher/Charging.dart';
import 'package:battery/battery.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:installed_apps/installed_apps.dart';
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
  @override
  void initState() {
    super.initState();
    checkInstalledApps();
    checkBatterylevel();
    // startTimer();

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
                    body: Center(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ConstrainedBox(
                                    constraints: BoxConstraints.tightFor(
                                        width: 60, height: 60),
                                    child: ElevatedButton(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.phone,
                                                    size: 25,
                                                    color: Colors.blueAccent,
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
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                        )),
                                        backgroundColor: MaterialStateProperty
                                            .resolveWith<Color>(
                                          (Set<MaterialState> states) {
                                            if (states.contains(
                                                MaterialState.pressed))
                                              return Colors.blueAccent;
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
                                        if ((batteryPercentage != 0 &&
                                                batteryPercentage < 20) ||
                                            (switchState == 'off' &&
                                                batteryPercentage != 0))
                                          ElevatedButton(
                                            onPressed: () {
                                              setBatterySavorMode();
                                            },
                                            style: ButtonStyle(
                                                shape: MaterialStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          18.0),
                                                )),
                                                backgroundColor:
                                                    MaterialStateProperty
                                                        .resolveWith<Color>(
                                                            (states) =>
                                                                Colors.red)),
                                            child: Text(
                                              'Turn $switchState power saver mode',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ConstrainedBox(
                                          constraints: BoxConstraints.tightFor(
                                              width: onChangeIcon ? 80 : 50,
                                              height: onChangeIcon ? 80 : 50),
                                          child: ElevatedButton(
                                            child: onChangeIcon == true
                                                ? Image.asset(
                                                    'assets/images/ga1.png',
                                                    height: 80,
                                                    width: 80,
                                                    fit: BoxFit.contain,
                                                  )
                                                : AppDrawerIcon(),
                                            onLongPress: () => {
                                              setState(() {
                                                onChangeIcon = true;
                                              }),
                                              Future.delayed(
                                                  Duration(seconds: 1), () {
                                                DeviceApps.openApp(
                                                    "com.google.android.apps.googleassistant");
                                                setState(() {
                                                  onChangeIcon = false;
                                                });
                                              })
                                            },
                                            onPressed: () =>
                                                _submit(counter: _counter),
                                            style: ButtonStyle(
                                              shape: MaterialStateProperty.all<
                                                      RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30.0),
                                              )),
                                              backgroundColor:
                                                  MaterialStateProperty
                                                      .resolveWith<Color>(
                                                (Set<MaterialState> states) {
                                                  if (states.contains(
                                                      MaterialState.pressed))
                                                    return Colors.red;
                                                  return Colors
                                                      .black; // Use the component's default.
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]),
                                  //
                                  ConstrainedBox(
                                    constraints: BoxConstraints.tightFor(
                                        width: 50, height: 50),
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
                                            color: Colors.orangeAccent,
                                          )
                                        ],
                                      ),
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                        )),
                                        backgroundColor: MaterialStateProperty
                                            .resolveWith<Color>(
                                          (Set<MaterialState> states) {
                                            if (states.contains(
                                                MaterialState.pressed))
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
                        ),
                      ),
                    )))));
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
