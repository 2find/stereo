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
    return new Column(children: <Widget>[
      new Wrap(
        alignment: WrapAlignment.spaceAround,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12.0,
        runSpacing: 8.0,
        children: <Widget>[
          new IconButton(
              icon: _playIcon, iconSize: 30.0, onPressed: () => _stereo.play()),
          new IconButton(
              icon: _isPlaying ? _pauseIcon : _playIcon,
              iconSize: 50.0,
              onPressed: () => _togglePlaying()),
          new IconButton(
              icon: _pauseIcon,
              iconSize: 30.0,
              onPressed: () => _stereo.pause(),
          )
        ],
      ),
      new LinearProgressIndicator(value: 0.5)
    ]);
  }

  void _togglePlaying() {
    _stereo
        .togglePlaying()
        .then((bool state) => setState(() => _isPlaying = state));
  }
}
