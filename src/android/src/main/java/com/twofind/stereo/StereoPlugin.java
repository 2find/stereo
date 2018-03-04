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
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "com.twofind.stereo");
    channel.setMethodCallHandler(new StereoPlugin());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    // isPlaying() method.
    if (call.method.equals("app.isPlaying")) {
      result.success(isPlaying());
    }
    // load() method.
    else if (call.method.equals("app.load")) {
      if (call.arguments != null) {
        if (!(call.arguments instanceof String)) {
          result.error("WRONG_FORMAT", "The specified URL must be a string.", null);
        }

        String path = (String)call.arguments;

        result.success(load(path));
      } else {
        result.error("NO_URL", "No URL was specified.", null);
      }
    }
    // pause() method.
    else if (call.method.equals("app.pause")) {
      pause();

      result.success(null);
    }
    // play() method.
    else if (call.method.equals("app.play")) {
      play();

      result.success(null);
    }
    // stop() method.
    else if (call.method.equals("app.stop")) {
      stop();

      result.success(null);
    }
    // Method not implemented.
    else {
      result.notImplemented();
    }
  }

  private boolean isPlaying() {
    if (mediaPlayer != null) {
      return mediaPlayer.isPlaying();
    }

    return false;
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
      return 1;
    }

    try {
      mediaPlayer.prepare();
    } catch (IOException e) {
      return 1;
    }

    return 0;
  }

  private void pause() {
    if (mediaPlayer != null) {
      mediaPlayer.pause();
    }
  }

  private void play() {
    if (mediaPlayer != null) {
      mediaPlayer.start();
    }
  }

  private void stop() {
    if (mediaPlayer != null) {
      mediaPlayer.stop();
      mediaPlayer.release();

      mediaPlayer = null;
    }
  }
}
