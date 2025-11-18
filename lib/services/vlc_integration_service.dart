import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import '../models/video_entry.dart';

class VlcIntegrationService {
  Future<String?> getVlcDatabasePath() async {
    if (Platform.isLinux) {
      final home = Platform.environment['HOME'] ?? '';
      return path.join(home, '.local', 'share', 'vlc', 'vlc.db');
    } else if (Platform.isWindows) {
      final appData = Platform.environment['APPDATA'] ?? '';
      return path.join(appData, 'vlc', 'vlc.db');
    } else if (Platform.isMacOS) {
      final home = Platform.environment['HOME'] ?? '';
      return path.join(home, 'Library', 'Application Support', 'org.videolan.vlc', 'vlc.db');
    }
    return null;
  }

  Future<bool> checkVlcDatabaseExists() async {
    final dbPath = await getVlcDatabasePath();
    if (dbPath == null) return false;
    
    final file = File(dbPath);
    return await file.exists();
  }

  Future<List<Map<String, dynamic>>> readVlcWatchHistory() async {
    final dbPath = await getVlcDatabasePath();
    if (dbPath == null) return [];

    if (!await checkVlcDatabaseExists()) return [];

    try {
      final database = await openDatabase(dbPath, readOnly: true);
      
      // VLC stores watch history in the 'media' table
      final List<Map<String, dynamic>> maps = await database.query(
        'media',
        columns: ['id', 'filename', 'insertion_date', 'last_played_date', 'play_count'],
        orderBy: 'last_played_date DESC',
      );

      await database.close();
      return maps;
    } catch (e) {
      return [];
    }
  }

  Future<List<VideoEntry>> importVlcHistory(String userId) async {
    final vlcHistory = await readVlcWatchHistory();
    final now = DateTime.now();
    final entries = <VideoEntry>[];

    for (final record in vlcHistory) {
      final fileName = record['filename'] as String?;
      if (fileName == null) continue;

      final lastPlayed = record['last_played_date'] as int?;
      final playCount = record['play_count'] as int? ?? 0;

      final entry = VideoEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString() + entries.length.toString(),
        userId: userId,
        title: _extractTitleFromPath(fileName),
        filePath: fileName,
        status: playCount > 0 ? WatchStatus.inProgress : WatchStatus.notStarted,
        createdAt: now,
        updatedAt: lastPlayed != null 
            ? DateTime.fromMillisecondsSinceEpoch(lastPlayed * 1000)
            : now,
        lastWatchedDate: lastPlayed != null 
            ? DateTime.fromMillisecondsSinceEpoch(lastPlayed * 1000)
            : null,
      );

      entries.add(entry);
    }

    return entries;
  }

  String _extractTitleFromPath(String filePath) {
    final fileName = path.basenameWithoutExtension(filePath);
    return fileName
        .replaceAll(RegExp(r'\[.*?\]'), '')
        .replaceAll(RegExp(r'\(.*?\)'), '')
        .replaceAll(RegExp(r'\.'), ' ')
        .trim();
  }
}

