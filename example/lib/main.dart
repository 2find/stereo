import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:path_provider/path_provider.dart';

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

  List<FileSystemEntity> _files = <FileSystemEntity>[];
  StreamSubscription<FileSystemEntity> _stream;

  @override
  void initState() {
    getApplicationDocumentsDirectory().then((Directory dir) {
      _stream = dir.list().listen((FileSystemEntity file) {
        setState(() => _files.add(file));
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _stream.cancel();
    super.dispose();
  }

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
                      child: new Row(children: <Widget>[
                new Expanded(
                    child: new RaisedButton(
                        child: new Text('dubstep.mp3'),
                        onPressed: () => _playFile('dubstep.mp3'))),
                new Expanded(
                    child: new RaisedButton(
                        child: new Text('pi.mp3'),
                        onPressed: () => _playFile('pi.mp3')))
              ]))),
              new MediaPlayerWidget()
            ])));
  }

  Future _playFile(String file) async {
    await _copyFiles();

    final Directory dir = await getApplicationDocumentsDirectory();

    // iOS needs 'file://' to work. At the moment, we leave it here and we will
    // deal with it later.
    _stereo.loadItemWithURL('file://${dir.path}/$file');
  }

  // Don't judge the code for this method, it's for the example...
  Future _copyFiles() async {
    final Directory dir = await getApplicationDocumentsDirectory();

    final File dubstepSong = new File('${dir.path}/dubstep.mp3');
    final File piSong = new File('${dir.path}/pi.mp3');

    if (!(await dubstepSong.exists())) {
      final data = await rootBundle.load('assets/songs/dubstep.mp3');
      final bytes = data.buffer.asUint8List();
      await dubstepSong.writeAsBytes(bytes, flush: true);
    }
    if (!(await piSong.exists())) {
      final data = await rootBundle.load('assets/songs/pi.mp3');
      final bytes = data.buffer.asUint8List();
      await piSong.writeAsBytes(bytes, flush: true);
    }
  }
}
