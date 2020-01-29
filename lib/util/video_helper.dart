import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

class VideoHelper {
  static final _coder = FlutterFFmpeg();

  static String thumbnailPath(File video) => '${video.path}_thumb.jpg';
  static String convertedVideoPath(File video) => '${video.path}.hd480.mp4';

  static Future<File> buildThumbnail(File file) async {
    String thumbnailPath = VideoHelper.thumbnailPath(file);
    await _coder.execute('-ss 1 -i ${file.path} -vframes 1 $thumbnailPath');
    return File(thumbnailPath);
  }

  static Future<File> processVideoForUpload(File original) async {
    String processedVideoPath = VideoHelper.convertedVideoPath(original);
    await _coder.execute('-i ${original.path} -c:v libx264 -preset fast $processedVideoPath');
    return File(processedVideoPath);
  }
}