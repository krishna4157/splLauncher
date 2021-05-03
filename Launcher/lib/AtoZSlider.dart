import 'dart:math';
import 'dart:typed_data';

// import 'package:Smart_Power_Launcher/newPage.dart';
import 'package:Smart_Power_Launcher/main.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:diacritic/diacritic.dart';
import 'package:page_transition/page_transition.dart';
import 'package:touchable_opacity/touchable_opacity.dart';
import 'package:url_launcher/url_launcher.dart';

var userNameController = new TextEditingController();
var noAppsFound = false;
var selectedList = [];
var color;
// var powerSavingMode;

// ignore: must_be_immutable
class AtoZSlider extends StatefulWidget {
  List items;
  var callbackitemclick;
  var callbacksearchchange;
  var powerSavingMode;

  AtoZSlider(items, callbackitemclick, callbacksearchchange, powerSavingMode) {
    this.items = items;
    this.powerSavingMode = powerSavingMode;
    this.items.sort((a, b) =>
        removeDiacritics(a['appName'].toString().toUpperCase()).compareTo(
            removeDiacritics(b['appName'].toString().toUpperCase())));
    this.callbackitemclick = callbackitemclick;
    this.callbacksearchchange = callbacksearchchange;
  } // prend une liste en param
/*
  void setItems(aca) // to easy set new item
  {
    this.items = aca;
    forceSort();
  }
  void forceSort() {
    this.items.sort((a, b) => removeDiacritics(a.toString().toUpperCase())
        .compareTo(removeDiacritics(b.toString().toUpperCase())));
  }
*/ //NOTE: not used
  @override
  _AtoZSlider createState() => new _AtoZSlider();
}

class _AtoZSlider extends State<AtoZSlider> {
  double _offsetContainer;
  double _heightscroller;
  var _itemscache;
  var _text;
  var _searchtext;
  var _oldtext;
  var _alphabet;
  var _customscrollisscrolling;
  var _itemsizeheight;
  var _itemfontsize;
  var _animationcounter; //wait end of all animations
  var _sizeheightcontainer;
  var _sizefirstitem;
  //
  //var _lastoffset; //NOTE: [TO UNCOMMENT TO ADD THE GOING DOWNWARD CHANGING LETTER]
  ScrollController _scrollController;
  FocusNode _focusNode;

  FocusNode focusOnButton;

  void onscrolllistview() {
    if (!_customscrollisscrolling && _animationcounter == 0) {
      var indexFirst =
          ((_scrollController.offset / _itemsizeheight) % _itemscache.length)
              .floor();
      /*if (_scrollController.offset > _lastoffset) //Go downward //NOTE: [TO UNCOMMENT TO ADD THE GOING DOWNWARD CHANGING LETTER] (all block)
      {
        var indexLast =
            ((((_heightscroller * _alphabet.length) / _itemsizeheight).floor() +
                        indexFirst) -
                    1) %
                _itemscache.length;
        var fletter = _itemscache[indexLast].toString().toUpperCase()[0];
        var i = _alphabet.indexOf(fletter);
        if (i != -1) {
          setState(() {
            _text = _alphabet[i];
            _offsetContainer = i * _heightscroller;
          });
        }
      } else //Go upward
      {*/
      var fletter =
          _itemscache[indexFirst]['appName'].toString().toUpperCase()[0];
      var i = _alphabet.indexOf(fletter);
      if (i != -1) {
        setState(() {
          _text = _alphabet[i];
          _offsetContainer = i * _heightscroller;
        });
      }
      //}
      // _lastoffset = _scrollController.offset; //NOTE: [TO UNCOMMENT TO ADD THE GOING DOWNWARD CHANGING LETTER]
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

  void onsearchtextchange(text) {
    if (text.length > 0) {
      try {
        RegExp regs = new RegExp(text);
        _itemscache.clear();
        for (var element in widget.items) {
          if (regs.hasMatch(element['appName'].toString().toLowerCase())) {
            _itemscache.add(element);
          }
        }
        if (_itemscache.length == 0 && text.length != "") {
          noAppsFound = true;
          setState(() {});
        } else {
          setState(() {});
          noAppsFound = false;
        }
        setState(() {
          noAppsFound = noAppsFound;
          _searchtext = text;
          _scrollController.jumpTo(0.0);
        });
        widget.callbacksearchchange(text);
      } catch (e) {
        debugPrint("coucou");
      } //regex error
    } else if (text.length != _searchtext.length) {
      setState(() {
        _searchtext = text;
        _itemscache = List.from(widget.items);
      });
    }
  }

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

  void reset() {
    setState(() {
      _searchtext = "";
      _itemscache = List.from(widget.items);
    });
    userNameController.clear();
    widget.callbacksearchchange("");
  }

  void onfocustextfield() {
    setState(() {});
  }

  void onItemClick(index) {
    setState(() {
      FocusScope.of(context).requestFocus(new FocusNode());
    }); //NOTE: unfocus search when you click on listview
    for (var i = 0; i < widget.items.length; i++) {
      if (widget.items[i]['appName'] == _itemscache[index]['appName']) {
        index = i;
        break;
      }
    }
    widget.callbackitemclick(index);
  }

  @override
  void dispose() {
    super.dispose();
    userNameController.clear();
    FocusScope.of(context).unfocus();
    // userNameController.clear();
  }

  @override
  void initState() {
    super.initState();
    _itemscache =
        List.from(widget.items); //NOTE: copy of original items for search
    _customscrollisscrolling = false;
    _offsetContainer = 0.0;
    _animationcounter = 0;
    _searchtext = "";
    _itemsizeheight = 60.0; //NOTE: size items
    _itemfontsize = 25.0; //NOTE: fontsize items
    _sizefirstitem = 80.0; //NOTE: size of the container above
    //_lastoffset = 0.0; //NOTE: [TO UNCOMMENT TO ADD THE GOING DOWNWARD CHANGING LETTER]
    _sizeheightcontainer = 0.0;
    _focusNode = FocusNode();
    _focusNode.addListener(onfocustextfield);
    _scrollController = ScrollController();
    _scrollController.addListener(onscrolllistview);
    _alphabet = new List<String>();
    for (var i = 0; i < _itemscache.length; i++) {
      if (_itemscache[i].toString().trim().length > 0) {
        var fletter = removeDiacritics(
            _itemscache[i]['appName'].toString().trim()[0].toUpperCase());
        if (_alphabet.indexOf(fletter) == -1) {
          _alphabet.add(fletter);
        }
      }
    }
    _text = "*";
    _oldtext = _text;
    if (_alphabet.length > 0) {
      _alphabet.sort();
      _text = _alphabet[0];
      _oldtext = _text;
    } else {
      throw new Exception('-> Zero items in list. <-');
    }
  }

  @override
  Widget build(BuildContext context) {
    color = getRandomColors();
    return LayoutBuilder(builder: (context, contrainsts) {
      _heightscroller = (contrainsts.biggest.height - _sizefirstitem) /
          _alphabet
              .length; //NOTE: Here the contrainsts.biggest.height is the height of the list (height of body)
      _sizeheightcontainer = contrainsts.biggest.height -
          _sizefirstitem; //NOTE: Here i'm substracting the size of the container above of the listView
      return Column(children: [
        if (_itemscache.length > 0)
          Expanded(
              flex: 3,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => {
                  setState(() {
                    FocusScope.of(context).requestFocus(new FocusNode());
                  }) //NOTE: unfocus search when you click on scroller
                },
                child: Container(
                    height:
                        _sizeheightcontainer, //NOTE: Here is were is set the size of the listview
                    child: Stack(alignment: Alignment.topRight, children: [
                      //NOTE: Here to add some other components (but you need to remove they height from calcs (line above))
                      ShaderMask(
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
                            physics: BouncingScrollPhysics(),
                            controller: _scrollController,
                            padding: EdgeInsets.all(8.0),
                            itemExtent: _itemsizeheight,
                            itemCount: _itemscache.length,
                            itemBuilder: (BuildContext context, int index) {
                              //NOTE: How you want to generate your items
                              return GestureDetector(
                                  onTap: () => onItemClick(index),
                                  child:
                                      // Text(_itemscache[index].toString(),
                                      //     style: new TextStyle(fontSize: _itemfontsize))
                                      Column(children: [
                                    ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty
                                                    .resolveWith<Color>(
                                                        (states) =>
                                                            Colors.black)),
                                        onPressed: () {
                                          var s = {
                                            'packageName': _itemscache[index]
                                                ['packageName'],
                                            'title': _itemscache[index]
                                                ['appName']
                                          };
                                          if (selectedList.length > 5) {
                                            selectedList.removeLast();
                                          }
                                          bool isPackageIncluded = false;
                                          selectedList.forEach((element) {
                                            if (element['packageName'] ==
                                                _itemscache[index]
                                                    ['packageName']) {
                                              isPackageIncluded = true;
                                            }
                                          });
                                          if (isPackageIncluded == false) {
                                            selectedList.insert(0, s);
                                          }
                                          Navigator.pushReplacement(
                                              context,
                                              PageTransition(
                                                  type: PageTransitionType
                                                      .bottomToTop,
                                                  duration:
                                                      Duration(seconds: 1),
                                                  child: CountingApp()));
                                          if (_itemscache[index]['appName']
                                                  .toLowerCase() ==
                                              'phone') {
                                            userNameController.clear();
                                            _launchCaller("");
                                          } else {
                                            userNameController.clear();
                                            DeviceApps.openApp(
                                                s['packageName']);
                                          }
                                        },
                                        child: AnimatedContainer(
                                            duration: Duration(seconds: 1),
                                            color: Colors.black,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Padding(
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.all(0),
                                                        child: Row(
                                                          children: [
                                                            if (widget.powerSavingMode ==
                                                                    "off" ||
                                                                widget.powerSavingMode ==
                                                                    null)
                                                              ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30),
                                                                  child: Image
                                                                      .memory(
                                                                    // Uint8List.fromList(
                                                                    _itemscache[
                                                                            index]
                                                                        [
                                                                        'icon'],
                                                                    // .cast<int>()),
                                                                    height: 40,
                                                                    width: 40,
                                                                  )
                                                                  //
                                                                  // child: Image.memory(icon),
                                                                  ),
                                                            Text(
                                                              "     ${_itemscache[index]['appName'].toString()}",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ],
                                                        ))
                                                  ],
                                                ))))
                                  ]));
                            },
                          )),
                      Visibility(
                        visible: _searchtext.length > 0 ? false : true,
                        child: GestureDetector(
                          child: AnimatedContainer(
                              // height: 40,
                              duration: Duration(milliseconds: 500),
                              child: Container(
                                //NOTE: this container is the scroll bar it need at least to have height => _heightscroller
                                width: _heightscroller + 20,
                                decoration: new BoxDecoration(
                                  gradient: new RadialGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.transparent,
                                      Colors.red,
                                      Colors.transparent
                                    ],
                                  ), //NOTE: change color of scroller
                                  shape: BoxShape.circle,
                                  //NOTE: change this to rectangle
                                ),
                                child: Center(
                                    child: Text(
                                  _text,
                                  textAlign: TextAlign.center,
                                  style: new TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: _heightscroller - 10,
                                      // fontWeight: FontWeight.bold,
                                      color: Colors
                                          .white), //NOTE: white -> color of text of scroller
                                )),
                              ),
                              height: _heightscroller + 30,
                              margin: EdgeInsets.only(top: _offsetContainer)),
                          onVerticalDragStart: (DragStartDetails details) {
                            _customscrollisscrolling = true;
                          },
                          onVerticalDragEnd: (DragEndDetails details) {
                            _customscrollisscrolling = false;
                          },
                          onVerticalDragUpdate: (DragUpdateDetails details) {
                            setState(() {
                              if ((_offsetContainer + details.delta.dy) >= 0 &&
                                  (_offsetContainer + details.delta.dy) <=
                                      (_sizeheightcontainer -
                                          _heightscroller)) {
                                _offsetContainer += details.delta.dy;
                                _text = _alphabet[
                                    ((_offsetContainer / _heightscroller) %
                                            _alphabet.length)
                                        .round()];
                                if (_text != _oldtext) {
                                  for (var i = 0; i < _itemscache.length; i++) {
                                    if (_itemscache[i]['appName']
                                                .toString()
                                                .trim()
                                                .length >
                                            0 &&
                                        _itemscache[i]['appName']
                                                .toString()
                                                .trim()
                                                .toUpperCase()[0] ==
                                            _text.toString().toUpperCase()[0]) {
                                      _animationcounter++;
                                      _scrollController
                                          .animateTo(
                                              i *
                                                  _itemsizeheight, //NOTE: To configure the animation
                                              duration: new Duration(
                                                  milliseconds: 500),
                                              curve: Curves.ease)
                                          .then((x) => {_animationcounter--});
                                      break;
                                    }
                                  }
                                  _oldtext = _text;
                                }
                              }
                            });
                          },
                        ),
                      )
                    ])),
              )),
        if (_itemscache.length == 0)
          Expanded(
              flex: 3,
              child: Container(
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 40, 20, 0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 40),
                              child: Image.asset(
                                'assets/images/not-found.gif',
                                height: 100,
                                width: 100,
                                fit: BoxFit.contain,
                              ),
                            ),
                            TouchableOpacity(
                              onTap: () {
                                if (_searchtext.contains('call') ||
                                    _searchtext.contains('+91') ||
                                    isNumericUsingRegularExpression(
                                        _searchtext)) {
                                  _launchCaller(_searchtext);
                                } else {
                                  _launchPlayStore(_searchtext);
                                }
                              },
                              child: Text(
                                isNumericUsingRegularExpression(_searchtext) ||
                                        _searchtext.contains('+91')
                                    ? _searchtext.contains('call')
                                        ? '"$_searchtext" '
                                        : 'call "$_searchtext" '
                                    : _searchtext.contains('.com') ||
                                            _searchtext.contains('https')
                                        ? 'open "$_searchtext" in browser.'
                                        : 'search for "$_searchtext" in play store. ',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 20,
                                  fontFamily: 'Montserrat',
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )))),
        // Expanded(
        //     flex: 0,
        //     child: Container(
        //       padding: EdgeInsets.all(10),
        //       height: _sizefirstitem,
        //       child: Column(children: <Widget>[
        //         TextFormField(
        //           controller: userNameController,
        //           onChanged: onsearchtextchange,
        //           focusNode: _focusNode,
        //           decoration: InputDecoration(
        //               prefixIcon: Icon(
        //                 Icons.search,
        //                 color: Colors.blueAccent,
        //               ),
        //               hintText: "Search your apps and content here",
        //               hintStyle: TextStyle(color: Colors.white, fontSize: 15.0),
        //               suffixIcon: IconButton(
        //                 color: Colors.red,
        //                 onPressed: () {
        //                   reset();
        //                 },
        //                 icon: Icon(
        //                   Icons.clear,
        //                   color: Colors.red,
        //                 ),
        //               )),
        //           keyboardType: TextInputType.emailAddress,
        //           onFieldSubmitted: (value) {
        //             //Validator
        //           },
        //           style: TextStyle(
        //               color: Colors.white,
        //               fontSize: 25,
        //               fontFamily: 'Montserrat'),
        //         ),
        //         // Padding(
        //         //   padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        //         //   child: Container(
        //         //     height: selectedList.length > 0 ? 60.0 : 0,
        //         //     child: ListView(
        //         //       scrollDirection: Axis.horizontal,
        //         //       children: <Widget>[
        //         //         for (var i in selectedList)
        //         //           RecentButtons(
        //         //             title: i['title'],
        //         //             packageName: i['packageName'],
        //         //           ),
        //         //       ],
        //         //     ),
        //         //   ),
        //         // ),
        //         // TextField(
        //         //   focusNode: _focusNode,
        //         //   onChanged: onsearchtextchange,
        //         //   decoration: InputDecoration(
        //         //       labelText: "search For apps and content",
        //         //       hintText: "Search",
        //         //       prefixIcon: Icon(Icons.search),
        //         //       border: OutlineInputBorder(
        //         //           borderRadius: BorderRadius.all(Radius.circular(6.0)))),
        //         // )
        //       ]),
        //     )),
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
                              controller: userNameController,
                              onChanged: onsearchtextchange,
                              focusNode: _focusNode,
                              decoration: InputDecoration(
                                  prefixIcon: widget.powerSavingMode == 'on'
                                      ? Icon(
                                          Icons.search,
                                          color: Colors.blueAccent,
                                        )
                                      : OutlinedButton(
                                          onPressed: () {
                                            DeviceApps.openApp(
                                                "com.google.android.apps.googleassistant");
                                          },
                                          child:
                                              // Padding(
                                              //     padding:
                                              //         EdgeInsets.fromLTRB(0, 0, 10, 0),
                                              //     child:
                                              Image.asset(
                                            'assets/images/ga1.png',
                                            height: 30,
                                            width: 30,
                                            fit: BoxFit.contain,
                                          )),
                                  hintText:
                                      "  Search your apps and content here",
                                  hintStyle: TextStyle(
                                      color: Colors.white, fontSize: 15.0),
                                  suffixIcon: IconButton(
                                    focusNode: focusOnButton,
                                    color: Colors.red,
                                    onPressed: () {
                                      reset();
                                    },
                                    icon: Icon(
                                      Icons.clear,
                                      color: Colors.red,
                                    ),
                                  )),
                              keyboardType: TextInputType.emailAddress,
                              onFieldSubmitted: (value) {
                                //Validator
                                FocusScope.of(context).unfocus();
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
      ]);
    });
  }
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

class RecentButtons extends StatelessWidget {
  final String title;
  final String packageName;

  // bool isPackageIncluded;
  RecentButtons({Key key, this.title, this.packageName}) : super(key: key);

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

  void _launchCaller(String text) async {
    var url = "tel:$text";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
