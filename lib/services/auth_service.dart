import 'package:firebase_auth/firebase_auth.dart';
import 'package:loanpal/models/user_profile.dart';
import 'package:loanpal/services/user_profile_service.dart';

/// Custom exception thrown when Firebase account creation succeeds,
/// but writing the user's Firestore profile fails.
class ProfileCreationException implements Exception {
  final String uid;
  final String message;

  ProfileCreationException({required this.uid, required this.message});

  @override
  String toString() => message;
}

/// Service handling Firebase Authentication operations and coordinating
/// user profile persistence.
class AuthService {
  final FirebaseAuth? _injectedAuth;
  final UserProfileService _profileService;

  AuthService({FirebaseAuth? auth, UserProfileService? profileService})
    : _injectedAuth = auth,
      _profileService = profileService ?? UserProfileService();

  FirebaseAuth get _auth => _injectedAuth ?? FirebaseAuth.instance;

  /// Stream of authentication state changes.
  Stream<User?> get authStateChanges {
    try {
      return _auth.authStateChanges();
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Currently authenticated Firebase user, if any.
  User? get currentUser {
    try {
      return _auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// Signs in a user using email and password.
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred during sign in. Please try again.';
    }
  }

  /// Registers a new user with Firebase Authentication and persists their
  /// profile in Cloud Firestore.
  ///
  /// If the Firestore profile write fails after account creation, a
  /// [ProfileCreationException] is thrown containing the user's UID for recovery.
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String firstName,
    required String lastName,
  }) async {
    UserCredential credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred during registration. Please try again.';
    }

    final user = credential.user;
    if (user != null) {
      final profile = UserProfile(
        uid: user.uid,
        username: username.trim(),
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        email: email.trim(),
      );

      // INFO: Pre-cache in-memory profile immediately so AuthGate stream listener does not race with Firestore document write.
      _profileService.setCachedProfile(profile);

      try {
        await _profileService.createUserProfile(profile);
      } catch (profileError) {
        _profileService.setCachedProfile(null);
        throw ProfileCreationException(
          uid: user.uid,
          message:
              'Account created, but could not set up user profile. Please complete your profile to continue.',
        );
      }

      try {
        await user.updateDisplayName('$firstName $lastName'.trim());
      } catch (_) {
        // INFO: Best-effort sync; failure to set Auth displayName does not block registration.
      }
    }

    return credential;
  }

  /// Signs out the currently authenticated user.
  Future<void> signOut() async {
    try {
      _profileService.clearCache();
      await _auth.signOut();
    } catch (e) {
      throw 'Failed to sign out. Please try again.';
    }
  }

  /// Translates [FirebaseAuthException] codes into user-friendly messages.
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account already exists for this email address.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network connection error. Please check your internet connection.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled for this project.';
      default:
        return 'Authentication failed: ${e.message ?? "Please try again."}';
    }
  }
}
