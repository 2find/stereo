package com.twofind.stereo;

import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Handler;
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
  private static MethodChannel channel;

  // To handle position updates.
  private final Handler handler = new Handler();

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    channel = new MethodChannel(registrar.messenger(), "com.twofind.stereo");
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
    stop();

    mediaPlayer = new MediaPlayer();

    try {
      mediaPlayer.setDataSource(path);
      mediaPlayer.prepare();
    } catch (IOException e) {
      channel.invokeMethod("platform.duration", 0);
      return 1;
    }

    // Send duration to the application.
    channel.invokeMethod("platform.duration", mediaPlayer.getDuration() / 1000);

    return 0;
  }

  private void pause() {
    if (mediaPlayer != null) {
      mediaPlayer.pause();
      // Stop sending position to the application.
      handler.removeCallbacks(updatePosition);
    }
  }

  private void play() {
    if (mediaPlayer != null) {
      // Start sending position to the application.
      handler.post(updatePosition);
      mediaPlayer.start();
    }
  }

  private void stop() {
    if (mediaPlayer != null) {
      // Reset duration and position.
      handler.removeCallbacks(updatePosition);
      channel.invokeMethod("platform.duration", 0);
      channel.invokeMethod("platform.position", 0);

      mediaPlayer.stop();
      mediaPlayer.release();

      mediaPlayer = null;
    }
  }

  private final Runnable updatePosition = new Runnable() {
    @Override
    public void run() {
      try {
        if (mediaPlayer.isPlaying() == false) {
          handler.removeCallbacks(updatePosition);
        }

        // Send position (seconds) to the application.
        channel.invokeMethod("platform.position", mediaPlayer.getCurrentPosition() / 1000);

        // Update every 300ms.
        handler.postDelayed(updatePosition, 300);
      } catch (Exception e) {
        e.printStackTrace();
      }
    }
  };
}
