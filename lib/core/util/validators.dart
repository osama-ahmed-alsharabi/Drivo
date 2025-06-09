class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'الايميل مطلوب';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'رقم الهاتف مطلوب';
    final phoneRegex = RegExp(r'^(77|78|71|73)\d{7}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'رقم الهاتف يجب ان يبداء 77, 78, 71 او 73 ويجب ان يكون 9 ارقام';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'كلمة السر مطلوبة';
    if (value.length < 6) return 'كلمة السر لاتقل عن 6 احرف';
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'الاسم مطلوب';
    if (value.length < 3) return 'الاسم لايقل عن 3 احرف';
    return null;
  }

  static String? validateCity(String? value) {
    if (value == null || value.isEmpty) return 'المدينة مطلوبة';
    return null;
  }

  static String? validateDirectorate(String? value) {
    if (value == null || value.isEmpty) return 'المديرية مطلوبة';
    return null;
  }

  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) return 'رمز التحقق مطلوب';
    if (value.length != 6) return 'رمز التحقق لايقل عن 6 ارقام';
    return null;
  }
}
