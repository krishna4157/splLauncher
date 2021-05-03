import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:Smart_Power_Launcher/AtoZSlider.dart';
import 'package:Smart_Power_Launcher/main.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

// void main() => runApp(AppsDrawer());
// var list = [];
Timer timer;

class AppsDrawer extends StatefulWidget {
  @override
  _AppsDrawerState createState() => _AppsDrawerState();
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

class _AppsDrawerState extends State<AppsDrawer> with TickerProviderStateMixin {
  var loading = true;
  var powerSavingMode = 'off';
  List<Widget> favouriteList = [];
  List<Widget> normalList = [];
  TextEditingController searchController = TextEditingController();
  AnimationController _controller1;
  Animation<double> animation2;
  var v;
  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  getAppsList() async {
    final prefs = await SharedPreferences.getInstance();
    var menus = prefs.getString('menus');
    // var newApp = prefs.getString('newApp');
    // var newAppIndex = prefs.getInt('newAppIndex');

    if (menus == null || menus == "null") {
      Future<List<Application>> apps = DeviceApps.getInstalledApplications(
          includeAppIcons: true, includeSystemApps: true);
      List<AppsList> futureList = [];
      var appsList = await apps;
      for (var i in appsList) {
        // bool isSystemApp = i.apkFilePath.contains("/data/app/") ? false : true;
        // if (i.appName.toLowerCase() == 'gallery' ||
        //     isSystemApp && i.appName.toLowerCase() == 'phone' ||
        //     !isSystemApp) {
        AppsList appsLists = AppsList(
            i.appName, i.packageName, i is ApplicationWithIcon ? i.icon : null);
        appsLists.icon = Uint8List.fromList(appsLists.icon.cast<int>());
        bool isSystemApp = await InstalledApps.isSystemApp(i.packageName);
        // if (i.appName.contains("2")) {
        //   print(isSystemApp);
        // }
        if (isSystemApp == false || i.appName.toLowerCase() == "phone") {
          futureList.add(appsLists);
        }
        // }
      }

      futureList.sort((a, b) => a.appName
          .toString()
          .toLowerCase()
          .compareTo(b.appName.toString().toLowerCase()));

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
        // list = storedList;
        loading = false;
      });
    } else {
      if (strList.length == 0) {
        var menus = prefs.getString('menus');
        // var strList = prefs.getString('strList');
        v = await getUserInfo(menus);

        // if (newApp != null && newApp != "") {
        //   strList.clear();
        //   setStateIfMounted(() {
        //     loading = true;
        //   });

        //   // var decodedNewApp = await getUserInfo(newApp);
        //   var d = await jsonDecode(newApp);
        //   // print(d);
        //   var e = {
        //     'appName': d['appName'],
        //     'packageName': d['packageName'],
        //     'icon': Uint8List.fromList(d['icon'].cast<int>())
        //   };
        //   // print(e);
        //   var index = strList.indexWhere((element) =>
        //       element['appName'].toLowerCase().toString() ==
        //       d['appName'].toLowerCase().toString());
        //   if (index == -1) {
        //     strList.insert(newAppIndex, e);
        //     await prefs.setString('menus', jsonEncode(strList));
        //     prefs.setString('newApp', "");
        //     prefs.setInt('newAppIndex', 0);
        //   }
        // }
        // if (strList.length == 0) {
        v.forEach((element) {
          element['icon'] = Uint8List.fromList(element['icon'].cast<int>());
        });
        setStateIfMounted(() {
          strList = v;
          loading = false;
        });
        // } else {
        // setStateIfMounted(() {
        //   // strList = v;
        //   loading = false;
        // });
        // }
      } else {
        // strList.clear();
        // setStateIfMounted(() {
        //   strList = strList;
        // });
        // if (removedAppName != null && removedAppName != "") {
        //   strList.clear();
        //   setStateIfMounted(() {
        //     loading = true;
        //   });
        //   strList
        //       .removeWhere((element) => element['appName'] == removedAppName);
        //   await prefs.setString('menus', jsonEncode(v));
        //   prefs.setString('removedAppName', "");
        //   setState(() {
        //     strList = strList;
        //   });
        // }

        // if (strList.length == 0) {

      }
    }

    // Future.delayed(Duration(milliseconds: 400), () {
    //   _controller1.forward();
    // });
  }

  checkInstalledAppsList() async {
    final prefs = await SharedPreferences.getInstance();
    var menus = prefs.getString('menus');
    var removedAppName = prefs.getString('removedAppName');
    var newApp = prefs.getString('newApp');
    var newAppIndex = prefs.getInt('newAppIndex');

    if (newApp != null && newApp != "") {
      // strList.clear();
      setStateIfMounted(() {
        loading = true;
      });

      // var decodedNewApp = await getUserInfo(newApp);
      var d = await jsonDecode(newApp);
      // print(d);
      var e = {
        'appName': d['appName'],
        'packageName': d['packageName'],
        'icon': Uint8List.fromList(d['icon'].cast<int>())
      };
      // print(e);
      var index = strList.indexWhere((element) =>
          element['appName'].toLowerCase().toString() ==
          d['appName'].toLowerCase().toString());
      if (index == -1) {
        strList.insert(newAppIndex, e);
      }
      // strList = v;
      await prefs.setString('menus', jsonEncode(strList));
      await prefs.setString('newApp', "");
      await prefs.setInt('newAppIndex', 0);

      v.forEach((element) {
        element['icon'] = Uint8List.fromList(element['icon'].cast<int>());
      });
      setStateIfMounted(() {
        loading = false;
        strList = strList;
      });
    }

    if (removedAppName != null && removedAppName != "") {
      setStateIfMounted(() {
        loading = true;
      });
      //
      v = await getUserInfo(menus);

      strList.removeWhere((element) => element['appName'] == removedAppName);
      v.removeWhere((element) => element['appName'] == removedAppName);
      var t = await prefs.setString('menus', jsonEncode(v));
      var t1 = await prefs.setString('removedAppName', "");
      print(t);
      print(t1);
      setState(() {
        strList = strList;
        loading = false;
      });
    }
  }

  updateAppsList() async {
    Stream<ApplicationEvent> apps = await DeviceApps.listenToAppsChanges();
    print(apps);
  }

  setPowerSavingModeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    batterySaverMode = prefs.getString('BatterySaverMode');
    setStateIfMounted(() {
      powerSavingMode = batterySaverMode;
    });
  }

  @override
  void initState() {
    // updateAppsList();
    setPowerSavingModeStatus();
    if (strList.length == 0) {
      getAppsList();
    }

    // checkInstalledAppsList();

    searchController.addListener(() {});
    super.initState();
    startTimer();
    _controller1 = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    animation2 = Tween<double>(begin: 0.0, end: 1.0).animate(_controller1)
      ..addListener(() {
        // print('hello');
      });
    setStateIfMounted(() {
      loading = false;
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
      checkInstalledAppsList();
      await prefs.setBool('isRecentAppInstalled', false);
      await prefs.setBool('loading', false);
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
      Future.delayed(Duration(milliseconds: 50), () {
        _controller1.forward();
      });
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
                      // opacity: animation2,
                      child: Padding(
                          padding: EdgeInsets.fromLTRB(5, 30, 0, 0),
                          child: AtoZSlider(
                              strList,
                              (i) => {
                                    debugPrint("Click on : (" +
                                        i.toString() +
                                        ") -> " +
                                        strList[i].appName)
                                  },
                              (word) => {debugPrint("SearchWord: " + word)},
                              powerSavingMode))))));
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
                'Loading',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    decorationStyle: TextDecorationStyle.dashed),
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
