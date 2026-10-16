import 'package:flutter_test/flutter_test.dart';
import 'package:loanpal/core/validators/form_validators.dart';

void main() {
  group('Username Validation', () {
    test('rejects null, empty, and whitespace-only', () {
      expect(FormValidators.validateUsername(null), 'Username is required');
      expect(FormValidators.validateUsername(''), 'Username is required');
      expect(FormValidators.validateUsername('   '), 'Username is required');
    });

    test('rejects usernames that are too short or too long', () {
      expect(
        FormValidators.validateUsername('ab'),
        'Username must be at least 3 characters',
      );
      expect(
        FormValidators.validateUsername('a' * 21),
        'Username cannot exceed 20 characters',
      );
    });

    test('rejects usernames with invalid characters', () {
      expect(
        FormValidators.validateUsername('john.doe'),
        'Username can only contain letters, numbers, and underscores',
      );
      expect(
        FormValidators.validateUsername('user@name'),
        'Username can only contain letters, numbers, and underscores',
      );
      expect(
        FormValidators.validateUsername('user name'),
        'Username can only contain letters, numbers, and underscores',
      );
    });

    test('accepts valid alphanumeric and underscored usernames', () {
      expect(FormValidators.validateUsername('john_doe'), isNull);
      expect(FormValidators.validateUsername('user123'), isNull);
      expect(FormValidators.validateUsername('LoanPal_Dev_99'), isNull);
    });
  });

  group('First and Last Name Validation', () {
    test('rejects null, empty, and whitespace-only', () {
      expect(FormValidators.validateFirstName(null), 'First name is required');
      expect(FormValidators.validateFirstName(''), 'First name is required');
      expect(FormValidators.validateFirstName('   '), 'First name is required');
      expect(FormValidators.validateLastName(null), 'Last name is required');
      expect(FormValidators.validateLastName(''), 'Last name is required');
      expect(FormValidators.validateLastName('   '), 'Last name is required');
    });

    test('rejects names shorter than 2 characters', () {
      expect(
        FormValidators.validateFirstName('A'),
        'First name must be at least 2 characters',
      );
      expect(
        FormValidators.validateLastName('B'),
        'Last name must be at least 2 characters',
      );
    });

    test('accepts international names, spaces, hyphens, and apostrophes', () {
      expect(FormValidators.validateFirstName('John'), isNull);
      expect(FormValidators.validateLastName('Doe'), isNull);
      expect(FormValidators.validateFirstName('Mary-Jane'), isNull);
      expect(FormValidators.validateLastName("O'Connor"), isNull);
      expect(FormValidators.validateFirstName('René'), isNull);
      expect(FormValidators.validateLastName('García'), isNull);
      expect(FormValidators.validateFirstName('Jean Luc'), isNull);
    });

    test('rejects names with numbers or illegal symbols', () {
      expect(
        FormValidators.validateFirstName('John123'),
        'First name contains invalid characters',
      );
      expect(
        FormValidators.validateLastName('Smith#'),
        'Last name contains invalid characters',
      );
    });
  });

  group('Email Validation', () {
    test('rejects null, empty, and whitespace-only', () {
      expect(FormValidators.validateEmail(null), 'Email address is required');
      expect(FormValidators.validateEmail(''), 'Email address is required');
      expect(FormValidators.validateEmail('   '), 'Email address is required');
    });

    test('rejects malformed email addresses', () {
      expect(
        FormValidators.validateEmail('plainaddress'),
        'Please enter a valid email address',
      );
      expect(
        FormValidators.validateEmail('@missinguser.com'),
        'Please enter a valid email address',
      );
      expect(
        FormValidators.validateEmail('user@.com'),
        'Please enter a valid email address',
      );
      expect(
        FormValidators.validateEmail('user@domain'),
        'Please enter a valid email address',
      );
    });

    test('accepts valid email addresses', () {
      expect(FormValidators.validateEmail('user@example.com'), isNull);
      expect(FormValidators.validateEmail('first.last@loanpal.org'), isNull);
      expect(FormValidators.validateEmail('dev+test@domain.co.in'), isNull);
    });
  });

  group('Password Validation', () {
    test('rejects null and empty passwords', () {
      expect(FormValidators.validatePassword(null), 'Password is required');
      expect(FormValidators.validatePassword(''), 'Password is required');
    });

    test('rejects passwords below 8 characters', () {
      expect(
        FormValidators.validatePassword('1234567'),
        'Password must be at least 8 characters long',
      );
    });

    test('accepts passwords with 8 or more characters', () {
      expect(FormValidators.validatePassword('password123'), isNull);
      expect(FormValidators.validatePassword('StrongP@ssw0rd!'), isNull);
    });
  });

  group('Confirm Password Validation', () {
    test('rejects null and empty confirmation', () {
      expect(
        FormValidators.validateConfirmPassword(null, 'secret123'),
        'Please confirm your password',
      );
      expect(
        FormValidators.validateConfirmPassword('', 'secret123'),
        'Please confirm your password',
      );
    });

    test('rejects mismatching passwords', () {
      expect(
        FormValidators.validateConfirmPassword('secret124', 'secret123'),
        'Passwords do not match',
      );
    });

    test('accepts matching passwords', () {
      expect(
        FormValidators.validateConfirmPassword('secret123', 'secret123'),
        isNull,
      );
    });
  });
}
