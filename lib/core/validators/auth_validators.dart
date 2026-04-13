// This file contains validation logic for authentication-related fields such as email and password.
class AuthValidators {
 AuthValidators._(); 

  /// Strict FCI email format: `digits@stud.fci-cu.edu.eg`.
  static final RegExp _fciEmailRegex =
      RegExp(r'^\d+@stud\.fci-cu\.edu\.eg$');

   /// Student ID must be numeric only.
  static final RegExp _studentIdRegex = RegExp(r'^\d+$');

   /// Password must include at least one decimal digit.
  static final RegExp _passwordHasNumberRegex = RegExp(r'\d');

   /// Validates required name field.
  ///
  /// Returns an error string if invalid, otherwise `null`.
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  /// Validates required numeric student ID field.
  ///
  /// Returns an error string if invalid, otherwise `null`.
  static String? validateStudentId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Student ID is required';
    }

    if (!_studentIdRegex.hasMatch(value.trim())) {
      return 'Student ID must contain digits only';
    }
    return null;
  }

  /// Validates FCI email structure.
  ///
  /// Expected shape: `studentID@stud.fci-cu.edu.eg`.
  /// Returns an error string if invalid, otherwise `null`.
  static String? validateFciEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'FCI email is required';
    }

    if (!_fciEmailRegex.hasMatch(value.trim())) {
      return 'Email must be like studentID@stud.fci-cu.edu.eg';
    }
    return null;
  }

   /// Validates password complexity rules.
  ///
  /// Rules:
  /// - not empty
  /// - at least 8 characters
  /// - contains at least one number
  ///
  /// Returns an error string if invalid, otherwise `null`.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!_passwordHasNumberRegex.hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    return null;
  }


   /// Validates confirm password field against the source [password].
  ///
  /// Rules:
  /// - not empty
  /// - at least 8 characters
  /// - exact match with [password]
  ///
  /// Returns an error string if invalid, otherwise `null`.
  static String? validateConfirmPassword({
    required String? confirmPassword,
    required String password,
  }) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Confirm password is required';
    }
    if (confirmPassword.length < 8) {
      return 'Confirm password must be at least 8 characters';
    }
    if (confirmPassword != password) {
      return 'Confirm password must match password';
    }
    return null;
  }


  /// Checks that the email username part equals the provided student ID.
  ///
  /// Example:
  /// - email: `20231234@stud.fci-cu.edu.eg`
  /// - studentId: `20231234`
  ///   => `true`
  ///
  /// Returns `false` for empty values.
  static bool isEmailMatchingStudentId({
    required String email,
    required String studentId,
  }) {
    final trimmedEmail = email.trim();
    final trimmedStudentId = studentId.trim();

    if (trimmedEmail.isEmpty || trimmedStudentId.isEmpty) {
      return false;
    }

    final emailPrefix = trimmedEmail.split('@').first;
    return emailPrefix == trimmedStudentId;
  }



}
