import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:Smart_Power_Launcher/AtoZSlider.dart';
import 'package:Smart_Power_Launcher/main.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

// void main() => runApp(MainApp());
var list = [];
Timer timer;

class User {
  final String name;
  final String company;
  final bool favourite;

  User(this.name, this.company, this.favourite);
}

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
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

class _MainAppState extends State<MainApp> with TickerProviderStateMixin {
  List<User> userList = [];
  List strList = [];
  var loading = true;
  List<Widget> favouriteList = [];
  List<Widget> normalList = [];
  TextEditingController searchController = TextEditingController();
  AnimationController _controller1;
  Animation<double> animation2;

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  getAppsList() async {
    final prefs = await SharedPreferences.getInstance();
    var menus = prefs.getString('menus');
    var removedAppName = prefs.getString('removedAppName');
    var newApp = prefs.getString('newApp');
    var newAppIndex = prefs.getInt('newAppIndex');

    if (menus == null) {
      Future<List<Application>> apps = DeviceApps.getInstalledApplications(
          includeAppIcons: true, includeSystemApps: true);
      List<AppsList> futureList = [];
      var appsList = await apps;
      for (var i in appsList) {
        bool isSystemApp = i.apkFilePath.contains("/data/app/") ? false : true;
        if (i.appName.toLowerCase() == 'gallery' ||
            isSystemApp && i.appName.toLowerCase() == 'phone' ||
            !isSystemApp) {
          AppsList appsLists = AppsList(i.appName, i.packageName,
              i is ApplicationWithIcon ? i.icon : null);
          appsLists.icon = Uint8List.fromList(appsLists.icon.cast<int>());
          futureList.add(appsLists);
        }
      }

      futureList.sort((a, b) => a.appName
          .toString()
          .toLowerCase()
          .compareTo(b.appName.toString().toLowerCase()));

      var v;
      var z =
          await prefs.setString('menus', jsonEncode(futureList)).then((value) {
        menus = prefs.getString('menus');
        return menus;
      });
      menus = z;
      v = getUserInfo(menus);

      var storedList = await v;
      // var w = await getUserInfo(storedList);
      storedList.forEach((element) {
        element['icon'] = Uint8List.fromList(element['icon'].cast<int>());
      });
      setStateIfMounted(() {
        strList = storedList;
        list = storedList;
        loading = false;
      });
    } else {
      var menus = prefs.getString('menus');
      // var strList = prefs.getString('strList');
      var v = await getUserInfo(menus);
      if (removedAppName != null && removedAppName != "") {
        strList.clear();
        setStateIfMounted(() {
          loading = true;
        });
        v.removeWhere((element) => element['appName'] == removedAppName);
        await prefs.setString('menus', jsonEncode(v));
        prefs.setString('removedAppName', "");
      }

      if (newApp != null && newApp != "") {
        strList.clear();
        setStateIfMounted(() {
          loading = true;
        });

        // var decodedNewApp = await getUserInfo(newApp);
        var d = await jsonDecode(newApp);
        // print(d);
        var e = {
          'appName': d['appName'],
          'packageName': d['packageName'],
          'icon': d['icon']
        };
        print(e);
        var index = v.indexWhere((element) =>
            element['appName'].toLowerCase().toString() ==
            d['appName'].toLowerCase().toString());
        if (index == -1) {
          v.insert(newAppIndex, e);
        }
        await prefs.setString('menus', jsonEncode(v));
        prefs.setString('newApp', "");
        prefs.setInt('newAppIndex', 0);
      }

      v.forEach((element) {
        element['icon'] = Uint8List.fromList(element['icon'].cast<int>());
      });
      setStateIfMounted(() {
        list = v;
        strList = v;
        loading = false;
      });
    }

    Future.delayed(Duration(milliseconds: 500), () {
      _controller1.forward();
    });
  }

  @override
  void initState() {
    getAppsList();
    searchController.addListener(() {});
    super.initState();
    startTimer();
    _controller1 = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    animation2 = Tween<double>(begin: 0.0, end: 1.0).animate(_controller1)
      ..addListener(() {
        // print('hello');
      });
  }

  startTimer() async {
    timer =
        Timer.periodic(Duration(seconds: 1), (Timer t) => checkLoadingStatus());
  }

  checkLoadingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    var loading = prefs.getBool('isRecentAppInstalled');
    while (loading == true) {
      setStateIfMounted(() {
        loading = true;
      });
      getAppsList();
      await prefs.setBool('isRecentAppInstalled', false);
      setStateIfMounted(() {
        loading = false;
      });
      break;
    }
    // break;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (strList.length != 0 && loading == false) {
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
          child: MaterialApp(
              home: Scaffold(
                  backgroundColor: Colors.black,
                  body: FadeTransition(
                      opacity: animation2,
                      child: Padding(
                          padding: EdgeInsets.fromLTRB(5, 30, 0, 0),
                          child: new AtoZSlider(
                              strList,
                              (i) => {
                                    debugPrint("Click on : (" +
                                        i.toString() +
                                        ") -> " +
                                        strList[i].appName)
                                  },
                              (word) =>
                                  {debugPrint("SearchWord: " + word)}))))));
    } else {
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
          child: Center(
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
                  fontSize: 18,
                  color: Colors.white,
                ),
              )
            ],
          )));
    }
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
