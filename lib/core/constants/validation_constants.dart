/// Centralized validation constants and regular expression patterns
/// for the LoanPal application.
class ValidationConstants {
  ValidationConstants._();

  /// Username policy: 3 to 20 characters, alphanumeric and underscore only.
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;
  static final RegExp usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,20}$');

  /// Name policy: Allows international letters, apostrophes, hyphens, and spaces.
  /// Minimum 2 characters, maximum 50 characters.
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static final RegExp nameRegex = RegExp(
    r"^[\p{L}][\p{L} '\-]{0,48}[\p{L}]$",
    unicode: true,
  );

  /// RFC-compliant general email pattern.
  static final RegExp emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$",
  );

  /// Minimum password length required by application policy.
  static const int minPasswordLength = 8;
}
