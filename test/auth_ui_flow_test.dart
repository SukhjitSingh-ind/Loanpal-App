import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loanpal/main.dart';
import 'package:loanpal/models/user_profile.dart';
import 'package:loanpal/services/auth_service.dart';
import 'package:loanpal/services/user_profile_service.dart';
import 'package:loanpal/ui/auth/auth_gate.dart';
import 'package:loanpal/ui/auth/login_screen.dart';
import 'package:loanpal/ui/auth/profile_completion_screen.dart';
import 'package:loanpal/ui/auth/register_screen.dart';
import 'package:loanpal/ui/calculator_screen.dart';
import 'package:loanpal/ui/theme.dart';

void main() {
  group('Firebase Initialization Error Handling', () {
    testWidgets('renders dedicated error screen when initialization fails', (
      WidgetTester tester,
    ) async {
      bool retryCalled = false;
      final testError = Exception('Simulated network connectivity timeout');

      await tester.pumpWidget(
        LoanPalApp(
          initializationError: testError,
          onRetryInitialization: () async {
            retryCalled = true;
          },
        ),
      );

      expect(find.text('Service Initialization Failed'), findsOneWidget);
      expect(
        find.text(
          'LoanPal could not connect to required cloud services. Please check your internet connection and try again.',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
      expect(find.text('Retry Connection'), findsOneWidget);

      await tester.tap(find.text('Retry Connection'));
      await tester.pump();

      expect(retryCalled, isTrue);
    });
  });

  group('LoginScreen UI & Validation Flow', () {
    testWidgets('renders brand title, email, password, and sign in button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: LoanPalTheme.lightTheme, home: const LoginScreen()),
      );

      expect(find.text('Welcome to LoanPal'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets('triggers validation errors on empty submission', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: LoanPalTheme.lightTheme, home: const LoginScreen()),
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      expect(find.text('Email address is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('toggles password visibility icon', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: LoanPalTheme.lightTheme, home: const LoginScreen()),
      );

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });
  });

  group('RegisterScreen UI & Validation Flow', () {
    testWidgets('renders all required registration fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: LoanPalTheme.lightTheme,
          home: const RegisterScreen(),
        ),
      );

      expect(find.text('Join LoanPal'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('First Name'), findsOneWidget);
      expect(find.text('Last Name'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(
        find.widgetWithText(ElevatedButton, 'Create Account'),
        findsOneWidget,
      );
    });

    testWidgets('shows validation errors when fields are empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: LoanPalTheme.lightTheme,
          home: const RegisterScreen(),
        ),
      );

      final submitBtn = find.widgetWithText(ElevatedButton, 'Create Account');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pump();

      expect(find.text('Username is required'), findsOneWidget);
      expect(find.text('First name is required'), findsOneWidget);
      expect(find.text('Last name is required'), findsOneWidget);
      expect(find.text('Email address is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(find.text('Please confirm your password'), findsOneWidget);
    });

    testWidgets('shows validation error when passwords do not match', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: LoanPalTheme.lightTheme,
          home: const RegisterScreen(),
        ),
      );

      final formFields = find.byType(TextFormField);
      expect(formFields, findsNWidgets(6));

      // Enter fields: 0=Username, 1=First Name, 2=Last Name, 3=Email, 4=Password, 5=Confirm Password
      await tester.enterText(formFields.at(0), 'johndoe');
      await tester.enterText(formFields.at(1), 'John');
      await tester.enterText(formFields.at(2), 'Doe');
      await tester.enterText(formFields.at(3), 'john@example.com');
      await tester.enterText(formFields.at(4), 'Password123');
      await tester.enterText(formFields.at(5), 'Password999');

      final submitBtn = find.widgetWithText(ElevatedButton, 'Create Account');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });

  group('CalculatorScreen User Identity & Privacy Greeting', () {
    testWidgets(
      'displays personalized greeting with first name and privacy tagline (no email leak)',
      (WidgetTester tester) async {
        const profile = UserProfile(
          uid: 'user_123',
          username: 'johndoe',
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: LoanPalTheme.lightTheme,
            home: const CalculatorScreen(userProfile: profile),
          ),
        );

        // First name and initial are displayed
        expect(find.text('Hi, John!'), findsOneWidget);
        expect(find.text('J'), findsOneWidget);

        // Privacy: neutral tagline is displayed, private email address is NOT shown
        expect(find.text('Smart EMI & Loan Planner'), findsOneWidget);
        expect(find.text('john@example.com'), findsNothing);
      },
    );

    testWidgets(
      'displays username greeting when first name is empty without leaking email',
      (WidgetTester tester) async {
        const profile = UserProfile(
          uid: 'user_456',
          username: 'fintech_guru',
          firstName: '',
          lastName: '',
          email: 'guru@example.com',
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: LoanPalTheme.lightTheme,
            home: const CalculatorScreen(userProfile: profile),
          ),
        );

        expect(find.text('Hi, fintech_guru!'), findsOneWidget);
        expect(find.text('F'), findsOneWidget);
        expect(find.text('Smart EMI & Loan Planner'), findsOneWidget);
        expect(find.text('guru@example.com'), findsNothing);
      },
    );

    testWidgets('displays fallback greeting when profile is not provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: LoanPalTheme.lightTheme,
          home: const CalculatorScreen(),
        ),
      );

      expect(find.text('Welcome to LoanPal'), findsOneWidget);
      expect(find.text('Smart EMI & Loan Planner'), findsOneWidget);
      expect(find.text('L'), findsOneWidget);
    });
  });

  group('Decoupled Sign-Out Integration', () {
    testWidgets('CalculatorScreen delegates sign out to callback', (
      WidgetTester tester,
    ) async {
      bool signedOut = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: LoanPalTheme.lightTheme,
          home: CalculatorScreen(
            onSignOut: () async {
              signedOut = true;
            },
          ),
        ),
      );

      final signOutButton = find.byTooltip('Sign Out');
      expect(signOutButton, findsOneWidget);

      await tester.tap(signOutButton);
      await tester.pumpAndSettle();

      expect(find.text('SIGN OUT'), findsOneWidget);

      await tester.tap(find.text('SIGN OUT'));
      await tester.pumpAndSettle();

      expect(signedOut, isTrue);
    });
  });

  group('AuthGate Routing & Normal Registration Flow', () {
    testWidgets('routes to LoginScreen when user is unauthenticated', (
      WidgetTester tester,
    ) async {
      final fakeAuth = FakeAuthService();
      final fakeProfile = FakeUserProfileService();

      await tester.pumpWidget(
        MaterialApp(
          theme: LoanPalTheme.lightTheme,
          home: AuthGate(authService: fakeAuth, profileService: fakeProfile),
        ),
      );

      // Initially stream emits null
      fakeAuth.emitUser(null);
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(CalculatorScreen), findsNothing);
      expect(find.byType(ProfileCompletionScreen), findsNothing);
    });

    testWidgets(
      'routes directly to CalculatorScreen with personalized greeting during normal registration (never shows ProfileCompletionScreen)',
      (WidgetTester tester) async {
        const user = FakeUser(
          uid: 'user_registered',
          email: 'alice@example.com',
          displayName: 'Alice Smith',
        );
        const validProfile = UserProfile(
          uid: 'user_registered',
          username: 'alicesmith',
          firstName: 'Alice',
          lastName: 'Smith',
          email: 'alice@example.com',
        );

        final fakeAuth = FakeAuthService();
        final fakeProfile = FakeUserProfileService(cached: validProfile);

        await tester.pumpWidget(
          MaterialApp(
            theme: LoanPalTheme.lightTheme,
            home: AuthGate(authService: fakeAuth, profileService: fakeProfile),
          ),
        );

        fakeAuth.emitUser(user);
        await tester.pumpAndSettle();

        // Must show Calculator directly
        expect(find.byType(CalculatorScreen), findsOneWidget);
        expect(find.text('Hi, Alice!'), findsOneWidget);

        // Crucial acceptance criterion: Profile completion MUST NOT be shown
        expect(find.byType(ProfileCompletionScreen), findsNothing);
        expect(find.text('Almost There!'), findsNothing);
      },
    );

    testWidgets(
      'routes to ProfileCompletionScreen when authenticated user has no Firestore profile (recovery scenario)',
      (WidgetTester tester) async {
        const user = FakeUser(
          uid: 'user_missing_profile',
          email: 'lost@example.com',
          displayName: 'Lost User',
        );

        final fakeAuth = FakeAuthService();
        final fakeProfile = FakeUserProfileService(
          cached: null,
          firestoreProfile: null,
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: LoanPalTheme.lightTheme,
            home: AuthGate(authService: fakeAuth, profileService: fakeProfile),
          ),
        );

        fakeAuth.emitUser(user);
        await tester.pumpAndSettle();

        // Recovery screen is displayed
        expect(find.byType(ProfileCompletionScreen), findsOneWidget);
        expect(find.text('Almost There!'), findsOneWidget);
        expect(find.byType(CalculatorScreen), findsNothing);
      },
    );

    testWidgets(
      'routes to ProfileCompletionScreen when Firestore profile is incomplete/invalid',
      (WidgetTester tester) async {
        const user = FakeUser(
          uid: 'user_incomplete',
          email: 'incomplete@example.com',
        );
        // Profile with empty firstName & username is incomplete (!isValid)
        const incompleteProfile = UserProfile(
          uid: 'user_incomplete',
          username: '',
          firstName: '',
          lastName: 'Doe',
          email: 'incomplete@example.com',
        );

        final fakeAuth = FakeAuthService();
        final fakeProfile = FakeUserProfileService(
          cached: null,
          firestoreProfile: incompleteProfile,
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: LoanPalTheme.lightTheme,
            home: AuthGate(authService: fakeAuth, profileService: fakeProfile),
          ),
        );

        fakeAuth.emitUser(user);
        await tester.pumpAndSettle();

        expect(find.byType(ProfileCompletionScreen), findsOneWidget);
        expect(find.byType(CalculatorScreen), findsNothing);
      },
    );

    testWidgets(
      'ProfileCompletionScreen completes profile and transitions to CalculatorScreen',
      (WidgetTester tester) async {
        const user = FakeUser(
          uid: 'user_recover',
          email: 'recover@example.com',
          displayName: 'Recover User',
        );

        final fakeProfile = FakeUserProfileService();
        bool completedCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: LoanPalTheme.lightTheme,
            home: ProfileCompletionScreen(
              user: user,
              profileService: fakeProfile,
              onProfileCompleted: () {
                completedCalled = true;
              },
            ),
          ),
        );

        // Pre-populated names from displayName
        expect(find.text('Recover'), findsOneWidget);
        expect(find.text('User'), findsOneWidget);

        // Enter username
        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.at(0), 'recovered_user');

        final saveBtn = find.widgetWithText(
          ElevatedButton,
          'Save and Continue',
        );
        await tester.ensureVisible(saveBtn);
        await tester.tap(saveBtn);
        await tester.pumpAndSettle();

        expect(completedCalled, isTrue);
        expect(fakeProfile.currentProfile, isNotNull);
        expect(fakeProfile.currentProfile?.username, 'recovered_user');
        expect(fakeProfile.currentProfile?.isValid, isTrue);
      },
    );

    testWidgets(
      'RegisterScreen captures username, first name, and last name once during registration',
      (WidgetTester tester) async {
        final fakeAuth = FakeAuthService();

        await tester.pumpWidget(
          MaterialApp(
            theme: LoanPalTheme.lightTheme,
            home: RegisterScreen(authService: fakeAuth),
          ),
        );

        final formFields = find.byType(TextFormField);
        expect(formFields, findsNWidgets(6));

        // 0=Username, 1=First Name, 2=Last Name, 3=Email, 4=Password, 5=Confirm Password
        await tester.enterText(formFields.at(0), 'alexsmith');
        await tester.enterText(formFields.at(1), 'Alex');
        await tester.enterText(formFields.at(2), 'Smith');
        await tester.enterText(formFields.at(3), 'alex@example.com');
        await tester.enterText(formFields.at(4), 'Secret123');
        await tester.enterText(formFields.at(5), 'Secret123');

        final submitBtn = find.widgetWithText(ElevatedButton, 'Create Account');
        await tester.ensureVisible(submitBtn);
        await tester.tap(submitBtn);
        await tester.pumpAndSettle();

        // Verification: Captured all fields accurately in one submission
        expect(fakeAuth.lastRegisteredData, isNotNull);
        expect(fakeAuth.lastRegisteredData?['username'], 'alexsmith');
        expect(fakeAuth.lastRegisteredData?['firstName'], 'Alex');
        expect(fakeAuth.lastRegisteredData?['lastName'], 'Smith');
        expect(fakeAuth.lastRegisteredData?['email'], 'alex@example.com');
      },
    );
  });
}

class FakeUser implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;

  const FakeUser({required this.uid, this.email, this.displayName});

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeUserCredential implements UserCredential {
  @override
  final User user;

  FakeUserCredential(this.user);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAuthService implements AuthService {
  final StreamController<User?> _controller =
      StreamController<User?>.broadcast();
  User? _currentUser;
  bool signedOutCalled = false;
  Map<String, String>? lastRegisteredData;

  FakeAuthService({User? initialUser}) : _currentUser = initialUser;

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  User? get currentUser => _currentUser;

  void emitUser(User? user) {
    _currentUser = user;
    _controller.add(user);
  }

  @override
  Future<void> signOut() async {
    signedOutCalled = true;
    emitUser(null);
  }

  @override
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String firstName,
    required String lastName,
  }) async {
    lastRegisteredData = {
      'email': email,
      'password': password,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
    };
    final user = FakeUser(
      uid: 'registered_uid_1',
      email: email,
      displayName: '$firstName $lastName',
    );
    emitUser(user);
    return FakeUserCredential(user);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeUserProfileService extends ChangeNotifier
    implements UserProfileService {
  UserProfile? _cached;
  UserProfile? _firestoreProfile;

  FakeUserProfileService({UserProfile? cached, UserProfile? firestoreProfile})
    : _cached = cached,
      _firestoreProfile = firestoreProfile;

  @override
  UserProfile? get currentProfile => _cached;

  @override
  void setCachedProfile(UserProfile? profile) {
    _cached = profile;
    notifyListeners();
  }

  @override
  void clearCache() {
    _cached = null;
    notifyListeners();
  }

  @override
  Future<UserProfile?> getUserProfile(String uid) async {
    if (_cached != null && _cached!.uid == uid) {
      return _cached;
    }
    return _firestoreProfile;
  }

  @override
  Future<void> createUserProfile(UserProfile profile) async {
    _cached = profile;
    _firestoreProfile = profile;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
