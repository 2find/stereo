package com.twofind.stereo;

import android.media.MediaMetadataRetriever;

import java.util.HashMap;

public class AudioTrack {
  private AudioTrack() { }

  public static HashMap<String, Object> toJson(String path) {
    HashMap<String, Object> data = new HashMap<>();

    MediaMetadataRetriever mmr = new MediaMetadataRetriever();
    mmr.setDataSource(path);

    data.put("album", mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ALBUM));
    data.put("artist", mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST));
    data.put("title", mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE));
    data.put("path", path);
    data.put("artwork", mmr.getEmbeddedPicture());

    if (data.get("title") == null) {
      data.put("title", path.substring(path.lastIndexOf('/') + 1));
    }

    mmr.release();

    return data;
  };
}
