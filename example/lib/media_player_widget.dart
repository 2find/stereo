import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:intl/intl.dart';

import 'package:stereo/stereo.dart';

class MediaPlayerWidget extends StatefulWidget {
  @override
  _MediaPlayerState createState() => new _MediaPlayerState();
}

class _MediaPlayerState extends State<MediaPlayerWidget> {
  /// Pause icon.
  static const Icon _pauseIcon = const Icon(FontAwesomeIcons.pause);

  /// Play icon.
  static const Icon _playIcon = const Icon(FontAwesomeIcons.play);

  /// Stop icon.
  static const Icon _stopIcon = const Icon(FontAwesomeIcons.stop);

  // Used to format duration.
  static NumberFormat _twoDigits = new NumberFormat('00', 'en_GB');

  Stereo _stereo = new Stereo();

  /// Returns the duration as a formatted string.
  String _formatDuration() {
    return '${_twoDigits.format(_stereo.duration.inSeconds / 60)}:${_twoDigits
        .format(_stereo.duration.inSeconds % 60)}';
  }

  @override
  void initState() {
    super.initState();

    _stereo.durationNotifier.addListener(() => setState(() {}));
    _stereo.isPlayingNotifier.addListener(() => setState(() {}));
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
              icon: _pauseIcon,
              iconSize: 30.0,
              onPressed: () => _stereo.pause()),
          new IconButton(
              icon: _stopIcon, iconSize: 30.0, onPressed: () => _stereo.stop()),
          new IconButton(
              icon: _stereo.isPlaying ? _pauseIcon : _playIcon,
              iconSize: 50.0,
              onPressed: null)
        ],
      ),
      new Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
        new Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: new Text('00:00')),
        new Expanded(child: new LinearProgressIndicator(value: 0.5)),
        new Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: new Text(_formatDuration()))
      ])
    ]);
  }
}
