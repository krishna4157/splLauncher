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

var list;
var searchText = "";
var selectedList = [];
var loading = true;
var userNameController = new TextEditingController();
var count = 0;
var _visible = true;
var isListVisible = false;
var noAppsFound = false;
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

getRandomColors() {
  var list = [
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
// generates a new Random object
  final _random = new Random();

// generate a random index based on the list length
// and use it to retrieve the element
  var element = list[_random.nextInt(list.length)];
  return element;
}

class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPL LAuncher',
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
  // Future<List> genCode() {
  //   return getAppsList();
  // }

  Stream<List> getAppsList() async* {
    final prefs = await SharedPreferences.getInstance();
    // // dataStored = prefs.getString('isLoaded');
    var menus = prefs.getString('menus');

    _visible = true;

    if (list == null && menus == null) {
      //     // await DeviceApps.getInstalledApplications();

      Future<List<Application>> apps = DeviceApps.getInstalledApplications(
          includeAppIcons: true, includeSystemApps: true);

      List<AppsList> futureList = [];
      var appsList = await apps;
      // appsList.remove((k, v) => k.contains('_'));

      for (var i in appsList) {
        bool isSystemApp = i.apkFilePath.contains("/data/app/") ? false : true;
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

      // setStateIfMounted(() {
      //   list = futureList;
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

      bool result = await prefs.setString('menus', jsonEncode(futureList));
      // prefs.setString('isLoaded', 'true');
      // print(result);

      // setStateIfMounted(() {
      //   list = futureList;
      //   loading = false;
      // });
      // dataStored = prefs.getString('isLoaded');
      // prefs.setString('isLoaded', 'true');
      var v = getUserInfo(menus);
      setStateIfMounted(() {
        list = v;
        _visible = false;
      });
      // Future.delayed(Duration(seconds: 1), () {
      //   _visible = false;
      // });
      // return list;
      // print(list.length);
      _visible = false;
      _controller.forward();
      yield* Stream.fromFuture(v);
    } else {
      if (list != null) {
        // return list;
        var v = getUserInfo(menus);
        // setStateIfMounted(() {
        //   list = v;
        //   loading = false;
        // });
        // Future.delayed(Duration(seconds: 1), () {
        //   _visible = false;
        // });
        _controller.forward();
        _visible = false;
        yield* Stream.fromFuture(v);
      } else {
        var menus = prefs.getString('menus');
        var v = getUserInfo(menus);
        // setStateIfMounted(() {
        //   list = v;
        //   loading = false;
        // });
        // Future.delayed(Duration(seconds: 1), () {
        //   _visible = false;
        // });
        //
        _controller.forward();
        _visible = false;

        yield* Stream.fromFuture(v);
      }
    }
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  // Future checkInstalledApps() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   var menus = prefs.getString('menus');
  //   if (menus != null) {
  //     var v = await getUserInfo(menus);
  //     Future<List<Application>> apps = DeviceApps.getInstalledApplications(
  //         includeAppIcons: true, includeSystemApps: true);

  //     List futureList = [];
  //     var appsList = await apps;
  //     // appsList.remove((k, v) => k.contains('_'));
  //     var count = 0;
  //     for (var i in appsList) {
  //       bool isSystemApp = i.apkFilePath.contains("/data/app/") ? false : true;
  //       if (i.appName.toLowerCase() == 'gallery' ||
  //           isSystemApp && i.appName.toLowerCase() == 'phone' ||
  //           !isSystemApp) {
  //         var index =
  //             v.indexWhere((element) => element['appName'] == i.appName);

  //         if (index == -1) {
  //           var s = {
  //             'appName': i.appName,
  //             'packageName': i.packageName,
  //             'icon': i is ApplicationWithIcon ? i.icon : null
  //           };
  //           futureList.add(s);
  //           if (futureList.length != 0) {
  //             v.add(futureList[0]);

  //             v.sort((a, b) => a['appName']
  //                 .toString()
  //                 .toLowerCase()
  //                 .compareTo(b['appName'].toString().toLowerCase()));

  //             bool result = await prefs.setString('menus', jsonEncode(v));
  //             print(result);
  //           }
  //         }
  //       }
  //     }
  //     // prefs.setString('isLoaded', 'true');

  //     //

  //     // futureList.sort((a, b) => a.appName
  //     //     .toString()
  //     //     .toLowerCase()
  //     //     .compareTo(b.appName.toString().toLowerCase()));

  //     // setStateIfMounted(() {
  //     //   list = futureList;
  //     //   loading = false;
  //     // });
  //     // print(list.length);
  //     // return futureList;

  //     /////////////////////////////////////////////////
  //     // Future<List<AppInfo>> apps =
  //     //     InstalledApps.getInstalledApps(false, true, "");

  //     // List<AppsList> futureList = [];
  //     // var appsList = await apps;
  //     // for (var i in appsList) {
  //     //   bool isSystemApp = await InstalledApps.isSystemApp(i.packageName);

  //     //   if (isSystemApp && i.appName.toLowerCase() == 'phone' || !isSystemApp) {
  //     //     AppsList appsLists = AppsList(i.appName, i.packageName, i.icon);
  //     //     futureList.add(appsLists);
  //     //   }
  //     // }

  //     // futureList.sort((a, b) => a.appName
  //     //     .toString()
  //     //     .toLowerCase()
  //     //     .compareTo(b.appName.toString().toLowerCase()));

  //     // setStateIfMounted(() {
  //     //   list = futureList;
  //     //   loading = false;
  //     // });

  //     // bool result = await prefs.setString('menus', jsonEncode(futureList));
  //     // prefs.setString('isLoaded', 'true');
  //     // print(result);

  //     // setStateIfMounted(() {
  //     //   list = futureList;
  //     //   loading = false;
  //     // });
  //     // dataStored = prefs.getString('isLoaded');
  //     // prefs.setString('isLoaded', 'true');
  //     // setStateIfMounted(() {
  //     //   list = v;
  //     //   loading = false;
  //     // });
  //     // return list;
  //     // print(list.length);
  //     // return v;
  //   }
  // }
  //
  startTimer() async {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => updateLoading());
  }

  updateLoading() async {
    final prefs = await SharedPreferences.getInstance();
    var prevLoading = prefs.getBool('loading');
    var menus = prefs.getString('menus');
    Future.delayed(Duration(seconds: 5), () {
      if (userNameController.text != searchText) {
        // setStateIfMounted(() {
        // searchText = userNameController.text;
        // count = count;
        // noAppsFound = false;
        // });
        reset();
      }
    });

    var isRecentAppInstalled = prefs.getBool('isRecentAppInstalled');

    if (isRecentAppInstalled) {
      await prefs.setBool('isRecentAppInstalled', false);
      setStateIfMounted(() {});
    }

    if (prevLoading != loading || loading == true) {
      var v = await getUserInfo(menus);
      setStateIfMounted(() {
        loading = prevLoading;
      });
      if (isRecentAppInstalled == true) {
        setStateIfMounted(() {
          list = v;
        });
        await prefs.setBool('isRecentAppInstalled', false);
      }
    }
  }

  // onChangeVisibility() {
  //   isListVisible = true;
  // }

  AnimationController _controller;
  AnimationController _controller1;
  Animation<double> animation2;
  Animation<double> animation;
  final _debouncer = new Debouncer(milliseconds: 500);
  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    reset();
  }

  void reset() {
    _controller1.value = 0.0;
  }

  setInitialValues() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      noAppsFound = false;
    });
    prefs.setBool('isRecentAppInstalled', false);
  }

  Stream<int> _someData() async* {
    yield* Stream.periodic(Duration(seconds: 2), (int a) {
      return a++;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _controller1 = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    animation2 = Tween<double>(begin: 0.0, end: 1.0).animate(_controller1)
      ..addListener(() {
        print('hello');
      });
    setInitialValues();
    // checkInstalledApps();
    startTimer();
    reset();
    setStateIfMounted(() {
      selectedList = selectedList;
      _visible = true;
    });

    if (list == null) {
      // _incrementCounter();
    }
    userNameController.clear();
    setStateIfMounted(() {
      searchText = "";
    });
    // userNameController.addListener(() {
    // setStateIfMounted(() {
    // searchText = userNameController.text.toString();
    // count = count;
    // });
    // var c = 0;
    // for (int i = 0; i < list.length; i++) {
    //   if (list[i]
    //       .appName
    //       .toLowerCase()
    //       .contains(searchText.toString().toLowerCase())) {
    //     // c = c + 1;
    //   }
    // }

    // setStateIfMounted(() {
    //   count = count;
    //   selectedList = selectedList;
    // });
    // });
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
                  duration: Duration(milliseconds: 500),
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
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
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
                                    'No Connection...',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ));
                            case ConnectionState.active:
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
                                    'Connection Active...${snapshot.data}',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ));
                            case ConnectionState.waiting:
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

                            case ConnectionState.done:
                              switch (noAppsFound) {
                                case false:
                                  return ListView.builder(
                                      cacheExtent: 9999,
                                      itemCount: snapshot.data.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        if (snapshot.data[index]['appName']
                                            .toString()
                                            .toLowerCase()
                                            .contains(
                                                searchText.toLowerCase())) {
                                          count = count + 1;
                                          var icon = Uint8List.fromList(snapshot
                                              .data[index]['icon']
                                              .cast<int>());
                                          _controller1.forward();
                                          return FadeTransition(
                                              opacity: animation2,
                                              child: AppListGenerator(
                                                  icon: icon,
                                                  title: snapshot.data[index]
                                                      ['appName'],
                                                  packageName:
                                                      snapshot.data[index]
                                                          ['packageName']));
                                        } else {
                                          var nosearchResult = true;
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
                                          if (nosearchResult == true &&
                                              searchText != "") {
                                            WidgetsBinding.instance
                                                .addPostFrameCallback((_) {
                                              setStateIfMounted(() {
                                                noAppsFound = true;
                                                count = 0;
                                              });
                                            });
                                          }

                                          return Container(
                                            color: Colors.black,
                                          );
                                        }
                                      });
                                case true:
                                  return Container(
                                      child: Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              20, 40, 20, 0),
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
                                                    if (searchText
                                                            .contains('call') ||
                                                        searchText
                                                            .contains('+91') ||
                                                        isNumericUsingRegularExpression(
                                                            userNameController
                                                                .text)) {
                                                      _launchCaller(searchText);
                                                    } else {
                                                      _launchPlayStore(
                                                          searchText);
                                                    }
                                                  },
                                                  child: Text(
                                                    isNumericUsingRegularExpression(
                                                                userNameController
                                                                    .text) ||
                                                            searchText
                                                                .contains('+91')
                                                        ? searchText.contains(
                                                                'call')
                                                            ? '"$searchText" '
                                                            : 'call "$searchText" '
                                                        : searchText.contains(
                                                                    '.com') ||
                                                                userNameController
                                                                    .text
                                                                    .contains(
                                                                        'https')
                                                            ? 'open "$searchText" in browser.'
                                                            : 'search for "$searchText" in play store. ',
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 20,
                                                      fontFamily: 'Montserrat',
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )));
                              }
                              break;
                            default:
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
                                    'default...',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ));
                          }
                        })

                    // child: FutureBuilder(
                    //     future: list == null
                    //         ? Future.delayed(Duration(seconds: 2), () async {
                    //             if (loading == false) {
                    //               reset();
                    //               return getAppsList();
                    //             }
                    //           })
                    //         : Future.delayed(Duration(milliseconds: 400),
                    //             () async {
                    //             reset();
                    //             // _visible = true;
                    //             final prefs =
                    //                 await SharedPreferences.getInstance();
                    //             var menus = prefs.getString('menus');
                    //             if (loading == false) {
                    //               return await getUserInfo(menus);
                    //             }
                    //             // _visible = false;
                    //             // return await list;
                    //           }),
                    //     builder:
                    //         (BuildContext context, AsyncSnapshot snapshot) {
                    //       switch (snapshot.connectionState) {
                    //         case ConnectionState.none:
                    //           return Center(
                    //               child: Column(
                    //             mainAxisAlignment: MainAxisAlignment.center,
                    //             crossAxisAlignment: CrossAxisAlignment.center,
                    //             children: <Widget>[
                    //               Image.asset(
                    //                 'assets/images/dino.gif',
                    //                 height: 250,
                    //                 width: 250,
                    //                 fit: BoxFit.contain,
                    //               ),
                    //               Text(
                    //                 'No Connection...',
                    //                 style: TextStyle(
                    //                   color: Colors.white,
                    //                 ),
                    //               )
                    //             ],
                    //           ));
                    //         case ConnectionState.active:
                    //           return Center(
                    //               child: Column(
                    //             mainAxisAlignment: MainAxisAlignment.center,
                    //             crossAxisAlignment: CrossAxisAlignment.center,
                    //             children: <Widget>[
                    //               Image.asset(
                    //                 'assets/images/dino.gif',
                    //                 height: 250,
                    //                 width: 250,
                    //                 fit: BoxFit.contain,
                    //               ),
                    //               Text(
                    //                 'Connection Active...',
                    //                 style: TextStyle(
                    //                   color: Colors.white,
                    //                 ),
                    //               )
                    //             ],
                    //           ));
                    //         case ConnectionState.waiting:
                    //           return Center(
                    //               child: Column(
                    //             mainAxisAlignment: MainAxisAlignment.center,
                    //             crossAxisAlignment: CrossAxisAlignment.center,
                    //             children: <Widget>[
                    //               Image.asset(
                    //                 'assets/images/dino.gif',
                    //                 height: 250,
                    //                 width: 250,
                    //                 fit: BoxFit.contain,
                    //               ),
                    //               Text(
                    //                 'Connection waiting...',
                    //                 style: TextStyle(
                    //                   color: Colors.white,
                    //                 ),
                    //               )
                    //             ],
                    //           ));
                    //         case ConnectionState.done:
                    //           return Center(
                    //               child: Column(
                    //             mainAxisAlignment: MainAxisAlignment.center,
                    //             crossAxisAlignment: CrossAxisAlignment.center,
                    //             children: <Widget>[
                    //               Image.asset(
                    //                 'assets/images/dino.gif',
                    //                 height: 250,
                    //                 width: 250,
                    //                 fit: BoxFit.contain,
                    //               ),
                    //               Text(
                    //                 'Connection done...',
                    //                 style: TextStyle(
                    //                   color: Colors.white,
                    //                 ),
                    //               )
                    //             ],
                    //           ));
                    //         default:
                    //           return Center(
                    //               child: Column(
                    //             mainAxisAlignment: MainAxisAlignment.center,
                    //             crossAxisAlignment: CrossAxisAlignment.center,
                    //             children: <Widget>[
                    //               Image.asset(
                    //                 'assets/images/dino.gif',
                    //                 height: 250,
                    //                 width: 250,
                    //                 fit: BoxFit.contain,
                    //               ),
                    //               Text(
                    //                 'default...',
                    //                 style: TextStyle(
                    //                   color: Colors.white,
                    //                 ),
                    //               )
                    //             ],
                    //           ));
                    //       }
                    //     })
                    ),
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
                                    onChanged: (value) {
                                      // searchText = value;
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        _debouncer.run(() {
                                          setStateIfMounted(() {
                                            searchText = value;
                                            //   count = count;
                                            noAppsFound = false;
                                          });
                                        });
                                      });
                                    },
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
                                        // suffixIcon: IconButton(
                                        //   color: Colors.red,
                                        //   onPressed: () => {
                                        //     SchedulerBinding.instance
                                        //         .addPostFrameCallback((_) {
                                        //       focus.unfocus();
                                        //       setState(() {
                                        //         searchText = "";
                                        //         isListVisible = false;
                                        //         noAppsFound = false;
                                        //       });
                                        //       userNameController.clear();
                                        //       reset();
                                        //     }),
                                        //   },
                                        //   // userNameController.clear()},
                                        //   icon: Icon(
                                        //     Icons.clear,
                                        //     color: Colors.red,
                                        //   ),
                                        // )
                                        suffixIcon: userNameController.text !=
                                                ""
                                            ? IconButton(
                                                color: Colors.red,
                                                onPressed: () => {
                                                  SchedulerBinding.instance
                                                      .addPostFrameCallback(
                                                          (_) {
                                                    focus.unfocus();
                                                    setState(() {
                                                      searchText = "";
                                                      isListVisible = false;
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

                                    // InputDecoration(
                                    //   hintText: 'Please enter a search term',
                                    //   hintStyle: TextStyle(
                                    //     fontSize: 15.0,
                                    //     color: Colors.grey,
                                    //   ),
                                    //   prefixIcon: Icon(
                                    //     Icons.search,
                                    //     color: Colors.blueAccent,
                                    //   ),
                                    //   suffixIcon: searchText != ""
                                    //       ? IconButton(
                                    //           onPressed: () => {
                                    //             SchedulerBinding.instance
                                    //                 .addPostFrameCallback((_) {
                                    //               focus.unfocus();
                                    //               setState(() {
                                    //                 searchText = "";
                                    //                 isListVisible = false;
                                    //                 noAppsFound = false;
                                    //               });
                                    //               userNameController.clear();
                                    //               reset();
                                    //             }),
                                    //           },
                                    //           // userNameController.clear()},
                                    //           icon: Icon(
                                    //             Icons.clear,
                                    //             color: Colors.red,
                                    //           ),
                                    //         )
                                    //       : Container(),
                                    // ),

                                    controller: userNameController,
                                    keyboardType: TextInputType.emailAddress,
                                    onFieldSubmitted: (value) {
                                      //Validator
                                    },
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 25,
                                        fontFamily: 'Montserrat'),
                                  )
                                  // TextFormField(
                                  //   // onChanged: (value) {
                                  //   //   Future.delayed(Duration(milliseconds: 0),
                                  //   //       () {
                                  //   //     // setState(() {
                                  //   //     searchText = value;
                                  //   //     count = count;
                                  //   //     noAppsFound = false;
                                  //   //     // });
                                  //   //     reset();
                                  //   //   });
                                  //   // },
                                  //   focusNode: focus,
                                  //   decoration: InputDecoration(

                                  //     hintText: 'Please enter a search term',
                                  //     hintStyle: TextStyle(
                                  //       fontSize: 15.0,
                                  //       color: Colors.grey,
                                  //     ),
                                  //     prefixIcon: Icon(
                                  //       Icons.search,
                                  //       color: Colors.blueAccent,
                                  //     ),
                                  //     suffixIcon: userNameController.text != ""
                                  //         ? IconButton(
                                  //             onPressed: () => {
                                  //               SchedulerBinding.instance
                                  //                   .addPostFrameCallback((_) {
                                  //                 focus.unfocus();
                                  //                 setState(() {
                                  //                   searchText = "";
                                  //                   isListVisible = false;
                                  //                 });
                                  //                 userNameController.clear();
                                  //                 reset();
                                  //               }),
                                  //             },
                                  //             // userNameController.clear()},
                                  //             icon: Icon(
                                  //               Icons.clear,
                                  //               color: Colors.red,
                                  //             ),
                                  //           )
                                  //         : Container(),
                                  //   ),
                                  //   controller: userNameController,
                                  //   keyboardType: TextInputType.emailAddress,
                                  //   onFieldSubmitted: (value) {
                                  //     //Validator
                                  //   },
                                  //   style: TextStyle(
                                  //       color: Colors.white,
                                  //       fontSize: 25,
                                  //       fontFamily: 'Montserrat'),
                                  // )),
                                  ),
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
}

// class AppsList {
//   final String appName;
//   final String packageName;
//   final Uint8List icon;

//   AppsList(this.appName, this.packageName, this.icon);
// }

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

  const AppListGenerator({Key key, this.title, this.icon, this.packageName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget image = Image.memory(
      icon,
      height: 50,
      width: 50,
    );
    //  FadeInImage(
    //   placeholder: MemoryImage(icon),
    //   image: MemoryImage(icon),
    //   height: 50,
    //   width: 50,
    // );
    // FadeInImage(
    //   placeholder:
    // MemoryImage(icon),
    // image: MemoryImage(icon),
    // fadeInDuration: Duration(milliseconds: 50),
    // // fadeOutDuration: Duration(milliseconds: 50),
    // height: 50,
    // width: 50,
    // );

    // FadeInImage(
    //   placeholder: MemoryImage(icon),
    //   image: MemoryImage(icon),
    //   fadeInDuration: Duration(milliseconds: 50),
    //   // fadeOutDuration: Duration(milliseconds: 50),
    //   height: 50,
    //   width: 50,
    // );

    // Widget t = Image.memory(icon);

    return Column(children: [
      TouchableOpacity(
          onTap: () {
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
              duration: Duration(seconds: 5),
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
                  // activeOpacity: 0.4,
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
