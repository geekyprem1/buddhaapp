/// Shared field validation used identically by the mobile app's onboarding
/// forms and the admin panel's content/user forms (PRD FR-4.x, AR-3.2).
///
/// Each validator returns `null` when the value is valid, or a localisation
/// key string when invalid. The caller (widget layer) maps the key to a
/// localised message via `gen-l10n` — this package has no Flutter/l10n
/// dependency, so it stays reusable in the admin web build too.
abstract class FieldValidators {
  FieldValidators._();

  static final _namePattern = RegExp(r'^[a-zA-Z\u0900-\u097F\s.]{2,40}$');
  static final _phonePattern = RegExp(r'^[6-9]\d{9}$');
  static final _emailPattern = RegExp(
    r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$',
  );

  /// Full name: 2-40 chars, Latin letters, Devanagari, spaces and dots.
  static String? name(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'error_name_required';
    if (!_namePattern.hasMatch(v)) return 'error_name_invalid';
    return null;
  }

  /// Indian mobile number: exactly 10 digits, starting 6-9 (no country code
  /// — the `+91` prefix is a fixed UI element, not part of the stored value).
  static String? phone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'error_phone_required';
    if (!_phonePattern.hasMatch(v)) return 'error_phone_invalid';
    return null;
  }

  /// Email is optional (FR-4.1) — only validated when non-empty.
  static String? emailOptional(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    if (!_emailPattern.hasMatch(v)) return 'error_email_invalid';
    return null;
  }

  /// Admin login requires an email (AR-1.1).
  static String? emailRequired(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'error_email_required';
    if (!_emailPattern.hasMatch(v)) return 'error_email_invalid';
    return null;
  }

  /// Login-time password check. Length rules live on the Auth project;
  /// here we only reject a blank field so existing accounts still work.
  static String? passwordRequired(String? value) {
    if (value == null || value.isEmpty) return 'error_password_required';
    return null;
  }

  /// At least one non-empty translation is required for admin-authored
  /// localised titles (PRD AR-3.2). Individual languages may be blank.
  static String? localisedTitleRequired({
    required String en,
    required String hi,
    required String mr,
  }) {
    if (en.trim().isEmpty && hi.trim().isEmpty && mr.trim().isEmpty) {
      return 'error_title_required';
    }
    return null;
  }

  /// At least one teacher must be selected (FR-5.5).
  static String? teacherSelectionRequired(List<String> selected) {
    if (selected.isEmpty) return 'error_teacher_required';
    return null;
  }

  /// Content-item licence provenance is mandatory in admin (PRD §8 launch
  /// risk: copyright). Kept intentionally strict — this is not optional.
  static String? licenceRequired(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'error_licence_required';
    return null;
  }

  static const List<String> allowedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];
  static const List<String> allowedAudioExtensions = ['mp3', 'm4a', 'aac'];
  static const List<String> allowedVideoExtensions = ['mp4']; // Phase 2

  static bool hasAllowedExtension(String fileName, List<String> allowed) {
    final lower = fileName.toLowerCase();
    return allowed.any((ext) => lower.endsWith('.$ext'));
  }

  /// Max upload sizes, in bytes, enforced client-side before the resumable
  /// upload starts (Architecture §9.6).
  static const int maxImageBytes = 8 * 1024 * 1024; // 8 MB
  static const int maxAudioBytes = 20 * 1024 * 1024; // 20 MB
  static const int maxVideoBytes = 60 * 1024 * 1024; // 60 MB, Phase 2
}
