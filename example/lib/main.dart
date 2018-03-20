import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:path_provider/path_provider.dart';
import 'package:stereo/stereo.dart';
import 'package:stereo_example/media_info_widget.dart';

import 'package:stereo_example/media_player_widget.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Stereo Plugin Example', home: new HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Stereo _stereo = new Stereo();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title: new Text('Stereo Plugin Example')),
        body: new Column(children: <Widget>[
          new Center(
              heightFactor: 1.5,
              child: new Text('Choose an action:',
                  style: new TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20.0))),
          new Wrap(
              alignment: WrapAlignment.spaceAround,
              spacing: 12.0,
              runSpacing: 8.0,
              children: <Widget>[
                new RaisedButton(
                    child: new Text('Play dubstep.mp3'),
                    onPressed: () => _playFile('dubstep.mp3')),
                new RaisedButton(
                    child: new Text('Play pi.mp3'),
                    onPressed: () => _playFile('pi.mp3')),
                new RaisedButton(
                    child: new Text('Invalid URL'),
                    onPressed: () => _playFile("invalid_file.mp3")),
                new RaisedButton(
                    child: new Text('Pick file'), onPressed: () => _pickFile())
              ]),
          new Container(height: 5.0),
          new MediaInfoWidget(),
          new Padding(
              padding:
                  new EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
              child: new MediaPlayerWidget())
        ]));
  }

  Future _pickFile() async {
    try {
      AudioTrack track = await _stereo.picker();

      _playFile(track.path, false);
    } on StereoPermissionsDeniedException catch (_) {
      print('ERROR: Permissions denied');
    } on StereoNoTrackSelectedException {
      print('ERROR: No track selected');
    }
  }

  Future _playFile(String file, [bool fromAppDir = true]) async {
    String dir = '';

    if (fromAppDir) {
      await _copyFiles();

      await getApplicationDocumentsDirectory().then(
          (Directory directory) => dir = 'file://' + directory.path + '/');
    }

    try {
      await _stereo.load('$dir$file');
    } on StereoFileNotPlayableException {
      var alert = new AlertDialog(
          title: new Text('File not playable'),
          content: new Text('The file you specified is not playable.'));

      showDialog(context: context, child: alert);
    }
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
