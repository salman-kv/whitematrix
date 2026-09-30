/// Input validation helpers for the login form.
class Validators {
  Validators._();

  static final _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  static String? email(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Please enter your email address';
    if (!_email.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  static String? phone(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Please enter your phone number';
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  static String? password(String? v) {
    final value = v ?? '';
    if (value.isEmpty) return 'Please enter your password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }
}
