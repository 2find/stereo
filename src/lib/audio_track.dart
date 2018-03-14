import 'dart:typed_data';

class AudioTrack {
  Map data;

  bool get isValid =>
      (album != null) && (artist != null) && (path != null) && (title != null);

  String get album => data['album'];

  String get artist => data['artist'];

  String get path => data['path'];

  String get title => data['title'];

  Uint8List get artwork => data['artwork'];

  AudioTrack(
      {String title,
      String artist,
      String album,
      String path,
      Uint8List artwork}) {
    data = {
      'title': title,
      'artist': artist,
      'album': album,
      'path': path,
      'artwork': artwork
    };
  }

  AudioTrack.fromJson(Map data) : data = data;

  String toString() {
    return '$title, $album, $artist';
  }
}
