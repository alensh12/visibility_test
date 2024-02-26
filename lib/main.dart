import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:visibility_detector/visibility_detector.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Genius app',
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
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<SendGAData> galist = [];
  int index = 0;

  static const timerDuration = const Duration(seconds: 3);
  Timer? _timer;
  Map<int, int> visibleIndexes = {};

  @override
  void initState() {
    super.initState();
    VisibilityDetectorController.instance.updateInterval = Duration.zero;

    _timer = Timer(timerDuration, () {
      sendVisibleIndex();
    });
  }

  sendVisibleIndex() {
    // Send the visible indexes to the GA
    print(visibleIndexes.values.toList());
    visibleIndexes.clear();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: NotificationListener<ScrollNotification>(
          child: ListView.builder(
            itemBuilder: (ctx, pos) {
              return VisibilityDetector(
                key: Key(pos.toString()),
                onVisibilityChanged: (VisibilityInfo info) =>
                    onVisibityChanged(info, pos),
                child: Column(
                  children: [
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.all(70.0),
                        child: Center(
                            child: Text(
                          "ITEM $pos",
                          style: TextStyle(fontSize: 30),
                        )),
                      ),
                    ),
                    Divider()
                  ],
                ),
              );
            },
            itemCount: 100,
          ),
          onNotification: (scrollNotification) {
            if (scrollNotification is ScrollStartNotification) {
              _timer?.cancel();
              _timer = null;
            } else if (scrollNotification is ScrollEndNotification) {
              _timer = Timer(timerDuration, () {
                sendVisibleIndex();
              });
            }
            return true;
          },
        ),
      ),
    );
  }

  void onVisibityChanged(VisibilityInfo info, int index) {
    var visiblePercentage = info.visibleFraction * 100;
    if (visiblePercentage == 100) {
      // print(index);
      visibleIndexes[index] = index;
      // print(visibleIndexes.values.toList());
    } else {
      visibleIndexes.remove(index);
    }
  }
}

class SendGAData {
  bool? isAlreadySent = false;
  int? index;

  SendGAData(this.index, this.isAlreadySent);
}
