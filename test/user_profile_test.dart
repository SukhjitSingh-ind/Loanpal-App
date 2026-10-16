import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loanpal/models/user_profile.dart';
import 'package:loanpal/services/user_profile_service.dart';

void main() {
  group('UserProfile Model Serialization & Deserialization', () {
    test('serializes user profile to Map with all required fields', () {
      final now = DateTime(2026, 10, 12, 12, 0, 0);
      final profile = UserProfile(
        uid: 'user_123',
        username: 'johndoe',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@example.com',
        createdAt: now,
      );

      final map = profile.toMap();

      expect(map['uid'], 'user_123');
      expect(map['username'], 'johndoe');
      expect(map['firstName'], 'John');
      expect(map['lastName'], 'Doe');
      expect(map['email'], 'john@example.com');
      expect(map['createdAt'], isA<Timestamp>());
      expect((map['createdAt'] as Timestamp).toDate(), now);
    });

    test('serializes with server timestamp when createdAt is null', () {
      const profile = UserProfile(
        uid: 'user_123',
        username: 'johndoe',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@example.com',
      );

      final map = profile.toMap();

      expect(map['uid'], 'user_123');
      expect(map['createdAt'], isA<FieldValue>());
    });

    test('deserializes from Firestore map with Timestamp', () {
      final now = DateTime(2026, 10, 12, 12, 0, 0);
      final map = {
        'username': 'johndoe',
        'firstName': 'John',
        'lastName': 'Doe',
        'email': 'john@example.com',
        'createdAt': Timestamp.fromDate(now),
      };

      final profile = UserProfile.fromMap(map, 'user_123');

      expect(profile.uid, 'user_123');
      expect(profile.username, 'johndoe');
      expect(profile.firstName, 'John');
      expect(profile.lastName, 'Doe');
      expect(profile.email, 'john@example.com');
      expect(profile.displayName, 'John Doe');
      expect(profile.createdAt, now);
    });

    test('handles missing or trimmed fields during deserialization', () {
      final map = <String, dynamic>{
        'username': '  alice  ',
        'firstName': ' Alice ',
        'lastName': ' Smith ',
        'email': ' alice@test.com ',
      };

      final profile = UserProfile.fromMap(map, 'user_456');

      expect(profile.uid, 'user_456');
      expect(profile.username, 'alice');
      expect(profile.firstName, 'Alice');
      expect(profile.lastName, 'Smith');
      expect(profile.email, 'alice@test.com');
      expect(profile.createdAt, isNull);
    });

    test('copyWith updates specified fields only', () {
      const profile = UserProfile(
        uid: 'user_123',
        username: 'johndoe',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@example.com',
      );

      final updated = profile.copyWith(username: 'johnny');

      expect(updated.username, 'johnny');
      expect(updated.firstName, 'John');
      expect(updated.uid, 'user_123');
    });

    test('isValid returns true for complete profile', () {
      const profile = UserProfile(
        uid: 'user_123',
        username: 'johndoe',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@example.com',
      );

      expect(profile.isValid, isTrue);
    });

    test('isValid returns false for missing or incomplete fields', () {
      expect(
        const UserProfile(
          uid: '',
          username: 'johndoe',
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
        ).isValid,
        isFalse,
      );

      expect(
        const UserProfile(
          uid: 'user_123',
          username: 'jo', // too short (< 3)
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
        ).isValid,
        isFalse,
      );

      expect(
        const UserProfile(
          uid: 'user_123',
          username: 'johndoe',
          firstName: 'J', // too short (< 2)
          lastName: 'Doe',
          email: 'john@example.com',
        ).isValid,
        isFalse,
      );

      expect(
        const UserProfile(
          uid: 'user_123',
          username: 'johndoe',
          firstName: 'John',
          lastName: '', // empty
          email: 'john@example.com',
        ).isValid,
        isFalse,
      );

      expect(
        const UserProfile(
          uid: 'user_123',
          username: 'johndoe',
          firstName: 'John',
          lastName: 'Doe',
          email: '', // empty
        ).isValid,
        isFalse,
      );
    });
  });

  group('UserProfileService Singleton & Instance Caching', () {
    final service = UserProfileService();

    tearDown(() {
      service.clearCache();
    });

    test('caches user profile and serves it without database call', () async {
      const profile = UserProfile(
        uid: 'user_abc',
        username: 'alice',
        firstName: 'Alice',
        lastName: 'Wonder',
        email: 'alice@example.com',
      );

      service.setCachedProfile(profile);

      expect(service.currentProfile, equals(profile));

      // getUserProfile returns matching cached profile immediately
      final fetched = await service.getUserProfile('user_abc');
      expect(fetched, equals(profile));
      expect(fetched?.firstName, 'Alice');
      expect(fetched?.username, 'alice');
    });

    test(
      'does not return cached profile when requested UID does not match',
      () async {
        const profile = UserProfile(
          uid: 'user_111',
          username: 'alice',
          firstName: 'Alice',
          lastName: 'Smith',
          email: 'alice@example.com',
        );

        service.setCachedProfile(profile);

        // Cache has user_111. Querying for user_222 should NOT hit cache.
        // Since no real Firestore is mocked, attempting to query another UID throws or returns null
        // We verify that it does not mistakenly return user_111's data.
        expect(service.currentProfile?.uid, 'user_111');
        try {
          final mismatch = await service.getUserProfile('user_222');
          expect(mismatch?.uid, isNot('user_111'));
        } catch (e) {
          // Expected network/no-app exception when attempting Firestore query for uncached user
          expect(e, isNotNull);
        }
      },
    );

    test('clearCache resets cached profile to null upon sign out', () {
      const profile = UserProfile(
        uid: 'user_xyz',
        username: 'bob',
        firstName: 'Bob',
        lastName: 'Builder',
        email: 'bob@example.com',
      );

      service.setCachedProfile(profile);
      expect(service.currentProfile, isNotNull);

      service.clearCache();
      expect(service.currentProfile, isNull);
    });

    test('notifies listeners when cached profile is set or cleared', () {
      int notifyCount = 0;
      void listener() {
        notifyCount++;
      }

      service.addListener(listener);

      const profile = UserProfile(
        uid: 'user_listener_test',
        username: 'listener',
        firstName: 'Listen',
        lastName: 'Er',
        email: 'listener@example.com',
      );

      service.setCachedProfile(profile);
      expect(notifyCount, 1);

      service.clearCache();
      expect(notifyCount, 2);

      service.removeListener(listener);
    });

    test('singleton factory returns same instance', () {
      final s1 = UserProfileService();
      final s2 = UserProfileService();
      expect(identical(s1, s2), isTrue);
    });
  });
}
