import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import 'package:launcher/main.dart';
import 'package:touchable_opacity/touchable_opacity.dart';
import 'package:lodash_dart/lodash_dart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:battery/battery.dart';

var list = [];
var selectedList = [];
var iconsList = [];
var searchText = '';
var userNameController = new TextEditingController();
var count = 0;
getAppsData(packageName) async {}

_launchPlayStore(value) async {
  var url = "https://play.google.com/store/search?q=$value";
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

_launchCaller() async {
  const url = "tel:";
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

class HeaderSection extends StatelessWidget {
  final String title;
  final Uint8List icon;
  final packageName;
  const HeaderSection({Key key, this.title, this.icon, this.packageName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    count++;
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Padding(
          padding: EdgeInsets.all(10),
          child: TouchableOpacity(
              activeOpacity: 0.4,
              onTap: () {
                // bool isInstalled = await DeviceApps.isAppInstalled(packageName);
                // if (isInstalled) {
                var s = {
                  // 'icon': icon,
                  'packageName': packageName, 'title': title
                };

                // selectedList = [] ;
                // selectedList.map((element) {
                //   if(element['title'] == title){

                //   }
                // })
                if (selectedList.length > 5) {
                  selectedList.removeAt(0);
                }
                selectedList.add(s);
                final jsonList =
                    selectedList.map((item) => jsonEncode(item)).toList();

                // using toSet - toList strategy
                final uniqueJsonList = jsonList.toSet().toList();

                // convert each item back to the original form using JSON decoding
                final result =
                    uniqueJsonList.map((item) => jsonDecode(item)).toList();
                selectedList = [];
                selectedList.addAll(result);
                // if (!selectedList.map(s)) {

                // }
                if (packageName == "phone") {
                  _launchCaller();
                } else {
                  DeviceApps.openApp(packageName);
                }
                // }
              },
              child: Row(
                children: [
                  if (icon == null)
                    ConstrainedBox(
                      constraints:
                          BoxConstraints.tightFor(width: 60, height: 60),
                      child: ElevatedButton(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.phone,
                                      size: 25,
                                    ),
                                  ]),
                            ]),
                        onPressed: () {
                          _launchCaller();
                          //  UrlLauncher.launch("tel://<phone_number>");
                          // DeviceApps.openApp("com.android.incallui");
                        },
                        // DeviceApps.openApp('com.android.incallui'),
                        style:
                            // ElevatedButton.styleFrom(
                            //   shape: CircleBorder(),

                            // ),
                            ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          )),
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed))
                                return Colors.blueAccent;
                              return Colors
                                  .black; // Use the component's default.
                            },
                          ),
                        ),
                      ),
                    ),
                  if (icon != null)
                    ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.memory(
                          icon,
                          width: 50,
                          height: 50,
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
                  var s = {
                    icon: '',
                    'packageName': packageName,
                    'title': title
                  };
                  if (selectedList.length > 5) {
                    selectedList.removeAt(0);
                  }
                  selectedList.add(s);
                  final jsonList =
                      selectedList.map((item) => jsonEncode(item)).toList();

                  // using toSet - toList strategy
                  final uniqueJsonList = jsonList.toSet().toList();

                  // convert each item back to the original form using JSON decoding
                  final result =
                      uniqueJsonList.map((item) => jsonDecode(item)).toList();
                  selectedList = [];
                  selectedList.addAll(result);
                  if (packageName == "phone") {
                    _launchCaller();
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
      // color: Colors.red,
      // sty
    );
  }
}

// class SecondRoute extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         home: Scaffold(
//             body: SafeArea(
//       child: SingleChildScrollView(
//         child: Column(
//           children: <Widget>[
//             Container(
//               color: Colors.green, // Yellow
//               height: 120.0,
//             ),
//             for (var i in list)
//               HeaderSection(
//                 title: i,
//                 name: i,
//               ),
//             RaisedButton(
//               onPressed: () => getAppsData(),
//               child: Text('LOGIN'),
//             ),
//           ],
//         ),
//       ),
//     )));
//   }
// }

class SecondRoute extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'SPL Launcher', home: SecondRoutePage(title: 'SPL Launcher'));
  }
}

class SecondRoutePage extends StatefulWidget {
  SecondRoutePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _SecondRoutePage createState() => _SecondRoutePage();
}

final Battery _battery = Battery();

class _SecondRoutePage extends State<SecondRoutePage> {
  var listComplete = [];
  var loading = false;
  var lowBattery = false;
  get appName => null;
  get packageName => null;
  @override
  initState() {
    getAppsData('');
    userNameController.addListener(() {
      setState(() {
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

      setState(() {
        count = c;
        selectedList = selectedList;
      });

      // }
    });
    // getProfileData();
    super.initState();
  }

  @override
  void dispose() {
    // userNameController.dispose();
    super.dispose();
  }

  Future<void> getAppsData(value) async {
    List<Application> apps = await DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      includeSystemApps: true,
      onlyAppsWithLaunchIntent: true,
    );

    list = [];
    // iconsList = [];
    for (int i = 0; i < apps.length; i++) {
      Application app = apps[i];
      // if (app.appName.contains(value) || value == '') {
      list.add(app);
      // }
    }
    // list.add({appName: 'phone', packageName: 'phone'});

    list.sort((a, b) => a.appName
        .toString()
        .toLowerCase()
        .compareTo(b.appName.toString().toLowerCase()));

    setState(() {
      listComplete = list;
      selectedList = selectedList;
      count = 1;
      //print(_test1);
    });
  }

  // Future<bool> _navigateToBackPage(counter) async {
  //   Navigator.pop(counter);
  //   Route route = MaterialPageRoute(builder: (context) => CountingApp());
  //   Navigator.pushReplacement(context, route);
  //   return true;
  //   // Navigator.pop(counter);
  //   // Navigator.pop(
  //   //   context,
  //   //   MaterialPageRoute(builder: (context) => SecondRoute()),
  //   // );
  // }

  Future<bool> _willPopCallback(context) async {
    // await showDialog or Show add banners or whatever
    // then
    Route route = MaterialPageRoute(builder: (context) => CountingApp());
    Navigator.pushReplacement(context, route);
    return true; // return true if the route to be popped
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //     backgroundColor: Colors.black,
    //     body: Column(children: <Widget>[
    //       // Expanded(
    //       //   flex: 1,
    //       //   child: Container(),
    //       // ),
    //       Expanded(
    //           flex: 1,
    //           child: Container(
    //               width: double.infinity,
    //               child: SingleChildScrollView(
    //                   child: Column(children: <Widget>[
    //                 // FloatingActionButton(
    //                 //   heroTag: null,
    //                 //   onPressed: () => {},
    //                 //   tooltip: 'press me',
    //                 //   child: Icon(Icons.add),
    //                 // ),
    //                 Column(
    //                     mainAxisAlignment: MainAxisAlignment.start,
    //                     crossAxisAlignment: CrossAxisAlignment.start,
    //                     children: [
    //                       Expanded(
    //                         flex: 1,
    //                         child: Container(
    //                             child: Column(
    //                           children: [
    //
    //
    //                                 ],
    //                               ),
    //                             )
    //                           ],
    //                         )),
    //                       )
    //                     ])
    //               ]))))
    //     ]));

    return WillPopScope(
        // onWillPop: () => Navigator.pop(, true),
        onWillPop: () => _willPopCallback(context),

        // showDialog<bool>(
        //     context: context,
        //     builder: (c) => AlertDialog(
        //           title: Text('Warning'),
        //           content: Text('Do you really want to exit'),
        //           actions: [
        //             FlatButton(
        //               child: Text('Yes'),
        //               onPressed: () => {
        //                 _navigateToBackPage(c)
        //                 // Navigator.push(
        //                 //   context,
        //                 //   MaterialPageRoute(
        //                 //       builder: (context) => CountingApp()),
        //                 // )
        //               },
        //             ),
        //             FlatButton(
        //               child: Text('No'),
        //               onPressed: () => Navigator.pop(c, false),
        //             ),
        //           ],
        //         )
        // ),

        child: Scaffold(
            backgroundColor: Colors.black,
            body: Column(children: <Widget>[
              if (searchText != "" && count == 0)
                Expanded(
                    flex: 3,
                    child: Container(
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
                            child: Center(
                              child: TouchableOpacity(
                                onTap: () {
                                  _launchPlayStore(userNameController.text);
                                },
                                child: Text(
                                  'search for ${userNameController.text} in play store. ',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 20,
                                    fontFamily: 'Montserrat',
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            )))),
              if (list.length == 0)
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
              if (count != 0)
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
                              // Row(
                              //   crossAxisAlignment: CrossAxisAlignment.center,
                              //   mainAxisAlignment:
                              //       MainAxisAlignment.spaceBetween,
                              //   children: <Widget>[
                              //     Text(
                              //       'ff',
                              //       style: TextStyle(color: Colors.white),
                              //     ),
                              //     Text(
                              //       'ff',
                              //       style: TextStyle(color: Colors.white),
                              //     )
                              //   ],
                              // ),
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
                                    // onChanged: (value) => {count = 0},
                                    // onChanged: (value) => {
                                    //   // searchText = value,
                                    //   setState(() {
                                    //     // listComplete = list;
                                    //     searchText = value;
                                    //     //print(_test1);
                                    //   })
                                    //   // getAppsData(value)
                                    // },
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontFamily: 'Montserrat'),
                                    // validator: (value) {
                                    //   if (value.isEmpty ||
                                    //       !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    //           .hasMatch(value)) {
                                    //     return 'Enter a valid email!';
                                    //   }
                                    //   return null;
                                    // },
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
                              )
                              //       ListView(
                              // // This next line does the trick.
                              // scrollDirection: Axis.horizontal,
                              // children: <Widget>[
                              //   Container(
                              //     width: 160.0,
                              //     color: Colors.red,
                              //   ),
                              //   Container(
                              //     width: 160.0,
                              //     color: Colors.blue,
                              //   ),
                              //   Container(
                              //     width: 160.0,
                              //     color: Colors.green,
                              //   ),
                              //   Container(
                              //     width: 160.0,
                              //     color: Colors.yellow,
                              //   ),
                              //   Container(
                              //     width: 160.0,
                              //     color: Colors.orange,
                              //   ),
                              // ])
                            ],
                          ),
                        ),
                      ])),
            ])));
  }
}
