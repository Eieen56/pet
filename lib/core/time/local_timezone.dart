import 'package:timezone/timezone.dart' as tz;

/// Android también devuelve alias como GMT y offsets como GMT-06:00.
/// Las zonas IANA conservan sus reglas; los identificadores desconocidos usan
/// el desfase actual del dispositivo para no impedir el arranque.
tz.Location resolveLocalTimezone(
  String identifier, {
  required Duration fallbackOffset,
}) {
  final name = identifier.trim();
  const utcAliases = {
    'GMT',
    'UTC',
    'UCT',
    'ETC/UTC',
    'ETC/GMT',
    'ETC/UCT',
    'ZULU',
    'UNIVERSAL',
  };
  if (utcAliases.contains(name.toUpperCase())) return tz.UTC;
  try {
    return tz.getLocation(name);
  } on tz.LocationNotFoundException {
    final match = RegExp(
      r'^(?:GMT|UTC)([+-])(\d{1,2})(?::?([0-5]\d))?$',
      caseSensitive: false,
    ).firstMatch(name);
    var offset = fallbackOffset;
    if (match != null) {
      final minutes = int.parse(match[2]!) * 60 + int.parse(match[3] ?? '0');
      if (minutes <= 18 * 60) {
        offset = Duration(minutes: match[1] == '-' ? -minutes : minutes);
      }
    }
    if (offset == Duration.zero) return tz.UTC;
    // El plugin Android también necesita un ZoneId válido para programar alarmas.
    final seconds = offset.inSeconds.abs();
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final remainder = seconds % 60;
    final label =
        'UTC${offset.isNegative ? '-' : '+'}$hours:$minutes'
        '${remainder == 0 ? '' : ':${remainder.toString().padLeft(2, '0')}'}';
    return tz.Location(label, const [], const [], [
      tz.TimeZone(offset, isDst: false, abbreviation: label),
    ]);
  }
}
