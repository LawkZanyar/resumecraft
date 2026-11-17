/// Form validators. Each returns an error message or null when valid.
abstract final class Validators {
  static final RegExp _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
  static final RegExp _phone = RegExp(r'^\+?[0-9 ()\-]{7,20}$');
  static final RegExp _url = RegExp(r'^(https?:\/\/)?[\w\-]+(\.[\w\-]+)+(\/\S*)?$');

  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required';
    if (!_email.hasMatch(v)) return 'Enter a valid email address';
    return null;
  }

  /// At least 8 characters with a letter and a number.
  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Use at least 8 characters';
    if (!RegExp('[A-Za-z]').hasMatch(v) || !RegExp('[0-9]').hasMatch(v)) {
      return 'Use letters and numbers';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? name(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Name is required';
    if (v.length < 2) return 'Name is too short';
    if (v.length > 80) return 'Name is too long';
    return null;
  }

  /// Optional phone number: empty is valid.
  static String? optionalPhone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    if (!_phone.hasMatch(v)) return 'Enter a valid phone number';
    return null;
  }

  /// Optional email: empty is valid.
  static String? optionalEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    return email(v);
  }

  /// Optional web link: empty is valid.
  static String? optionalUrl(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    if (!_url.hasMatch(v)) return 'Enter a valid link';
    return null;
  }

  static String? maxLength(String? value, int max) {
    if ((value ?? '').length > max) return 'Keep this under $max characters';
    return null;
  }
}
