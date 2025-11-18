import 'package:flutter/foundation.dart';
import '../models/video_entry.dart';
import '../services/firebase_service.dart';
import '../services/local_storage_service.dart';

class VideoProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final LocalStorageService _localStorageService = LocalStorageService();

  List<VideoEntry> _videos = [];
  bool _isLoading = false;
  String? _error;

  List<VideoEntry> get videos => _videos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<VideoEntry> get recentVideos {
    return _videos
        .where((v) => v.lastWatchedDate != null)
        .toList()
      ..sort((a, b) => b.lastWatchedDate!.compareTo(a.lastWatchedDate!));
  }

  List<VideoEntry> get continueWatching {
    return _videos
        .where((v) => v.status == WatchStatus.inProgress && v.progress > 0)
        .toList()
      ..sort((a, b) => b.lastWatchedDate!.compareTo(a.lastWatchedDate!));
  }

  List<VideoEntry> get completedVideos {
    return _videos.where((v) => v.status == WatchStatus.completed).toList();
  }

  Future<void> loadVideos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = _firebaseService.currentUser;
      if (user != null) {
        // Load from Firebase
        _firebaseService.getVideoEntries().listen((videos) {
          _videos = videos;
          _isLoading = false;
          notifyListeners();
        });
      } else {
        // Load from local storage
        _videos = await _localStorageService.getLocalVideoEntries();
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addVideo(VideoEntry entry) async {
    try {
      final user = _firebaseService.currentUser;
      if (user != null) {
        await _firebaseService.addVideoEntry(entry);
      } else {
        await _localStorageService.saveVideoEntryLocally(entry);
        _videos.add(entry);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateVideo(VideoEntry entry) async {
    try {
      final updatedEntry = entry.copyWith(updatedAt: DateTime.now());
      final user = _firebaseService.currentUser;
      
      if (user != null) {
        await _firebaseService.updateVideoEntry(updatedEntry);
      } else {
        await _localStorageService.saveVideoEntryLocally(updatedEntry);
        final index = _videos.indexWhere((v) => v.id == entry.id);
        if (index != -1) {
          _videos[index] = updatedEntry;
          notifyListeners();
        }
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteVideo(String entryId) async {
    try {
      final user = _firebaseService.currentUser;
      if (user != null) {
        await _firebaseService.deleteVideoEntry(entryId);
      } else {
        await _localStorageService.deleteLocalVideoEntry(entryId);
        _videos.removeWhere((v) => v.id == entryId);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProgress(String entryId, double progress) async {
    final video = _videos.firstWhere((v) => v.id == entryId);
    final now = DateTime.now();
    
    final updatedVideo = video.copyWith(
      progress: progress.clamp(0.0, 1.0),
      status: progress >= 0.95 ? WatchStatus.completed : WatchStatus.inProgress,
      lastWatchedDate: now,
      startedDate: video.startedDate ?? now,
      completedDate: progress >= 0.95 ? now : video.completedDate,
    );

    await updateVideo(updatedVideo);
  }

  Future<void> addWatchSession(String entryId, WatchSession session) async {
    final video = _videos.firstWhere((v) => v.id == entryId);
    final sessions = List<WatchSession>.from(video.watchSessions)..add(session);
    
    final totalTime = sessions
        .where((s) => s.duration != null)
        .fold<Duration>(
          Duration.zero,
          (sum, s) => sum + s.duration!,
        );

    final updatedVideo = video.copyWith(
      watchSessions: sessions,
      timeWatched: totalTime,
      lastWatchedDate: session.endTime ?? session.startTime,
    );

    await updateVideo(updatedVideo);
  }
}

