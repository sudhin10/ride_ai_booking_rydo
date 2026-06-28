class Validators {
  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final re = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    return re.hasMatch(v.trim()) ? null : 'Enter a valid email';
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    return v.length >= 6 ? null : 'Password must be 6+ characters';
  }

  static String? required(String? v, [String field = 'This field']) {
    return (v == null || v.trim().isEmpty) ? '$field is required' : null;
  }

  static String? cardNumber(String? v) {
    final clean = (v ?? '').replaceAll(' ', '');
    if (clean.length < 12) return 'Enter a valid card number';
    return null;
  }
}
