import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:stereo/stereo.dart';

class MediaPlayerWidget extends StatefulWidget {
  @override
  _MediaPlayerState createState() => new _MediaPlayerState();
}

class _MediaPlayerState extends State<MediaPlayerWidget> {
  static const Icon _pauseIcon = const Icon(FontAwesomeIcons.pause);
  static const Icon _playIcon = const Icon(FontAwesomeIcons.play);

  bool _isPlaying = false;

  Stereo _stereo = new Stereo();

  @override
  void initState() {
    super.initState();

    Stereo.togglePlayPauseCallback = () => _togglePlaying();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        height: 80.0,
        child: new Row(children: <Widget>[
          new Expanded(
              child: new IconButton(
                  icon: const Icon(FontAwesomeIcons.stepBackward),
                  iconSize: 30.0,
                  onPressed: null)),
          new Expanded(
              child: new IconButton(
                  icon: _isPlaying ? _pauseIcon : _playIcon,
                  iconSize: 50.0,
                  onPressed: () => _togglePlaying())),
          new Expanded(
              child: new IconButton(
                  icon: const Icon(FontAwesomeIcons.stepForward),
                  iconSize: 30.0,
                  onPressed: null))
        ]));
  }

  void _togglePlaying() {
    _stereo
        .togglePlaying()
        .then((bool state) => setState(() => _isPlaying = state));
  }
}
