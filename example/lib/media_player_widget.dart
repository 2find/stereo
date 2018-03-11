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
  String _formatDuration(Duration duration) {
    return '${_twoDigits.format(duration.inSeconds ~/ 60)}:${_twoDigits
        .format(duration.inSeconds % 60)}';
  }

  /// Returns the slider value.
  double _getSliderValue() {
    int position = _stereo.position.inSeconds;
    if (position <= 0) {
      return 0.0;
    } else if (position >= _stereo.duration.inSeconds) {
      return _stereo.duration.inSeconds.toDouble();
    } else {
      return position.toDouble();
    }
  }

  @override
  void initState() {
    super.initState();

    _stereo.durationNotifier.addListener(() => setState(() {}));
    _stereo.isPlayingNotifier.addListener(() => setState(() {}));
    _stereo.positionNotifier.addListener(() => setState(() {}));

    _stereo.completionHandler = () => _stereo.stop();
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
          // This button is disabled since it's only there to show the current
          // state of the player.
          new IconButton(
              icon: _stereo.isPlaying ? _pauseIcon : _playIcon,
              iconSize: 50.0,
              onPressed: null)
        ],
      ),
      new Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
        new Container(
            width: 50.0,
            child: new Text(_formatDuration(_stereo.position),
                textAlign: TextAlign.left)),
        new Expanded(
            child: new Slider(
                value: _getSliderValue(),
                max: _stereo.duration.inSeconds.toDouble(),
                onChanged: (double newValue) =>
                    _stereo.seek(new Duration(seconds: newValue.ceil())))),
        new Container(
            width: 50.0,
            child: new Text('-' + _formatDuration(_stereo.remaining),
                textAlign: TextAlign.right))
      ])
    ]);
  }
}
