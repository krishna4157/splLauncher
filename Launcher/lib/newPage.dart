// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:Smart_Power_Launcher/main.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touchable_opacity/touchable_opacity.dart';
import 'package:url_launcher/url_launcher.dart';

var list = [];
var searchText = "";
var selectedList = [];
var loading = true;
var userNameController = new TextEditingController();
var count = 0;
var noAppsFound = false;
var milliseconds = 150;
var tempCount = 1;
Timer timer;
bool isNumericUsingRegularExpression(String string) {
  final numericRegex = RegExp(r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');

  return numericRegex.hasMatch(string);
}

_launchPlayStore(value) async {
  var url;
  if (value.contains('https')) {
    url = "$value";
  } else if (value.contains('.com')) {
    url = "https://www.$value";
  } else {
    url = "https://play.google.com/store/search?q=$value";
  }
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

_launchCaller(String text) async {
  var url = "tel:$text";
  if (await canLaunch(url)) {
    if (!text.toString().contains('https')) {
      await launch(url);
    } else {
      _launchPlayStore(text);
    }
  } else {
    throw 'Could not launch $url';
  }
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

getRandomColors() {
  var colorsList = [
    Colors.red,
    Colors.green,
    Colors.yellow,
    Colors.blue,
    Colors.purple,
    Colors.white,
    Colors.amber,
    Colors.blueAccent,
    Colors.deepOrangeAccent,
    Colors.lime
  ];
  final _random = new Random();

  var element = colorsList[_random.nextInt(colorsList.length)];
  return element;
}

class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPL Launcher',
      home: SharedPreferencesDemo(),
    );
  }
}

class SharedPreferencesDemo extends StatefulWidget {
  SharedPreferencesDemo({Key key}) : super(key: key);

  @override
  _SharedPreferencesDemoState createState() => _SharedPreferencesDemoState();
}

class _SharedPreferencesDemoState extends State<SharedPreferencesDemo>
    with TickerProviderStateMixin {
  final GlobalKey<AnimatedListState> key = new GlobalKey<AnimatedListState>();
  List<Widget> itemData = [];
  Stream<List> getAppsList() async* {
    if (userNameController.text == "") {
      final prefs = await SharedPreferences.getInstance();
      var menus = prefs.getString('menus');

      if (menus == null) {
        Future<List<Application>> apps = DeviceApps.getInstalledApplications(
            includeAppIcons: true, includeSystemApps: true);

        List<AppsList> futureList = [];
        var appsList = await apps;
        for (var i in appsList) {
          bool isSystemApp =
              i.apkFilePath.contains("/data/app/") ? false : true;
          if (i.appName.toLowerCase() == 'gallery' ||
              isSystemApp && i.appName.toLowerCase() == 'phone' ||
              !isSystemApp) {
            AppsList appsLists = AppsList(i.appName, i.packageName,
                i is ApplicationWithIcon ? i.icon : null);
            futureList.add(appsLists);
          }
        }

        futureList.sort((a, b) => a.appName
            .toString()
            .toLowerCase()
            .compareTo(b.appName.toString().toLowerCase()));

        var v;
        await prefs.setString('menus', jsonEncode(futureList)).then((value) {
          menus = prefs.getString('menus');
          v = getUserInfo(menus);
        });

        // var w = await v;
        // v = await v;
        // list = v;

        yield* Stream.fromFuture(v);
      } else {
        // if (list != null) {
        //   var v = getUserInfo(menus);
        //   yield* Stream.fromFuture(v);
        // } else {
        var menus = prefs.getString('menus');
        var v = getUserInfo(menus);
        list = await v;
        yield* Stream.fromFuture(v);
      }
    }
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  startTimer() async {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => updateLoading());
  }

  updateLoading() async {
    final prefs = await SharedPreferences.getInstance();
    count = 0;
    if (userNameController.text.toString().isEmpty) {
    } else {
      list.forEach((e) {
        if (e['appName']
            .toString()
            .toLowerCase()
            .contains(userNameController.text.toLowerCase())) {
          count = count + 1;
        }
      });
    }

    var isRecentAppInstalled = prefs.getBool('isRecentAppInstalled');

    if (isRecentAppInstalled != null && isRecentAppInstalled) {
      var removedApp = prefs.getString('removedAppName');
      if (removedApp != null && removedApp != "") {
        // var s = prefs.getString('menus');

        list.removeWhere((element) => element['appName'] == removedApp);
        prefs.setString('menus', jsonEncode(list));
        prefs.setString('removedAppName', "");
      }

      Future.delayed(Duration(milliseconds: 150), () {
        setStateIfMounted(() {
          // list = v;
        });
      });

      await prefs.setBool('isRecentAppInstalled', false);
    }
  }

  AnimationController _controller1;
  Animation<double> animation2;
  Animation<double> animation;
  final _debouncer = new Debouncer(milliseconds: 500);
  var nosearchResult = true;
  @override
  void dispose() {
    super.dispose();
    reset();
  }

  void reset() {
    _controller1.value = 0.0;
  }

  void resetCount() {
    _controller1.value = 0.0;
    count = 0;
    tempCount = 1;
  }

  setInitialValues() async {
    setStateIfMounted(() {
      noAppsFound = false;
    });
  }

  @override
  void initState() {
    super.initState();

    _controller1 = AnimationController(
      duration: Duration(milliseconds: milliseconds),
      vsync: this,
    );

    animation2 = Tween<double>(begin: 0.0, end: 1.0).animate(_controller1)
      ..addListener(() {
        // print('hello');
      });
    setInitialValues();
    startTimer();
    reset();
    setStateIfMounted(() {
      selectedList = selectedList;
    });
    userNameController.clear();
    noAppsFound = false;
    userNameController.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _debouncer.run(() {
          print('tempCount : $tempCount');
          print('Count : $count');
          if (tempCount != count || tempCount == 0) {
            Future.delayed(Duration(milliseconds: 100), () {
              setStateIfMounted(() {
                // searchText = value;
                noAppsFound = noAppsFound;
                tempCount = count;
              });
              reset();
            });
          }

          // _controller1.forward();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    FocusNode focus = FocusNode();
    return Dismissible(
        // Show a red background as the item is swiped away.
        background: Container(
          color: Colors.black,
        ),
        key: Key('drawer'),
        onDismissed: (direction) {
          Navigator.pushReplacement(
              context,
              PageTransition(
                  type: PageTransitionType.fade,
                  duration: Duration(milliseconds: 200),
                  child: CountingApp()));
        },
        child: Scaffold(
            backgroundColor: Colors.black,
            body: Column(children: <Widget>[
              Expanded(
                flex: 3,
                child: Container(
                    child: StreamBuilder(
                        stream: getAppsList(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (!noAppsFound) {
                              // count = 0;

                              return ShaderMask(
                                  shaderCallback: (Rect bounds) {
                                    return LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: <Color>[
                                        Colors.white,
                                        Colors.white,
                                        Colors.white,
                                        Colors.white,
                                        Colors.black
                                      ],
                                    ).createShader(bounds);
                                  },
                                  child: ListView.builder(
                                      key: key,
                                      cacheExtent: 9999,
                                      physics: BouncingScrollPhysics(),
                                      itemCount: snapshot.data.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        // reset();
                                        // if (userNameController.text == "") {
                                        Future.delayed(
                                            Duration(milliseconds: 250), () {
                                          // reset();
                                          _controller1.forward();
                                        });
                                        // }
                                        if (snapshot.data[index]['appName']
                                            .toString()
                                            .toLowerCase()
                                            .contains(userNameController.text
                                                .toString()
                                                .toLowerCase())) {
                                          // return itemData[index];
                                          return FadeTransition(
                                              opacity: animation2,
                                              child: buildItem(
                                                  snapshot.data[index], index));
                                        } else {
                                          nosearchResult = true;
                                          for (var i in snapshot.data) {
                                            if (i['appName']
                                                .toString()
                                                .toLowerCase()
                                                .contains(userNameController
                                                    .text
                                                    .toLowerCase())) {
                                              nosearchResult = false;
                                            }
                                          }

                                          while (nosearchResult == true &&
                                              userNameController.text != "") {
                                            noAppsFound = true;
                                            break;
                                          }

                                          return Container(
                                            color: Colors.red,
                                          );
                                        }
                                      }));
                            } else {
                              var index = snapshot.data.indexWhere((ele) =>
                                  ele["appName"]
                                      .toString()
                                      .toLowerCase()
                                      .contains(userNameController.text));
                              if (index == -1) {
                                noAppsFound = true;
                              } else {
                                noAppsFound = false;
                              }
                              return Container(
                                  child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(20, 40, 20, 0),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0, 0, 40),
                                              child: Image.asset(
                                                'assets/images/not-found.gif',
                                                height: 100,
                                                width: 100,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                            TouchableOpacity(
                                              onTap: () {
                                                if (userNameController.text
                                                        .contains('call') ||
                                                    userNameController.text
                                                        .contains('+91') ||
                                                    isNumericUsingRegularExpression(
                                                        userNameController
                                                            .text)) {
                                                  _launchCaller(
                                                      userNameController.text);
                                                } else {
                                                  _launchPlayStore(
                                                      userNameController.text);
                                                }
                                              },
                                              child: Text(
                                                isNumericUsingRegularExpression(
                                                            userNameController
                                                                .text) ||
                                                        userNameController.text
                                                            .contains('+91')
                                                    ? userNameController.text
                                                            .contains('call')
                                                        ? '"${userNameController.text}" '
                                                        : 'call "${userNameController.text}" '
                                                    : userNameController.text
                                                                .contains(
                                                                    '.com') ||
                                                            userNameController
                                                                .text
                                                                .contains(
                                                                    'https')
                                                        ? 'open "${userNameController.text}" in browser.'
                                                        : 'search for "${userNameController.text}" in play store. ',
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 20,
                                                  fontFamily: 'Montserrat',
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )));
                            }
                          } else {
                            return Center(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  'assets/images/dino.gif',
                                  height: 250,
                                  width: 250,
                                  fit: BoxFit.contain,
                                ),
                                Text(
                                  'Loading ...',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            ));
                          }
                        })),
              ),
              Expanded(
                  flex: 0,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                              Padding(
                                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: TextFormField(
                                    focusNode: focus,
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.search,
                                          color: Colors.blueAccent,
                                        ),
                                        hintText:
                                            "Search your apps and content here",
                                        hintStyle: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.0),
                                        suffixIcon: userNameController.text !=
                                                ""
                                            ? IconButton(
                                                color: Colors.red,
                                                onPressed: () => {
                                                  SchedulerBinding.instance
                                                      .addPostFrameCallback(
                                                          (_) {
                                                    focus.unfocus();
                                                    count = 0;
                                                    setStateIfMounted(() {
                                                      noAppsFound = false;
                                                    });
                                                    userNameController.clear();
                                                    reset();
                                                  }),
                                                },
                                                // userNameController.clear()},
                                                icon: Icon(
                                                  Icons.clear,
                                                  color: Colors.red,
                                                ),
                                              )
                                            : Text('')),
                                    controller: userNameController,
                                    keyboardType: TextInputType.emailAddress,
                                    onFieldSubmitted: (value) {
                                      //Validator
                                    },
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 25,
                                        fontFamily: 'Montserrat'),
                                  )),
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: Container(
                                  height: selectedList.length > 0 ? 60.0 : 0,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: <Widget>[
                                      for (var i in selectedList)
                                        RecentButtons(
                                          title: i['title'],
                                          packageName: i['packageName'],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ]))
                      ]))
            ])));
  }

  Widget buildItem(item, int index) {
    Animation itemAnim =
        Tween<double>(begin: 0.0, end: 1.0).animate(_controller1);

    void resetAnimation() {
      // reset();
      // _controller1.forward();
    }

    return AppListGenerator(
        title: item['appName'],
        icon: Uint8List.fromList(item['icon'].cast<int>()),
        packageName: item['packageName'],
        itemAnimation: itemAnim,
        resetAnimation: () => resetAnimation(),
        onClicked: () => {});
  }

  void removeItem(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final menus = prefs.getString('menus');
    final removedAppName = prefs.getString('removedAppName');

    var removeApp = '1Intro';
    var item = await getUserInfo(menus);
    final removedItem =
        item.where((element) => element['appName'] == removedAppName).single;
    final removedIndex =
        item.indexWhere((element) => element['appName'] == removedAppName);
    item.removeWhere((element) => element['appName'] == removedAppName);

    if (key.currentState != null)
      key.currentState.removeItem(removedIndex,
          (context, animation) => buildItem(removedItem, removedIndex));
  }

  void insertItem(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final menus = prefs.getString('menus');
    var removeApp = '1Intro';
    final item = await getUserInfo(menus);
    final removedItem =
        item.where((element) => element['appName'] == removeApp).single;
    final removedIndex =
        item.indexWhere((element) => element['appName'] == removeApp);
    key.currentState.insertItem(index);
  }
}

class AppsList {
  String appName;
  String packageName;
  Uint8List icon;

  AppsList(this.appName, this.packageName, this.icon);

  AppsList.fromJson(Map<String, dynamic> json) {
    appName = json['appName'];
    packageName = json['packageName'];
    icon = json['icon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['appName'] = this.appName;
    data['packageName'] = this.packageName;
    data['icon'] = this.icon;
    return data;
  }

  @override
  String toString() {
    return '{ "appName": $appName, "packageName": $packageName, "icon": $icon }';
  }
}

class AppListGenerator extends StatelessWidget {
  final String title;
  final Uint8List icon;
  final String packageName;
  final Animation itemAnimation;
  final VoidCallback onClicked;
  final VoidCallback resetAnimation;

  const AppListGenerator({
    Key key,
    this.title,
    this.icon,
    this.packageName,
    this.itemAnimation,
    this.onClicked,
    this.resetAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget image = Image.memory(
      icon,
      height: 50,
      width: 50,
    );

    resetAnimation();

    return Column(children: [
      TouchableOpacity(
          onTap: () {
            onClicked();
            var s = {'packageName': packageName, 'title': title};
            if (selectedList.length > 5) {
              selectedList.removeLast();
            }
            bool isPackageIncluded = false;
            selectedList.forEach((element) {
              if (element['packageName'] == packageName) {
                isPackageIncluded = true;
              }
            });
            if (isPackageIncluded == false) {
              selectedList.insert(0, s);
            }
            Navigator.pushReplacement(
                context,
                PageTransition(
                    type: PageTransitionType.bottomToTop,
                    duration: Duration(seconds: 1),
                    child: CountingApp()));
            if (title.toLowerCase() == 'phone') {
              _launchCaller("");
            } else {
              DeviceApps.openApp(packageName);
            }
          },
          child: AnimatedContainer(
              duration: Duration(seconds: 1),
              color: Colors.black,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      new Container(),
                      ClipRRect(
                          borderRadius: BorderRadius.circular(30), child: image
                          //
                          // child: Image.memory(icon),
                          ),
                      Padding(
                          padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                          child: Row(
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ))
                    ],
                  ))))
    ]);
  }
}

// ignore: must_be_immutable
class RecentButtons extends StatelessWidget {
  final String title;
  final String packageName;

  bool isPackageIncluded;
  RecentButtons({Key key, this.title, this.packageName}) : super(key: key);
  final Color color = getRandomColors();

  get icon => null;
  @override
  Widget build(BuildContext context) {
    return TouchableOpacity(
      activeOpacity: 0.4,
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        // activeOpacity: 0.4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
                onPressed: () {
                  var s = {'packageName': packageName, 'title': title};

                  if (selectedList.length > 5) {
                    selectedList.removeLast();
                  }

                  var index = selectedList.indexWhere(
                      (element) => element['packageName'] == packageName);
                  selectedList.removeAt(index);
                  selectedList.insert(0, s);
                  Navigator.pushReplacement(
                      context,
                      PageTransition(
                          type: PageTransitionType.bottomToTop,
                          duration: Duration(seconds: 1),
                          child: CountingApp()));
                  if (title.toLowerCase() == 'phone') {
                    _launchCaller("");
                  } else {
                    DeviceApps.openApp(packageName);
                  }
                },
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: color)))),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Text(
                    title,
                    style: TextStyle(color: color),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}

class Debouncer {
  final int milliseconds;
  VoidCallback action;
  Timer _timer;

  Debouncer({this.milliseconds});

  run(VoidCallback action) {
    if (null != _timer) {
      _timer.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
