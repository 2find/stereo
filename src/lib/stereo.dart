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
  /// General instance.
  static Stereo _instance = new Stereo._internal();

  /// Channel used to communicate with the platform.
  static const MethodChannel _channel =
      const MethodChannel('com.twofind.stereo');

  /// Callback called when the platform toggle play/pause state.
  static VoidCallback togglePlayPauseCallback;

  /// Constructor.
  factory Stereo() {
    return _instance;
  }

  /// Internal constructor.
  Stereo._internal() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  /// Sets the data source (URI path) to use.
  ///
  /// Throws a [StereoFileNotPlayableException] if the specified [uri] points to
  /// a file which is not playable.
  Future load(String uri) async {
    int rc = await _channel.invokeMethod('app.load', uri);

    if (rc == 1) {
      throw new StereoFileNotPlayableException();
    }
  }

  /// Pauses playback.
  Future pause() async {
    await _channel.invokeMethod('app.pause');
  }

  /// Starts or resumes playback.
  Future play() async {
    await _channel.invokeMethod('app.play');
  }

  /// Stops playback.
  Future stop() async {
    await _channel.invokeMethod('app.stop');
  }

  Future<bool> togglePlaying() async {
    return await _channel.invokeMethod('app.togglePlaying');
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
