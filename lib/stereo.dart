import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Represents an audio player.
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

  /// Always returns `0`.
  Future<int> loadItemWithURL(String url) {
    return _channel.invokeMethod('app.loadItemWithURL', url);
  }

  /// Returns information about the song the user picked.
  Future<String> showMediaPicker() {
    return _channel.invokeMethod('app.showMediaPicker');
  }

  /// Returns `true` if the player resumed playing, `false` otherwise.
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
