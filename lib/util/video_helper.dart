import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';

class VideoHelper {
  static final _coder = FlutterFFmpeg();

  static Future<String> _videoPath(File video) async => '${(await getTemporaryDirectory()).path}${video.path.substring(video.parent.path.length, video.path.length - 4)}';
  static Future<String> thumbnailPath(File video) async => '${await _videoPath(video)}_thumb.jpg';
  static Future<String> convertedVideoPath(File video) async => '${await _videoPath(video)}.hd480.mp4';

  static Future<File> buildThumbnail(File file) async {
    String thumbnailPath = await VideoHelper.thumbnailPath(file);
    await _coder.execute('-ss 1 -i ${file.path} -vframes 1 $thumbnailPath');
    return File(thumbnailPath);
  }

  static Future<File> processVideoForUpload(File original) async {
    String processedVideoPath = await VideoHelper.convertedVideoPath(original);
    await _coder.execute('-i ${original.path} -c:v libx264 -preset fast $processedVideoPath');
    return File(processedVideoPath);
  }

  static File videoForThumbnail(File thumbnail) {
    return File('${thumbnail.path.substring(0, thumbnail.path.length - '_thumb.jpg'.length)}.hd480.mp4');
  }
}