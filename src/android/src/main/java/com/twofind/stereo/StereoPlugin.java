package com.twofind.stereo;

import android.media.MediaPlayer;
import android.net.Uri;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import java.io.IOException;

/**
 * StereoPlugin
 */
public class StereoPlugin implements MethodCallHandler {
  private MediaPlayer mediaPlayer;

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "com.mcs.plugins/stereo");
    channel.setMethodCallHandler(new StereoPlugin());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("app.loadItemWithURL")) {
      if (call.arguments != null) {
        if (!(call.arguments instanceof String)) {
          result.error("WRONG_FORMAT", "The specified URL must be a string.", null);
        }

        String path = (String)call.arguments;

        result.success(load(path));
      }
    } else if (call.method.equals("app.togglePlaying")) {
      result.success(togglePlayPause());
    } else {
      result.notImplemented();
    }
  }

  private int load(String path) {
    if (mediaPlayer != null) {
      mediaPlayer.stop();
      mediaPlayer.release();
      mediaPlayer = null;
    }

    mediaPlayer = new MediaPlayer();

    try {
      mediaPlayer.setDataSource(path);
    } catch (IOException e) {
      e.printStackTrace();

      return 1;
    }

    try {
      mediaPlayer.prepare();
    } catch (IOException e) {
      e.printStackTrace();

      return 1;
    }

    return 0;
  }

  private boolean togglePlayPause() {
    if (mediaPlayer.isPlaying()) {
      mediaPlayer.pause();
    } else {
      mediaPlayer.start();
    }

    return mediaPlayer.isPlaying();
  }
}
