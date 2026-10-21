abstract final class AdminCredentials {
  static const username = 'eileno';
  static const email = 'eileno@petreminder.local';

  static const _aliases = {username: email};

  static String normalizeEmail(String value) {
    final trimmed = value.trim();
    return _aliases[trimmed.toLowerCase()] ?? trimmed;
  }

  static bool isUsername(String value) =>
      _aliases.containsKey(value.trim().toLowerCase());
}
