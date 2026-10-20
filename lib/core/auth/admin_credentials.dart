abstract final class AdminCredentials {
  static const username = 'eileno';
  static const email = 'eileno@petreminder.local';

  static String normalizeEmail(String value) {
    final trimmed = value.trim();
    return trimmed.toLowerCase() == username ? email : trimmed;
  }

  static bool isUsername(String value) =>
      value.trim().toLowerCase() == username;
}
