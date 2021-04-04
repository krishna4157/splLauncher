// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:device_apps/device_apps.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:launcher/main.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touchable_opacity/touchable_opacity.dart';
import 'package:url_launcher/url_launcher.dart';

var list;
var searchText = "";
var selectedList = [];
var loading = false;
var userNameController = new TextEditingController();
var count = 0;

bool isNumericUsingRegularExpression(String string) {
  final numericRegex = RegExp(r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');

  return numericRegex.hasMatch(string);
}

_launchPlayStore(value) async {
  var url;
  if (value.contains('.com')) {
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
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
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
  SharedPreferencesDemoState createState() => SharedPreferencesDemoState();
}

class SharedPreferencesDemoState extends State<SharedPreferencesDemo> {
  Future<List<AppsList>> genCode() {
    return getAppsList();
  }

  Future<List<AppsList>> getAppsList() async {
    if (list == null) {
      Future<List<AppInfo>> apps =
          InstalledApps.getInstalledApps(false, true, "");

      List<AppsList> futureList = [];
      var appsList = await apps;
      for (var i in appsList) {
        bool isSystemApp = await InstalledApps.isSystemApp(i.packageName);

        if (isSystemApp && i.name.toLowerCase() == 'phone' || !isSystemApp) {
          AppsList appsLists = AppsList(i.name, i.packageName, i.icon);
          futureList.add(appsLists);
        }
      }

      futureList.sort((a, b) => a.name
          .toString()
          .toLowerCase()
          .compareTo(b.name.toString().toLowerCase()));

      setStateIfMounted(() {
        list = futureList;
        loading = false;
      });
      print(list.length);
      return futureList;
    } else {
      return list;
    }
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<Map> _list;

  @override
  void initState() {
    super.initState();
    setStateIfMounted(() {
      selectedList = selectedList;
    });
    if (list == null) {
      // _incrementCounter();
    }
    userNameController.clear();
    setStateIfMounted(() {
      searchText = "";
    });
    userNameController.addListener(() {
      setStateIfMounted(() {
        searchText = userNameController.text.toString();
        count = count;
      });
      var c = 0;
      for (int i = 0; i < list.length; i++) {
        if (list[i]
            .name
            .toLowerCase()
            .contains(searchText.toString().toLowerCase())) {
          c = c + 1;
        }
      }

      setStateIfMounted(() {
        count = c;
        selectedList = selectedList;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
        // Show a red background as the item is swiped away.
        background: CountingApp(),
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
                    child: FutureBuilder(
                        future: list == null
                            ? Future.delayed(Duration(seconds: 2), () async {
                                return getAppsList();
                              })
                            : Future.delayed(Duration(seconds: 0), () async {
                                return await list;
                              }),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.data == null) {
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
                                  'Loading...',
                                  style: TextStyle(color: Colors.white),
                                )
                              ],
                            ));
                          } else {
                            return ListView.builder(
                                itemCount: snapshot.data.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (snapshot.data[index].name
                                      .toString()
                                      .toLowerCase()
                                      .contains(userNameController.text
                                          .toLowerCase())) {
                                    return HeaderSection(
                                        icon: snapshot.data[index].icon,
                                        title: snapshot.data[index].name,
                                        packageName:
                                            snapshot.data[index].packageName);
                                  } else {
                                    return Container();
                                  }
                                });
                          }
                        })),
              ),
              if (searchText != "" && count == 0)
                Expanded(
                    child: Container(
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
                            child: Center(
                              child: TouchableOpacity(
                                onTap: () {
                                  if ((userNameController.text.contains('91') ||
                                          userNameController.text.length >
                                              10) ||
                                      userNameController.text
                                          .contains('call') ||
                                      isNumericUsingRegularExpression(
                                          userNameController.text)) {
                                    _launchCaller(userNameController.text);
                                  } else {
                                    _launchPlayStore(userNameController.text);
                                  }
                                },
                                child: Text(
                                  ((userNameController.text.contains('91') ||
                                                  isNumericUsingRegularExpression(
                                                      userNameController
                                                          .text)) ||
                                              userNameController.text.length >
                                                  10) ||
                                          userNameController.text
                                              .contains('call')
                                      ? userNameController.text.contains('call')
                                          ? '"${userNameController.text}" '
                                          : 'call "${userNameController.text}" '
                                      : userNameController.text.contains('.com')
                                          ? 'open "${userNameController.text}" in browser.'
                                          : 'search for "${userNameController.text}" in play store. ',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 20,
                                    fontFamily: 'Montserrat',
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            )))),
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
                                    decoration: InputDecoration(
                                        suffixIcon: IconButton(
                                          onPressed: () =>
                                              {userNameController.clear()},
                                          icon: Icon(Icons.clear),
                                        ),
                                        hintText: 'Please enter a search term',
                                        hintStyle: TextStyle(
                                          fontSize: 15.0,
                                          color: Colors.grey,
                                        )),
                                    controller: userNameController,
                                    keyboardType: TextInputType.emailAddress,
                                    onFieldSubmitted: (value) {
                                      //Validator
                                    },
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
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
                                        RoundedButtons(
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

class AppsList {
  final String name;
  final String packageName;
  final Uint8List icon;

  AppsList(this.name, this.packageName, this.icon);
}

class HeaderSection extends StatelessWidget {
  final String title;
  final Uint8List icon;
  final packageName;

  const HeaderSection({Key key, this.title, this.icon, this.packageName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          child: Container(
              color: Colors.black,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      new Container(),
                      ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: FadeInImage(
                            placeholder: MemoryImage(icon),
                            image: MemoryImage(icon),
                            fadeInDuration: Duration(milliseconds: 700),
                            height: 50,
                            width: 50,
                          )),
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
class RoundedButtons extends StatelessWidget {
  final String title;
  final packageName;

  bool isPackageIncluded;
  RoundedButtons({Key key, this.title, this.packageName}) : super(key: key);
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
