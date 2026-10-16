import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loanpal/firebase_options.dart';
import 'package:loanpal/ui/auth/auth_gate.dart';
import 'package:loanpal/ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Object? initializationError;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, stackTrace) {
    debugPrint('Firebase initialization failed: $e\n$stackTrace');
    initializationError = e;
  }

  runApp(
    LoanPalApp(
      initializationError: initializationError,
      onRetryInitialization: () async {
        try {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
          runApp(const LoanPalApp());
        } catch (e, stackTrace) {
          debugPrint('Firebase retry initialization failed: $e\n$stackTrace');
        }
      },
    ),
  );
}

/// Root widget of the LoanPal application.
///
/// If [initializationError] is non-null, displays an explicit error state with
/// retry capability instead of mounting widgets that depend on active Firebase services.
class LoanPalApp extends StatelessWidget {
  final Object? initializationError;
  final Future<void> Function()? onRetryInitialization;

  const LoanPalApp({
    super.key,
    this.initializationError,
    this.onRetryInitialization,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LoanPal',
      debugShowCheckedModeBanner: false,
      theme: LoanPalTheme.lightTheme,
      home: initializationError != null
          ? FirebaseInitializationErrorScreen(
              error: initializationError!,
              onRetry: onRetryInitialization,
            )
          : const AuthGate(),
    );
  }
}

/// Dedicated error screen displayed when Firebase service initialization fails.
class FirebaseInitializationErrorScreen extends StatefulWidget {
  final Object error;
  final Future<void> Function()? onRetry;

  const FirebaseInitializationErrorScreen({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  State<FirebaseInitializationErrorScreen> createState() =>
      _FirebaseInitializationErrorScreenState();
}

class _FirebaseInitializationErrorScreenState
    extends State<FirebaseInitializationErrorScreen> {
  bool _isRetrying = false;

  Future<void> _handleRetry() async {
    if (widget.onRetry == null || _isRetrying) return;
    setState(() => _isRetrying = true);
    try {
      await widget.onRetry!();
    } finally {
      if (mounted) {
        setState(() => _isRetrying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoanPalTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: LoanPalTheme.burdenHeavy.withValues(
                            alpha: 0.1,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cloud_off_rounded,
                          size: 48,
                          color: LoanPalTheme.burdenHeavy,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Service Initialization Failed',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: LoanPalTheme.textMain,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'LoanPal could not connect to required cloud services. Please check your internet connection and try again.',
                        style: TextStyle(
                          fontSize: 14,
                          color: LoanPalTheme.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (kDebugMode) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            'Debug info: ${widget.error}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (widget.onRetry != null)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isRetrying ? null : _handleRetry,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: LoanPalTheme.primaryNavy,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isRetrying
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Retry Connection',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
