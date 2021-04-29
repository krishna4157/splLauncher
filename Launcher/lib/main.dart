import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:Smart_Power_Launcher/Charging.dart';
import 'package:battery/battery.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touchable_opacity/touchable_opacity.dart';
import 'newPage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:focus_detector/focus_detector.dart';
import 'alphabetListView.dart';

// import 'package:hardware_buttons/hardware_buttons.dart';
var charging = false;
var isNotPresent = false;
StreamSubscription _volumeButtonSubscription;
var onChangeIcon = false;
var i = 0;
void main() {
  // GestureBinding.instance.resamplingEnabled = true;
  runApp(Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
      },
      child: MaterialApp(home: CountingApp(), // becomes the route named '/'
          routes: <String, WidgetBuilder>{
            '/secondRoute': (BuildContext context) => SecondRoute(),
            '/charging': (BuildContext context) => Charging(),
          })));
}

// _launchURL() async {
//   // Replace 12345678 with your tel. no.
//   DeviceApps.openApp("com.android.incallui");
//   // android_intent.Intent()
//   //   ..setAction(android_action.Action.ACTION_CALL)
//   //   ..setData(Uri(scheme: "tel", path: "12345678"))
//   //   ..startActivity().catchError((e) => print(e));
// }

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
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
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

  // void _incrementCounter() {
  //   setState(() {
  //     // This call to setState tells the Flutter framework that something has
  //     // changed in this State, which causes it to rerun the build method below
  //     // so that the display can reflect the updated values. If we changed
  //     // _counter without calling setState(), then the build method would not be
  //     // called again, and so nothing would appear to happen.
  //     _counter++;
  //   });
  // }

  // Future<void> _showMyDialog(counter) async {
  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: false, // user must tap button!
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('SUCCESS'),
  //         content: SingleChildScrollView(
  //           child: ListBody(
  //             children: <Widget>[
  //               Text(''),
  //               Text('do you want to save these details ?'),
  //             ],
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text('Approve'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               _navigateToNewPage(counter);
  //             },
  //           ),
  //           TextButton(
  //             child: Text('Deny'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           )
  //         ],
  //       );
  //     },
  //   );
  // }

  void _submit({int counter}) {
    _navigateToNewPage(counter);
  }

  void _navigateToNewPage(counter) {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.bottomToTop,
            duration: Duration(milliseconds: 300),
            child: MainApp()));
  }

  startTimer() async {
    timer = Timer.periodic(
        Duration(seconds: 10), (Timer t) => checkInstalledApps());
  }

  void setPrevChargeState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('prevChargeState', 'disCharge');
  }

  StreamSubscription<BatteryState> _batteryStateSubscription;
  var _battery = new Battery();
  Timer timer;
  int counter = 0;
  @override
  void initState() {
    super.initState();
    checkInstalledApps();

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
        navigateToCharging();
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
    final prefs = await SharedPreferences.getInstance();

    final String userStr = menus;
    if (userStr != null) {
      userMap = jsonDecode(userStr) as List<dynamic>;
    }
    if (userMap != null) {
      final List<dynamic> usersList = userMap;
      // setState(() {
      //   list = usersList;
      // });
      // dataStored = prefs.getString('isLoaded');
      return usersList;
    }
    return null;
  }

  Future checkInstalledApps() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('loading', false);
    var menus = prefs.getString('menus');
    if (menus != null) {
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
          prefs.setBool('loading', true);

          var s = {
            'appName': i['appName'],
            'packageName': i['packageName'],
            'icon': i['icon']
          };
          prefs.setString('removedAppName', i['appName']);
          // v.removeWhere((element) => element['appName'] == s['appName']);
          prefs.setString('menus', jsonEncode(v));
          // print(result);

          prefs.setBool('loading', false);
          prefs.setBool('isRecentAppInstalled', true);
        }
      });

      for (var i in appsList) {
        bool isSystemApp = i.apkFilePath.contains("/data/app/") ? false : true;
        if (i.appName.toLowerCase() == 'gallery' ||
            isSystemApp && i.appName.toLowerCase() == 'phone' ||
            !isSystemApp) {
          // print(i.appName);
          // if (i.appName.toLowerCase() == "tusk") {
          //   var s = 0;
          // }
          var index2;
          v.indexWhere((element) => index2 =
              element['appName'].toString().toLowerCase() ==
                  i.appName.toString().toLowerCase());
          // }
          // print(index2);
          var index = v.indexWhere((element) =>
              element['appName'].toLowerCase().toString() ==
              i.appName.toLowerCase().toString());

          if (index2 == -1) {
            // print('tusk');
          }

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
              // prefs.setString('menus', jsonEncode(v));
              // print(result);
              prefs.setBool('loading', false);
            }
            prefs.setBool('isRecentAppInstalled', true);
          }
        }
      }

      // prefs.setString('isLoaded', 'true');

      //

      // futureList.sort((a, b) => a.appName
      //     .toString()
      //     .toLowerCase()
      //     .compareTo(b.appName.toString().toLowerCase()));

      // setStateIfMounted(() {
      //   list = futureList;
      //   loading = false;
      // });
      // print(list.length);
      // return futureList;

      /////////////////////////////////////////////////
      // Future<List<AppInfo>> apps =
      //     InstalledApps.getInstalledApps(false, true, "");

      // List<AppsList> futureList = [];
      // var appsList = await apps;
      // for (var i in appsList) {
      //   bool isSystemApp = await InstalledApps.isSystemApp(i.packageName);

      //   if (isSystemApp && i.appName.toLowerCase() == 'phone' || !isSystemApp) {
      //     AppsList appsLists = AppsList(i.appName, i.packageName, i.icon);
      //     futureList.add(appsLists);
      //   }
      // }

      // futureList.sort((a, b) => a.appName
      //     .toString()
      //     .toLowerCase()
      //     .compareTo(b.appName.toString().toLowerCase()));

      // setStateIfMounted(() {
      //   list = futureList;
      //   loading = false;
      // });

      // bool result = await prefs.setString('menus', jsonEncode(futureList));
      // prefs.setString('isLoaded', 'true');
      // print(result);

      // setStateIfMounted(() {
      //   list = futureList;
      //   loading = false;
      // });
      // dataStored = prefs.getString('isLoaded');
      // prefs.setString('isLoaded', 'true');
      // setStateIfMounted(() {
      //   list = v;
      //   loading = false;
      // });
      // return list;
      // print(list.length);
      // return v;
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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    MediaQueryData queryData;
    queryData = MediaQuery.of(context);

    return WillPopScope(
        // ignore: missing_return
        onWillPop: () {
          return remainSamePage();
        },
        // onDoubleTap: () {},

        // onWillPop: () => Navigator.pop(),
        // showDialog<bool>(
        //     context: context,
        //     builder: (c) => AlertDialog(
        //           title: Text('Warning'),
        //           content: Text('Do you really want to exit'),
        //           actions: [
        //             FlatButton(
        //               child: Text('Yes'),
        //               onPressed: () => Navigator.pop(c, true),
        //             ),
        //             FlatButton(
        //               child: Text('No'),
        //               onPressed: () => Navigator.pop(c, false),
        //             ),
        //           ],
        //         )
        // ),
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
            },
            onVisibilityLost: () {
              print(
                'Visibility Lost.'
                '\nIt means the widget is no longer visible within your app.',
              );
            },
            onVisibilityGained: () {
              // checkInstalledApps();
            },
            onForegroundLost: () {
              print(
                'Foreground Lost.'
                '\nIt means, for example, that the user sent your app to the '
                'background by opening another app or turned off the device\'s '
                'screen while your widget was visible.',
              );
            },
            onForegroundGained: () {
              // checkInstalledApps();
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
                      // Center is a layout widget. It takes a single child and positions it
                      // in the middle of the parent.
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                        child: Column(
                          // Column is also a layout widget. It takes a list of children and
                          // arranges them vertically. By default, it sizes itself to fit its
                          // children horizontally, and tries to be as tall as its parent.
                          //
                          // Invoke "debug painting" (press "p" in the console, choose the
                          // "Toggle Debug Paint" action from the Flutter Inspector in Android
                          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
                          // to see the wireframe for each widget.
                          //
                          // Column has various properties to control how it sizes itself and
                          // how it positions its children. Here we use mainAxisAlignment to
                          // center the children vertically; the main axis here is the vertical
                          // axis because Columns are vertical (the cross axis would be
                          // horizontal).
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            // RaisedButton(
                            //
                            //     child: Text('s'),
                            //     shape: RoundedRectangleBorder(
                            //       borderRadius: new BorderRadius.circular(30.0),
                            //     )),
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
                                        //  UrlLauncher.launch("tel://<phone_number>");
                                        // DeviceApps.openApp("com.android.incallui");
                                      },
                                      onLongPress: () {
                                        _launchCaller('');
                                      },
                                      // DeviceApps.openApp('com.android.incallui'),
                                      style:
                                          // ElevatedButton.styleFrom(
                                          //   shape: CircleBorder(),

                                          // ),
                                          ButtonStyle(
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
                                        Future.delayed(Duration(seconds: 1),
                                            () {
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
                                        backgroundColor: MaterialStateProperty
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
                    )
                    // floatingActionButton: FloatingActionButton(
                    //   onPressed: _incrementCounter,
                    //   tooltip: 'press me',
                    //   child: Icon(Icons.add),
                    // ) // This trailing comma makes auto-formatting nicer for build methods.
                    ))));
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
