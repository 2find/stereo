package com.twofind.stereo;

import android.Manifest;
import android.app.Activity;
import android.content.ContentUris;
import android.content.Intent;
import android.database.Cursor;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Environment;
import android.os.Handler;
import android.provider.DocumentsContract;
import android.provider.MediaStore;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import java.io.IOException;

/**
 * StereoPlugin
 */
public class StereoPlugin implements MethodCallHandler, PluginRegistry.ActivityResultListener, PluginRegistry.RequestPermissionsResultListener {
  private MediaPlayer mediaPlayer;
  private static MethodChannel channel;

  public static final int REQUEST_PICKER_CODE = 1;
  public static final int REQUEST_PERMISSIONS_CODE = 2;

  // Flutter main activity.
  private Activity activity;

  // To handle position updates.
  private final Handler handler = new Handler();

  // Flutter result.
  private Result pendingResult;

  public StereoPlugin(Activity activity) {
    this.activity = activity;
  }

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    StereoPlugin instance = new StereoPlugin(registrar.activity());

    channel = new MethodChannel(registrar.messenger(), "com.twofind.stereo");
    channel.setMethodCallHandler(instance);
    registrar.addActivityResultListener(instance);
    registrar.addRequestPermissionsResultListener(instance);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      // isPlaying() method.
      case "app.isPlaying":
        result.success(isPlaying());
        break;

      // load() method.
      case "app.load":
        if (call.arguments != null) {
          if (!(call.arguments instanceof String)) {
            result.error("WRONG_FORMAT", "The specified URL must be a string.", null);
          }

          String path = (String) call.arguments;

          result.success(load(path));
        } else {
          result.error("NO_URL", "No URL was specified.", null);
        }
        break;

      // pause() method.
      case "app.pause":
        pause();

        result.success(null);
        break;

      case "app.picker":
        if (pendingResult != null) {
          pendingResult.error("MULTIPLE_REQUESTS", "Cannot make multiple requests.", null);
          pendingResult = null;
        }

        pendingResult = result;

        picker();

        break;

      // play() method.
      case "app.play":
        play();

        result.success(null);
        break;

      // seek() method.
      case "app.seek":
        if (call.arguments != null) {
          if (!(call.arguments instanceof Integer)) {
            result.error("INVALID_POSITION_TYPE", "Position must be specified by an integer.", null);
          }

          int seconds = (int) call.arguments;

          result.success(seek(seconds));
        } else {
          result.error("NO_POSITION", "No position was specified.", null);
        }
        break;

      // stop() method.
      case "app.stop":
        stop();

        result.success(null);
        break;

      // Method not implemented.
      default:
        result.notImplemented();
        break;
    }
  }

  private boolean isPlaying() {
    return mediaPlayer != null && mediaPlayer.isPlaying();
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
    channel.invokeMethod("platform.currentTrack", AudioTrack.toJson(path));

    mediaPlayer.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
      @Override
      public void onCompletion(MediaPlayer mediaPlayer) {
        channel.invokeMethod("platform.completion", null);
      }
    });

    return 0;
  }

  private void pause() {
    if (mediaPlayer != null) {
      mediaPlayer.pause();
      // Stop sending position to the application.
      handler.removeCallbacks(updatePosition);
    }
  }

  private void picker() {
    // Request permissions.
    activity.requestPermissions(new String[]{Manifest.permission.READ_EXTERNAL_STORAGE}, REQUEST_PERMISSIONS_CODE);
  }

  private void play() {
    if (mediaPlayer != null) {
      // Start sending position to the application.
      handler.post(updatePosition);
      mediaPlayer.start();
    }
  }

  private int seek(int seconds) {
    if (mediaPlayer != null) {
      mediaPlayer.seekTo(seconds * 1000);
      // Update position.
      channel.invokeMethod("platform.position", mediaPlayer.getCurrentPosition() / 1000);

      return 0;
    }

    return 1;
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
        if (!mediaPlayer.isPlaying()) {
          handler.removeCallbacks(updatePosition);
        }

        // Send position (seconds) to the application.
        channel.invokeMethod("platform.position", mediaPlayer.getCurrentPosition() / 1000);

        // Update every 200ms.
        handler.postDelayed(updatePosition, 200);
      } catch (Exception e) {
        e.printStackTrace();
      }
    }
  };

  @Override
  public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
    switch (requestCode) {
      case REQUEST_PICKER_CODE:
        if (resultCode == Activity.RESULT_OK) {
          Uri uri = data.getData();
          String path = getPath(uri);

          // Return metadata to the library.
          pendingResult.success(AudioTrack.toJson(path));
          pendingResult = null;

          return true;
        } else {
          pendingResult.error("NO_TRACK_SELECTED", "No track has been selected.", null);
          pendingResult = null;

          return false;
        }

      default:
        return false;
    }
  }

  /*
   * Credits: https://stackoverflow.com/a/36129285/3238070
   */
  private String getPath(Uri uri) {
    // DocumentProvider.
    if (DocumentsContract.isDocumentUri(activity, uri)) {
      final String documentId = DocumentsContract.getDocumentId(uri);
      final String[] split = documentId.split(":");
      // final String type = split[0];

      Uri contentUri;

      switch (uri.getAuthority()) {
        // ExternalStorageProvider
        case "com.android.externalstorage.documents":
          return Environment.getExternalStorageDirectory() + "/" + split[1];

        // DownloadsProvider.
        case "com.android.providers.downloads.documents":
          // Treat 'raw' files. Don't know if that's the best way to do this, consider it as a temporary fix.
          if (documentId != null && documentId.startsWith("raw:")) {
            return documentId.substring("raw:".length());
          }
          contentUri = ContentUris.withAppendedId(Uri.parse("content://downloads/public_downloads"), Long.valueOf(documentId));

          return getDataColumn(contentUri, null, null);

        // MediaProvider.
        case "com.android.providers.media.documents":
          contentUri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI;
          final String selection = "_id=?";
          final String[] selectionArgs = new String[]{split[1]};

          return getDataColumn(contentUri, selection, selectionArgs);

        default:
          return null;
      }
    }
    // Media Store.
    else if (uri.getScheme().equals("content")) {
      return getDataColumn(uri, null, null);
    }
    // File.
    else if (uri.getScheme().equals("file")) {
      return uri.getPath();
    }

    return null;
  }

  private String getDataColumn(Uri uri, String selection, String[] selectionArgs) {
    Cursor cursor = null;
    final String column = "_data";
    final String[] projection = new String[]{column};

    try {
      cursor = activity.getContentResolver().query(uri, projection, selection, selectionArgs, null);
      if (cursor != null && cursor.moveToFirst()) {
        return cursor.getString(cursor.getColumnIndexOrThrow(column));
      }
    } finally {
      if (cursor != null) {
        cursor.close();
      }
    }

    return null;
  }

  @Override
  public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] resultCodes) {
    switch(requestCode) {
      case REQUEST_PERMISSIONS_CODE:
        // Permission granted.
        if (resultCodes[0] == 0) {
          Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
          intent.setType("audio/*");

          activity.startActivityForResult(Intent.createChooser(intent, "Open audio file"), REQUEST_PICKER_CODE);

          return true;
        } else {
          pendingResult.error("STORAGE_PERMISSION_DENIED", "EXTERNAL_STORAGE permission denied by user.", null);
          pendingResult = null;
        }
    }

    return false;
  }
}
