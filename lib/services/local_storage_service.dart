import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/video_entry.dart';

class LocalStorageService {
  static const String _videosKey = 'local_videos';
  static const String _draftKey = 'draft_video';

  Future<void> saveVideoEntryLocally(VideoEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final videos = await getLocalVideoEntries();
    
    // Remove existing entry if present
    videos.removeWhere((v) => v.id == entry.id);
    videos.add(entry);
    
    final jsonList = videos.map((v) => v.toMap()).toList();
    await prefs.setString(_videosKey, jsonEncode(jsonList));
  }

  Future<List<VideoEntry>> getLocalVideoEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_videosKey);
    
    if (jsonString == null) return [];
    
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => VideoEntry.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> deleteLocalVideoEntry(String entryId) async {
    final prefs = await SharedPreferences.getInstance();
    final videos = await getLocalVideoEntries();
    
    videos.removeWhere((v) => v.id == entryId);
    
    final jsonList = videos.map((v) => v.toMap()).toList();
    await prefs.setString(_videosKey, jsonEncode(jsonList));
  }

  Future<void> saveDraft(VideoEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_draftKey, jsonEncode(entry.toMap()));
  }

  Future<VideoEntry?> getDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_draftKey);
    
    if (jsonString == null) return null;
    
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return VideoEntry.fromMap(json);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
  }

  Future<void> clearAllLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_videosKey);
    await prefs.remove(_draftKey);
  }
}

