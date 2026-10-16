import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:loanpal/models/user_profile.dart';

/// Service responsible for managing user profile documents in Cloud Firestore.
///
/// Stores and retrieves user data within the `users` collection using the
/// user's Firebase Authentication UID as the document ID.
class UserProfileService extends ChangeNotifier {
  static final UserProfileService _instance = UserProfileService._internal();

  /// Factory returning the shared singleton instance, or an isolated instance
  /// if a custom [firestore] instance is injected for testing.
  factory UserProfileService({FirebaseFirestore? firestore}) {
    if (firestore != null) {
      return UserProfileService._internal(firestore: firestore);
    }
    return _instance;
  }

  UserProfileService._internal({FirebaseFirestore? firestore})
    : _injectedFirestore = firestore;

  final FirebaseFirestore? _injectedFirestore;

  // INFO: Instance-level cache belonging to this service instance.
  UserProfile? _cachedProfile;

  FirebaseFirestore get _firestore =>
      _injectedFirestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  /// The currently cached in-memory user profile, if available.
  UserProfile? get currentProfile => _cachedProfile;

  /// Sets or updates the in-memory cached profile and notifies listeners.
  void setCachedProfile(UserProfile? profile) {
    _cachedProfile = profile;
    notifyListeners();
  }

  /// Clears the cached profile upon sign-out and notifies listeners.
  void clearCache() {
    _cachedProfile = null;
    notifyListeners();
  }

  /// Creates or updates a user profile document idempotently in Firestore.
  ///
  /// Uses [SetOptions(merge: true)] to prevent accidental overwriting of
  /// pre-existing fields during recovery or retry attempts.
  Future<void> createUserProfile(UserProfile profile) async {
    try {
      _cachedProfile = profile;
      notifyListeners();
      final docRef = _usersCollection.doc(profile.uid);
      final existingDoc = await docRef.get();
      if (existingDoc.exists && existingDoc.data() != null) {
        final existingCreatedAt = existingDoc.data()!['createdAt'];
        final data = profile.toMap();
        if (existingCreatedAt != null) {
          data['createdAt'] = existingCreatedAt;
        }
        await docRef.set(data, SetOptions(merge: true));
      } else {
        await docRef.set(profile.toMap());
      }
    } catch (e) {
      _cachedProfile = null;
      notifyListeners();
      throw Exception('Failed to save user profile: ${e.toString()}');
    }
  }

  /// Retrieves a user profile by [uid] from Firestore.
  ///
  /// Returns cached profile if matching [uid], or queries Firestore.
  /// Returns null if the document does not exist.
  Future<UserProfile?> getUserProfile(String uid) async {
    if (_cachedProfile != null && _cachedProfile!.uid == uid) {
      return _cachedProfile;
    }
    try {
      final docSnapshot = await _usersCollection.doc(uid).get();
      if (!docSnapshot.exists || docSnapshot.data() == null) {
        return null;
      }
      final profile = UserProfile.fromMap(docSnapshot.data()!, uid);
      _cachedProfile = profile;
      return profile;
    } catch (e) {
      throw Exception('Failed to load user profile: ${e.toString()}');
    }
  }
}
