import 'dart:async';

import 'package:flutter/services.dart';

/// Represents an audio player.
class AudioPlayer {
  static AudioPlayer _instance = new AudioPlayer._internal();

  static const MethodChannel _channel =
      const MethodChannel('com.mcs.plugins/stereo');

  factory AudioPlayer() {
    return _instance;
  }

  AudioPlayer._internal();

  /// Always returns `0`.
  Future<int> loadItemWithURL(String url) =>
      _channel.invokeMethod('app.loadItemWithURL', url);

  /// Returns information about the song the user picked.
  Future<String> showMediaPicker() {
    return _channel.invokeMethod('app.showMediaPicker');
  }

  /// Returns `true` if the player resumed playing, `false` otherwise.
  Future<bool> togglePlaying() {
    return _channel.invokeMethod('app.togglePlaying');
  }
}
