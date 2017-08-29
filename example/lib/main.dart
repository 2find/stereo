import 'package:flutter/material.dart';

import 'package:stereo/stereo.dart';

import 'package:stereo_example/media_player_widget.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Stereo _stereo = new Stereo();
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: new Scaffold(
            appBar: new AppBar(
              title: new Text('Stereo Plugin Example'),
            ),
            body: new Column(children: <Widget>[
              new Flexible(
                  child: new Center(
                      child: new RaisedButton(
                          child: new Text('Pick a song'),
                          onPressed: () {
                            _stereo.showMediaPicker().then((String url) {
                              _stereo.loadItemWithURL(url);
                            });
                          }))),
              new MediaPlayerWidget()
            ])));
  }
}
