import 'package:loanpal/core/constants/validation_constants.dart';

/// Reusable form field validators for registration and authentication forms.
class FormValidators {
  FormValidators._();

  /// Validates a username field.
  ///
  /// Criteria:
  /// - Cannot be null, empty, or whitespace-only.
  /// - Length must be between 3 and 20 characters.
  /// - Only alphanumeric characters and underscores are permitted.
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < ValidationConstants.minUsernameLength) {
      return 'Username must be at least ${ValidationConstants.minUsernameLength} characters';
    }
    if (trimmed.length > ValidationConstants.maxUsernameLength) {
      return 'Username cannot exceed ${ValidationConstants.maxUsernameLength} characters';
    }
    if (!ValidationConstants.usernameRegex.hasMatch(trimmed)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  /// Validates a first name field.
  ///
  /// Criteria:
  /// - Cannot be null, empty, or whitespace-only.
  /// - Must be at least 2 characters.
  /// - Supports international Unicode letters, spaces, hyphens, and apostrophes.
  static String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'First name is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < ValidationConstants.minNameLength) {
      return 'First name must be at least ${ValidationConstants.minNameLength} characters';
    }
    if (trimmed.length > ValidationConstants.maxNameLength) {
      return 'First name cannot exceed ${ValidationConstants.maxNameLength} characters';
    }
    if (!ValidationConstants.nameRegex.hasMatch(trimmed)) {
      return 'First name contains invalid characters';
    }
    return null;
  }

  /// Validates a last name field.
  ///
  /// Criteria:
  /// - Cannot be null, empty, or whitespace-only.
  /// - Must be at least 2 characters.
  /// - Supports international Unicode letters, spaces, hyphens, and apostrophes.
  static String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Last name is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < ValidationConstants.minNameLength) {
      return 'Last name must be at least ${ValidationConstants.minNameLength} characters';
    }
    if (trimmed.length > ValidationConstants.maxNameLength) {
      return 'Last name cannot exceed ${ValidationConstants.maxNameLength} characters';
    }
    if (!ValidationConstants.nameRegex.hasMatch(trimmed)) {
      return 'Last name contains invalid characters';
    }
    return null;
  }

  /// Validates an email address.
  ///
  /// Criteria:
  /// - Cannot be null, empty, or whitespace-only.
  /// - Must follow standard email format (user@domain.tld).
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final trimmed = value.trim();
    if (!ValidationConstants.emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates a password.
  ///
  /// Criteria:
  /// - Cannot be null or empty.
  /// - Must be at least 8 characters long.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < ValidationConstants.minPasswordLength) {
      return 'Password must be at least ${ValidationConstants.minPasswordLength} characters long';
    }
    return null;
  }

  /// Validates a confirm-password field against the original password.
  ///
  /// Criteria:
  /// - Cannot be null or empty.
  /// - Must match the password value exactly.
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}
