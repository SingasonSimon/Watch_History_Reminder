import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../core/constants/app_constants.dart';
import 'package:video_player/video_player.dart';

class FileScannerService {
  Future<List<String>> scanDirectoryForVideos(String directoryPath) async {
    final directory = Directory(directoryPath);
    if (!await directory.exists()) return [];

    final videoFiles = <String>[];
    
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File) {
        final extension = path.extension(entity.path).toLowerCase();
        if (AppConstants.videoFormats.contains(extension)) {
          videoFiles.add(entity.path);
        }
      }
    }

    return videoFiles;
  }

  Future<String?> pickVideoFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      return result.files.single.path;
    }
    return null;
  }

  Future<List<String>> pickMultipleVideoFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: true,
    );

    if (result != null) {
      return result.files
          .where((file) => file.path != null)
          .map((file) => file.path!)
          .toList();
    }
    return [];
  }

  Future<Map<String, dynamic>?> getVideoMetadata(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final fileSize = await file.length();
      final fileName = path.basename(filePath);
      final extension = path.extension(filePath).toLowerCase();
      
      // Try to get duration using video_player
      Duration? duration;
      try {
        final controller = VideoPlayerController.file(file);
        await controller.initialize();
        duration = controller.value.duration;
        await controller.dispose();
      } catch (e) {
        // If video_player fails, duration will remain null
      }

      return {
        'filePath': filePath,
        'fileName': fileName,
        'fileSize': fileSize,
        'format': extension,
        'duration': duration,
      };
    } catch (e) {
      return null;
    }
  }

  String extractTitleFromPath(String filePath) {
    final fileName = path.basenameWithoutExtension(filePath);
    // Remove common patterns like [1080p], (2023), etc.
    return fileName
        .replaceAll(RegExp(r'\[.*?\]'), '')
        .replaceAll(RegExp(r'\(.*?\)'), '')
        .replaceAll(RegExp(r'\.'), ' ')
        .trim();
  }
}

