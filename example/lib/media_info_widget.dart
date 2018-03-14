import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:stereo/stereo.dart';

class MediaInfoWidget extends StatefulWidget {
  @override
  _MediaInfoState createState() => new _MediaInfoState();
}

class _MediaInfoState extends State<MediaInfoWidget> {
  Stereo _stereo = new Stereo();

  @override
  void initState() {
    super.initState();

    _stereo.currentTrackNotifier.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = <Widget>[
      _getArtwork(),
      new Expanded(child: new Flex(direction: Axis.vertical)),
      _getTitleText(),
      _getSubtitleText()
    ];

    return new Expanded(
        child: new Column(
            children: widgets, mainAxisAlignment: MainAxisAlignment.center));
  }

  Widget _getArtwork() {
    Widget child;

    if (_stereo.currentTrack?.artwork != null) {
      child = new Image.memory(_stereo.currentTrack.artwork,
          height: 250.0, width: 250.0);
    } else {
      child = new Container(
          width: 250.0,
          height: 250.0,
          decoration: new BoxDecoration(color: const Color(0xFF000000)));
    }

    return new Padding(padding: const EdgeInsets.only(top: 44.0), child: child);
  }

  Widget _getSubtitleText() {
    return new Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 80.0),
        child: new Text(
            '${_stereo.currentTrack?.artist ?? ''} - ${_stereo.currentTrack
                ?.album ?? ''}',
            textAlign: TextAlign.center,
            style: new TextStyle(fontSize: 18.0)));
  }

  Widget _getTitleText() {
    return new Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 50.0),
        child: new Text('${_stereo.currentTrack?.title ?? ''}',
            textAlign: TextAlign.center,
            overflow: TextOverflow.clip,
            maxLines: 1,
            style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0)));
  }
}
