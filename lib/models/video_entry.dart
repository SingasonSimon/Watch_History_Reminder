import 'package:cloud_firestore/cloud_firestore.dart';

enum WatchStatus {
  notStarted,
  inProgress,
  completed,
  dropped,
}

class WatchSession {
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;

  WatchSession({
    required this.startTime,
    this.endTime,
    this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'duration': duration?.inSeconds,
    };
  }

  factory WatchSession.fromMap(Map<String, dynamic> map) {
    return WatchSession(
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      duration: map['duration'] != null ? Duration(seconds: map['duration']) : null,
    );
  }
}

class VideoEntry {
  final String id;
  final String userId;
  final String title;
  final String? filePath;
  final Duration? duration;
  final int? fileSize;
  final String? format;
  final String? resolution;
  final String? thumbnailUrl;
  final WatchStatus status;
  final double progress; // 0.0 to 1.0
  final Duration? timeWatched;
  final List<WatchSession> watchSessions;
  final DateTime? startedDate;
  final DateTime? lastWatchedDate;
  final DateTime? completedDate;
  final double? rating; // 1.0 to 10.0
  final List<String> notes;
  final List<String> tags;
  final List<String> genres;
  final DateTime createdAt;
  final DateTime updatedAt;

  VideoEntry({
    required this.id,
    required this.userId,
    required this.title,
    this.filePath,
    this.duration,
    this.fileSize,
    this.format,
    this.resolution,
    this.thumbnailUrl,
    this.status = WatchStatus.notStarted,
    this.progress = 0.0,
    this.timeWatched,
    this.watchSessions = const [],
    this.startedDate,
    this.lastWatchedDate,
    this.completedDate,
    this.rating,
    this.notes = const [],
    this.tags = const [],
    this.genres = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'filePath': filePath,
      'duration': duration?.inSeconds,
      'fileSize': fileSize,
      'format': format,
      'resolution': resolution,
      'thumbnailUrl': thumbnailUrl,
      'status': status.name,
      'progress': progress,
      'timeWatched': timeWatched?.inSeconds,
      'watchSessions': watchSessions.map((s) => s.toMap()).toList(),
      'startedDate': startedDate?.toIso8601String(),
      'lastWatchedDate': lastWatchedDate?.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'rating': rating,
      'notes': notes,
      'tags': tags,
      'genres': genres,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory VideoEntry.fromMap(Map<String, dynamic> map) {
    return VideoEntry(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      filePath: map['filePath'],
      duration: map['duration'] != null ? Duration(seconds: map['duration']) : null,
      fileSize: map['fileSize'],
      format: map['format'],
      resolution: map['resolution'],
      thumbnailUrl: map['thumbnailUrl'],
      status: WatchStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => WatchStatus.notStarted,
      ),
      progress: (map['progress'] ?? 0.0).toDouble(),
      timeWatched: map['timeWatched'] != null ? Duration(seconds: map['timeWatched']) : null,
      watchSessions: (map['watchSessions'] as List<dynamic>?)
              ?.map((s) => WatchSession.fromMap(s as Map<String, dynamic>))
              .toList() ??
          [],
      startedDate: map['startedDate'] != null ? DateTime.parse(map['startedDate']) : null,
      lastWatchedDate: map['lastWatchedDate'] != null ? DateTime.parse(map['lastWatchedDate']) : null,
      completedDate: map['completedDate'] != null ? DateTime.parse(map['completedDate']) : null,
      rating: map['rating']?.toDouble(),
      notes: List<String>.from(map['notes'] ?? []),
      tags: List<String>.from(map['tags'] ?? []),
      genres: List<String>.from(map['genres'] ?? []),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  factory VideoEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VideoEntry.fromMap({...data, 'id': doc.id});
  }

  VideoEntry copyWith({
    String? id,
    String? userId,
    String? title,
    String? filePath,
    Duration? duration,
    int? fileSize,
    String? format,
    String? resolution,
    String? thumbnailUrl,
    WatchStatus? status,
    double? progress,
    Duration? timeWatched,
    List<WatchSession>? watchSessions,
    DateTime? startedDate,
    DateTime? lastWatchedDate,
    DateTime? completedDate,
    double? rating,
    List<String>? notes,
    List<String>? tags,
    List<String>? genres,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VideoEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      duration: duration ?? this.duration,
      fileSize: fileSize ?? this.fileSize,
      format: format ?? this.format,
      resolution: resolution ?? this.resolution,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      timeWatched: timeWatched ?? this.timeWatched,
      watchSessions: watchSessions ?? this.watchSessions,
      startedDate: startedDate ?? this.startedDate,
      lastWatchedDate: lastWatchedDate ?? this.lastWatchedDate,
      completedDate: completedDate ?? this.completedDate,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      genres: genres ?? this.genres,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

