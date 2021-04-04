import 'dart:async';
import 'dart:ui';

import 'package:device_apps/device_apps.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'newPage.dart';
import 'package:intent/intent.dart' as android_intent;
import 'package:intent/action.dart' as android_action;
import 'package:url_launcher/url_launcher.dart';
// import 'package:hardware_buttons/hardware_buttons.dart';

StreamSubscription _volumeButtonSubscription;

void main() {
  runApp(MaterialApp(home: CountingApp(), // becomes the route named '/'
      routes: <String, WidgetBuilder>{
        '/secondRoute': (BuildContext context) => SecondRoute(),
      }));
}

// _launchURL() async {
//   // Replace 12345678 with your tel. no.
//   DeviceApps.openApp("com.android.incallui");
//   // android_intent.Intent()
//   //   ..setAction(android_action.Action.ACTION_CALL)
//   //   ..setData(Uri(scheme: "tel", path: "12345678"))
//   //   ..startActivity().catchError((e) => print(e));
// }

_launchCaller() async {
  const url = "tel:";
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
  var _formKey = GlobalKey<FormState>();
  Animation<double> animation;
  AnimationController controller;
  Animation<double> animation2;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  Future<void> _showMyDialog(counter) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('SUCCESS'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(''),
                Text('do you want to save these details ?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToNewPage(counter);
              },
            ),
            TextButton(
              child: Text('Deny'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  void _submit({int counter}) {
    // final isValid = _formKey.currentState.validate();
    // if (!isValid) {
    //   return;
    // }
    // Navigator.of(context).pop();
    _navigateToNewPage(counter);
    // _showMyDialog(counter);

    // _formKey.currentState.save();
  }

  void _navigateToNewPage(counter) {
    // _showMyDialog(counter);
    // Future.delayed(Duration(seconds: 10), () {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.bottomToTop,
            duration: Duration(milliseconds: 300),
            child: SecondRoute()));
    // });

    // MaterialPageRoute(builder: (context) {
    //   return SecondRoute();
    // }),
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  @override
  void initState() {
    super.initState();
    // _volumeButtonSubscription =
    //     volumeButtonEvents.listen((VolumeButtonEvent event) {
    //   // do something
    //   // event is either VolumeButtonEvent.VOLUME_UP or VolumeButtonEvent.VOLUME_DOWN
    // });
    controller =
        AnimationController(duration: const Duration(seconds: 7), vsync: this);
    // #docregion addListener
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

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
    _volumeButtonSubscription?.cancel();
  }

  remainSamePage() async {
    return false;
    // Route route = MaterialPageRoute(builder: (context) => CountingApp());
    // Navigator.pushReplacement(context, route);
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

    TextEditingController userNameController = new TextEditingController();
    TextEditingController passwordController = new TextEditingController();

    return WillPopScope(
        // ignore: missing_return
        onWillPop: () {},

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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ConstrainedBox(
                            constraints:
                                BoxConstraints.tightFor(width: 60, height: 60),
                            child: ElevatedButton(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
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

                          //menu button
                          ConstrainedBox(
                            constraints:
                                BoxConstraints.tightFor(width: 50, height: 50),
                            child: ElevatedButton(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                  ]),
                              onLongPress: () => DeviceApps.openApp(
                                  "com.google.android.apps.googleassistant"),
                              onPressed: () => _submit(counter: _counter),
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                )),
                                backgroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                    if (states.contains(MaterialState.pressed))
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
                            constraints:
                                BoxConstraints.tightFor(width: 50, height: 50),
                            child: ElevatedButton(
                              onPressed: () {
                                _textMe();
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[Icon(Icons.message)],
                              ),
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                )),
                                backgroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                    if (states.contains(MaterialState.pressed))
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
            ));
  }
}
