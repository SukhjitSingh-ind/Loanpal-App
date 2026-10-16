import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loanpal/models/user_profile.dart';
import 'package:loanpal/services/auth_service.dart';
import 'package:loanpal/services/user_profile_service.dart';
import 'package:loanpal/ui/auth/login_screen.dart';
import 'package:loanpal/ui/auth/profile_completion_screen.dart';
import 'package:loanpal/ui/calculator_screen.dart';
import 'package:loanpal/ui/theme.dart';

/// Authentication Gate (Option A) that listens to Firebase Authentication state
/// and routes the user between authentication, profile recovery, and the calculator.
class AuthGate extends StatefulWidget {
  final AuthService? authService;
  final UserProfileService? profileService;

  const AuthGate({super.key, this.authService, this.profileService});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final _authService = widget.authService ?? AuthService();
  late final _profileService = widget.profileService ?? UserProfileService();

  // Key to force reload profile check when profile is completed
  int _refreshCounter = 0;

  void _onProfileRefresh() {
    if (mounted) {
      setState(() {
        _refreshCounter++;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _profileService.addListener(_onProfileRefresh);
  }

  @override
  void dispose() {
    _profileService.removeListener(_onProfileRefresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, authSnapshot) {
        // While Firebase is evaluating local cached session
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: LoanPalTheme.background,
            body: Center(
              child: CircularProgressIndicator(color: LoanPalTheme.primaryNavy),
            ),
          );
        }

        final user = authSnapshot.data;

        // Unauthenticated -> Show Login
        if (user == null) {
          return LoginScreen(authService: _authService);
        }

        // Fast path: If a valid in-memory profile is already available for this user
        // (e.g. set during normal registration), transition immediately to Calculator.
        final cached = _profileService.currentProfile;
        if (cached != null && cached.uid == user.uid && cached.isValid) {
          return CalculatorScreen(
            userProfile: cached,
            onSignOut: () => _authService.signOut(),
          );
        }

        // Authenticated -> Verify Firestore user profile
        return FutureBuilder<UserProfile?>(
          key: ValueKey('${user.uid}_$_refreshCounter'),
          future: _profileService.getUserProfile(user.uid),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: LoanPalTheme.background,
                body: Center(
                  child: CircularProgressIndicator(
                    color: LoanPalTheme.primaryNavy,
                  ),
                ),
              );
            }

            if (profileSnapshot.hasError) {
              return Scaffold(
                backgroundColor: LoanPalTheme.background,
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_off_rounded,
                          size: 56,
                          color: LoanPalTheme.burdenHeavy,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Connection Error',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: LoanPalTheme.textMain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          profileSnapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: LoanPalTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton(
                              onPressed: () => _authService.signOut(),
                              child: const Text('Sign Out'),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: _onProfileRefresh,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: LoanPalTheme.primaryNavy,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final profile = profileSnapshot.data;

            // Missing or invalid profile recovery flow
            if (profile == null || !profile.isValid) {
              return ProfileCompletionScreen(
                user: user,
                onProfileCompleted: _onProfileRefresh,
                onSignOut: () => _authService.signOut(),
                profileService: _profileService,
              );
            }

            // Valid authenticated user with verified profile
            return CalculatorScreen(
              userProfile: profile,
              onSignOut: () => _authService.signOut(),
            );
          },
        );
      },
    );
  }
}
