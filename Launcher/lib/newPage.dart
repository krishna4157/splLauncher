// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';

import 'package:device_apps/device_apps.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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
  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<Map> _list;

  Future<void> _incrementCounter() async {
    final SharedPreferences prefs = await _prefs;
    // final var list = (prefs.getInt('list') ?? 0) + 1;
    setStateIfMounted(() {
      loading = true;
    });
    Future<List<Application>> apps = DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      includeSystemApps: true,
    );

    list = [];
    // iconsList = [];
    var appsList = await apps;
    for (int i = 0; i < appsList.length; i++) {
      Application app = appsList[i];
      if (app.apkFilePath.contains('/data/app') ||
          app.apkFilePath.contains('/system/priv-app')) {
        if (!app.appName.contains('com.')) {
          list.add(app);
        }
        // }
      }
    }

    list.sort((a, b) => a.appName
        .toString()
        .toLowerCase()
        .compareTo(b.appName.toString().toLowerCase()));

    setStateIfMounted(() {
      list = list;
      loading = false;
    });

    // var tempList = new List<String>.from(list);

    // setStateIfMounted(() {
    // _list = prefs.setStringList("list", tempList).then((bool success) {
    //   return _list;
    //   // });
    // });
  }

  @override
  void initState() {
    super.initState();
    setStateIfMounted(() {
      selectedList = selectedList;
    });
    if (list == null) {
      _incrementCounter();
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
            .appName
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
                  type: PageTransitionType.bottomToTop,
                  duration: Duration(seconds: 1),
                  child: CountingApp()));
        },
        child: Scaffold(
            backgroundColor: Colors.black,
            body: Column(children: <Widget>[
              if (loading == false)
                Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
                          child: Column(
                            children: <Widget>[
                              for (var i in list)
                                if (i.appName.toLowerCase().contains(
                                    searchText.toString().toLowerCase()))
                                  HeaderSection(
                                      title: i.appName,
                                      icon: i.icon,
                                      packageName: i.packageName),
                            ],
                          ),
                        ),
                      ),
                    )),
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
              if (loading == true)
                Expanded(
                  flex: 5,
                  child: Container(
                    child: Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                          ]),
                    ),
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
                            // height: 10,
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
                                  // margin: EdgeInsets.symmetric(vertical: 10.0),
                                  height: selectedList.length > 0 ? 60.0 : 0,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: <Widget>[
                                      for (var i in selectedList)
                                        RoundedButtons(
                                          title: i['title'],
                                          // icon: i.icon,
                                          packageName: i['packageName'],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ]))
                      ])),
            ])));
  }
}

class HeaderSection extends StatelessWidget {
  final String title;
  final Uint8List icon;
  final packageName;

  const HeaderSection({Key key, this.title, this.icon, this.packageName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Padding(
          padding: EdgeInsets.all(10),
          child: TouchableOpacity(
              activeOpacity: 0.4,
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
                // if (!selectedList.map(s)) {
                // Navigator.of(context).pop();
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
              )))
    ]);
  }
}

class RoundedButtons extends StatelessWidget {
  final String title;
  // final Uint8List icon;
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
