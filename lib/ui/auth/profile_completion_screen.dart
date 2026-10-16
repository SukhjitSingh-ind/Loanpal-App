import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loanpal/core/validators/form_validators.dart';
import 'package:loanpal/models/user_profile.dart';
import 'package:loanpal/services/auth_service.dart';
import 'package:loanpal/services/user_profile_service.dart';
import 'package:loanpal/ui/theme.dart';

/// Screen displayed when an authenticated Firebase user exists, but their
/// Firestore user profile is missing or incomplete.
///
/// Enables seamless, non-destructive recovery without requiring re-authentication.
class ProfileCompletionScreen extends StatefulWidget {
  final User user;
  final VoidCallback onProfileCompleted;
  final VoidCallback? onSignOut;
  final UserProfileService? profileService;

  const ProfileCompletionScreen({
    super.key,
    required this.user,
    required this.onProfileCompleted,
    this.onSignOut,
    this.profileService,
  });

  @override
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  late final _profileService = widget.profileService ?? UserProfileService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate names from displayName if available
    final parts = (widget.user.displayName ?? '').trim().split(' ');
    if (parts.isNotEmpty && parts.first.isNotEmpty) {
      _firstNameController.text = parts.first;
      if (parts.length > 1) {
        _lastNameController.text = parts.sublist(1).join(' ');
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveProfile() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final profile = UserProfile(
        uid: widget.user.uid,
        username: _usernameController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: widget.user.email ?? '',
      );

      await _profileService.createUserProfile(profile);
      widget.onProfileCompleted();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: LoanPalTheme.burdenHeavy,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: LoanPalTheme.background,
      appBar: AppBar(
        title: const Text('Complete Profile'),
        backgroundColor: Colors.transparent,
        foregroundColor: LoanPalTheme.primaryNavy,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout),
            onPressed: widget.onSignOut ?? () => AuthService().signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.person_pin_rounded,
                          size: 48,
                          color: LoanPalTheme.primaryNavy,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Almost There!',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: LoanPalTheme.primaryNavy,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please complete your personal profile to activate your LoanPal account.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),

                        // Username Field
                        TextFormField(
                          controller: _usernameController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.alternate_email_rounded),
                            helperText: '3-20 characters (letters, numbers, _)',
                          ),
                          validator: FormValidators.validateUsername,
                        ),
                        const SizedBox(height: 16),

                        // First Name
                        TextFormField(
                          controller: _firstNameController,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'First Name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: FormValidators.validateFirstName,
                        ),
                        const SizedBox(height: 16),

                        // Last Name
                        TextFormField(
                          controller: _lastNameController,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleSaveProfile(),
                          decoration: const InputDecoration(
                            labelText: 'Last Name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: FormValidators.validateLastName,
                        ),
                        const SizedBox(height: 28),

                        // Submit Button
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSaveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: LoanPalTheme.primaryNavy,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Save and Continue',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
