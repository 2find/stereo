import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Represents an audio player.
class Stereo {
  static const MethodChannel _channel =
  const MethodChannel('com.mcs.plugins/stereo');

  Stereo._internal() {
    Stereo._channel.setMethodCallHandler(Stereo._handleMethodCall);
  }

  static VoidCallback togglePlayPauseCallback;

  /// Always returns `0`.
  static Future<int> loadItemWithURL(String url) =>
      _channel.invokeMethod('app.loadItemWithURL', url);

  /// Returns information about the song the user picked.
  static Future<String> showMediaPicker() {
    return _channel.invokeMethod('app.showMediaPicker');
  }

  /// Returns `true` if the player resumed playing, `false` otherwise.
  static Future<bool> togglePlaying() {
    return _channel.invokeMethod('app.togglePlaying');
  }

  static Future _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'event.togglePlayPause':
        togglePlayPauseCallback();
        break;
      default:
        print('[ERROR] Channel method ${call.method} not implemented.');
    }
  }
}
