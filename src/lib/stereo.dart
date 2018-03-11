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

/// Exception thrown when a specified position is invalid.
class StereoInvalidPositionException implements Exception {
  /// A message describing the error.
  String message;

  /// Creates a new [StereoInvalidPositionException] with an optional error
  /// message.
  StereoInvalidPositionException([this.message]);
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

  /// Constructor.
  factory Stereo() {
    return _instance;
  }

  /// Internal constructor.
  Stereo._internal() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  /// Callback called when the playing song ends.
  VoidCallback completionHandler;

  /// Notifier to notify listeners every time the playback duration changes.
  ValueNotifier<Duration> _durationNotifier =
      new ValueNotifier(new Duration(seconds: 0));

  /// Playback duration.
  Duration get duration => _durationNotifier.value;

  /// Notifier to get notified every time the playback duration changes.
  ValueNotifier<Duration> get durationNotifier => _durationNotifier;

  /// Notifier to notify listeners every time the Stereo player state changes.
  ValueNotifier<bool> _isPlayingNotifier = new ValueNotifier(false);

  /// Whether the Stereo player is playing.
  bool get isPlaying => _isPlayingNotifier.value;

  /// Notifier to get notified every time the Stereo player state changes.
  ValueNotifier<bool> get isPlayingNotifier => _isPlayingNotifier;

  /// Notifier to notify listeners every time the playback position changes.
  ValueNotifier<Duration> _positionNotifier = new ValueNotifier(new Duration(seconds: 0));

  /// Playback position.
  Duration get position => _positionNotifier.value;

  /// Notifier to get notified every time the playback position changes.
  ValueNotifier<Duration> get positionNotifier => _positionNotifier;

  /// Remaining time.
  ///
  /// No notifier has been made available for this member since it relies on
  /// the [durationNotifier] and [positionNotifier] values.
  Duration get remaining => _durationNotifier.value - _positionNotifier.value;

  /// Sets the data source (URI path) to use.
  ///
  /// Throws a [StereoFileNotPlayableException] if the specified [uri] points to
  /// a file which is not playable.
  Future load(String uri) async {
    int rc = await _channel.invokeMethod('app.load', uri);

    _isPlayingNotifier.value = await _isPlaying();

    if (rc == 1) {
      throw new StereoFileNotPlayableException();
    }
  }

  /// Pauses playback.
  Future pause() async {
    await _channel.invokeMethod('app.pause');

    _isPlayingNotifier.value = await _isPlaying();
  }

  /// Starts or resumes playback.
  Future play() async {
    await _channel.invokeMethod('app.play');

    _isPlayingNotifier.value = await _isPlaying();
  }

  /// Seeks to specified time [position].
  Future seek(Duration position) async {
    if (position.inSeconds < 0 || position.inSeconds > duration.inSeconds) {
      throw new StereoInvalidPositionException();
    }

    await _channel.invokeMethod('app.seek', position.inSeconds);
  }

  /// Stops playback.
  Future stop() async {
    await _channel.invokeMethod('app.stop');


    _isPlayingNotifier.value = await _isPlaying();
  }

  /// Handles method calls from platform.
  Future _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'platform.completion':
        completionHandler();
        break;
      case 'platform.duration':
        _durationNotifier.value = new Duration(seconds: call.arguments);
        break;
      case 'platform.isPlaying':
        _isPlayingNotifier.value = call.arguments;
        break;
      case 'platform.position':
        _positionNotifier.value = new Duration(seconds: call.arguments);
        break;
      default:
        print('[ERROR] Channel method ${call.method} not implemented.');
    }
  }

  /// Returns `true` if the player is playing music, `false` otherwise.
  Future<bool> _isPlaying() async {
    return await _channel.invokeMethod('app.isPlaying');
  }
}
