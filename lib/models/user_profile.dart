import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a LoanPal user profile stored in Cloud Firestore.
///
/// Contains personal profile metadata associated with an authenticated
/// Firebase Authentication UID. Never stores passwords or credentials.
class UserProfile {
  final String uid;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final DateTime? createdAt;

  const UserProfile({
    required this.uid,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.createdAt,
  });

  /// Full formatted name for display.
  String get displayName => '$firstName $lastName'.trim();

  /// Checks whether the user profile has all required fields to be considered valid and complete.
  bool get isValid =>
      uid.trim().isNotEmpty &&
      username.trim().length >= 3 &&
      firstName.trim().length >= 2 &&
      lastName.trim().length >= 2 &&
      email.trim().isNotEmpty;

  /// Converts the profile instance into a Map for Firestore persistence.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  /// Deserializes a Firestore document snapshot map into a [UserProfile].
  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    DateTime? parsedDate;
    final createdVal = map['createdAt'];
    if (createdVal is Timestamp) {
      parsedDate = createdVal.toDate();
    } else if (createdVal is String) {
      parsedDate = DateTime.tryParse(createdVal);
    }

    return UserProfile(
      uid: uid,
      username: (map['username'] as String? ?? '').trim(),
      firstName: (map['firstName'] as String? ?? '').trim(),
      lastName: (map['lastName'] as String? ?? '').trim(),
      email: (map['email'] as String? ?? '').trim(),
      createdAt: parsedDate,
    );
  }

  UserProfile copyWith({
    String? uid,
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    DateTime? createdAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
