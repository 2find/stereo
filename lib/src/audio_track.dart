part of stereo;

/// Represents a track.
class AudioTrack {
  /// Track metadata.
  Map data;

  /// Default values to replace fields that are `null` at initialization.
  static Map defaults = new Map.from({
    'album': 'Unknown album',
    'artist': 'Unknown artist',
    'artwork': null,
    'path': null,
    'title': 'Unknown title'
  });

  /// Track album.
  String get album => data['album'];

  /// Track artist.
  String get artist => data['artist'];

  /// Track artwork.
  Uint8List get artwork => data['artwork'];

  /// Track path.
  String get path => data['path'];

  /// Track title.
  String get title => data['title'];

  /// Creates a track by defining its fields.
  ///
  /// If a field is `null`, it will assign its default value as specified in
  /// the [defaults] static variable.
  AudioTrack(
      {String album,
      String artist,
      Uint8List artwork,
      String path,
      String title}) {
    data = {
      'album': album ?? defaults['album'],
      'artwork': artwork ?? defaults['artwork'],
      'artist': artist ?? defaults['artist'],
      'path': path ?? defaults['path'],
      'title': title ?? defaults['title']
    };
  }

  /// Creates a track from existing metadata.
  AudioTrack.fromJson(Map data)
      : this(
            album: data['album'],
            artist: data['artist'],
            artwork: data['artwork'],
            path: data['path'],
            title: data['title']);
}
