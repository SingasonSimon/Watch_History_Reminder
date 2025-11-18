import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/video_entry.dart';
import '../core/constants/app_constants.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Auth Methods
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Video Entry Methods
  Future<void> addVideoEntry(VideoEntry entry) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore
        .collection(AppConstants.videosCollection)
        .doc(entry.id)
        .set(entry.toMap());
  }

  Future<void> updateVideoEntry(VideoEntry entry) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore
        .collection(AppConstants.videosCollection)
        .doc(entry.id)
        .update(entry.toMap());
  }

  Future<void> deleteVideoEntry(String entryId) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore
        .collection(AppConstants.videosCollection)
        .doc(entryId)
        .delete();
  }

  Future<VideoEntry?> getVideoEntry(String entryId) async {
    final doc = await _firestore
        .collection(AppConstants.videosCollection)
        .doc(entryId)
        .get();

    if (!doc.exists) return null;
    return VideoEntry.fromFirestore(doc);
  }

  Stream<List<VideoEntry>> getVideoEntries() {
    final user = currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection(AppConstants.videosCollection)
        .where('userId', isEqualTo: user.uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VideoEntry.fromFirestore(doc))
            .toList());
  }

  Stream<List<VideoEntry>> getVideoEntriesByStatus(String status) {
    final user = currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection(AppConstants.videosCollection)
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: status)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VideoEntry.fromFirestore(doc))
            .toList());
  }

  // Storage Methods
  Future<String> uploadThumbnail(String entryId, Uint8List imageBytes) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    final ref = _storage
        .ref()
        .child(AppConstants.thumbnailsPath)
        .child(user.uid)
        .child('$entryId.jpg');

    await ref.putData(imageBytes);
    return await ref.getDownloadURL();
  }

  Future<void> deleteThumbnail(String entryId) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    final ref = _storage
        .ref()
        .child(AppConstants.thumbnailsPath)
        .child(user.uid)
        .child('$entryId.jpg');

    try {
      await ref.delete();
    } catch (e) {
      // Ignore if file doesn't exist
    }
  }

  // Enable offline persistence
  Future<void> enableOfflinePersistence() async {
    await _firestore.enablePersistence();
  }
}

