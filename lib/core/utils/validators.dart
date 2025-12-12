class Validators {
  Validators._();

  static String? notEmpty(String? value, {String message = 'Required'}) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email required';
    final regex = RegExp(r'^.+@.+\..+$');
    if (!regex.hasMatch(value)) return 'Invalid email';
    return null;
  }

  static String? minLength(String? value, int length, {String? label}) {
    if (value == null || value.length < length) {
      return '${label ?? 'Field'} must be at least $length characters';
    }
    return null;
  }
}
