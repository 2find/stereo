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
      _getTitleText(),
      _getSubtitleText()
    ];

    return new Expanded(
        child: new Column(
            children: widgets, mainAxisAlignment: MainAxisAlignment.center));
  }

  Widget _getArtwork() {
    Image image;

    if (_stereo.currentTrack?.artwork != null) {
      image =
          new Image.memory(_stereo.currentTrack.artwork, fit: BoxFit.fitHeight);
    } else {
      image = new Image.asset('assets/images/artwork_default.png',
          fit: BoxFit.fitHeight);
    }

    return new Expanded(child: image);
  }

  Widget _getSubtitleText() {
    return new Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: new Text(
            '${_stereo.currentTrack?.artist ??
                AudioTrack.defaults['artist']} - ${_stereo.currentTrack
                ?.album ?? AudioTrack.defaults['album']}',
            textAlign: TextAlign.center,
            style: new TextStyle(fontSize: 18.0)));
  }

  Widget _getTitleText() {
    return new Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: new Text(
            '${_stereo.currentTrack?.title ?? AudioTrack.defaults['title']}',
            textAlign: TextAlign.center,
            overflow: TextOverflow.clip,
            maxLines: 1,
            style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0)));
  }
}
