class Validators {
  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Email is required';
    }

    final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!pattern.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  static String? password(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 8) {
      return 'Use at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Include an uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Include a lowercase letter';
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      return 'Include a number';
    }

    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  static String? fullName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) {
      return 'Full name is required';
    }
    if (name.length < 2) {
      return 'Enter your full name';
    }

    return null;
  }

  static PasswordStrength passwordStrength(String password) {
    if (password.isEmpty) {
      return PasswordStrength.empty;
    }
    if (password.length < 8) {
      return PasswordStrength.weak;
    }

    var score = 0;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'\d').hasMatch(password)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;

    if (score >= 4) return PasswordStrength.strong;
    if (score >= 3) return PasswordStrength.good;
    return PasswordStrength.weak;
  }
}

enum PasswordStrength {
  empty,
  weak,
  good,
  strong;

  String get label => switch (this) {
        empty => '',
        weak => 'Weak',
        good => 'Good',
        strong => 'Strong',
      };

  ColorHint get colorHint => switch (this) {
        empty => ColorHint.neutral,
        weak => ColorHint.error,
        good => ColorHint.warning,
        strong => ColorHint.success,
      };
}

enum ColorHint { neutral, error, warning, success }
