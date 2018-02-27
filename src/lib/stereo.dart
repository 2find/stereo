import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Exception thrown when a file is not playable.
class StereoFileNotPlayableException implements Exception {
  /// A message describing the error.
  String message;

  /// Creates a new [StereoFileNotPlayableException] with an optional error
  /// message.
  StereoFileNotPlayableException([this.message]);
}

/// Represents an audio player.
///
/// This class is a factory so it has only one instance.
class Stereo {
  static Stereo _instance = new Stereo._internal();

  static const MethodChannel _channel =
      const MethodChannel('com.mcs.plugins/stereo');

  static VoidCallback togglePlayPauseCallback;

  factory Stereo() {
    return _instance;
  }

  Stereo._internal() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  /// Loads a file given its URI.
  ///
  /// Throws a [StereoFileNotPlayableException] if the specified [uri] points to
  /// a file which is not playable.
  Future load(String uri) async {
    int rc = await _channel.invokeMethod('app.loadItemWithURL', uri);

    if (rc == 1) {
      throw new StereoFileNotPlayableException();
    }
  }

  Future<bool> togglePlaying() {
    return _channel.invokeMethod('app.togglePlaying');
  }

  Future _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'event.togglePlayPause':
        togglePlayPauseCallback();
        break;
      default:
        print('[ERROR] Channel method ${call.method} not implemented.');
    }
  }
}
