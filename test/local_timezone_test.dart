import 'package:flutter_test/flutter_test.dart';
import 'package:petreminder_user/core/time/local_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test('GMT y alias UTC no detienen el arranque', () {
    for (final name in ['GMT', 'UTC', 'Etc/UTC', 'gmt', ' GMT ']) {
      final location = resolveLocalTimezone(
        name,
        fallbackOffset: const Duration(hours: -6),
      );
      expect(
        tz.TZDateTime.from(DateTime.utc(2026), location).timeZoneOffset,
        Duration.zero,
      );
    }
  });

  test('zonas IANA conservan los cambios de horario', () {
    final location = resolveLocalTimezone(
      'America/New_York',
      fallbackOffset: Duration.zero,
    );
    expect(
      tz.TZDateTime.from(DateTime.utc(2026, 1), location).timeZoneOffset,
      const Duration(hours: -5),
    );
    expect(
      tz.TZDateTime.from(DateTime.utc(2026, 7), location).timeZoneOffset,
      const Duration(hours: -4),
    );
  });

  test('GMT con offset positivo y minutos conserva la hora local', () {
    final location = resolveLocalTimezone(
      'GMT+05:30',
      fallbackOffset: Duration.zero,
    );
    final date = tz.TZDateTime.from(DateTime.utc(2026), location);
    expect(date.hour, 5);
    expect(date.minute, 30);
  });

  test('GMT con offset negativo conserva el día y hora locales', () {
    final location = resolveLocalTimezone(
      'GMT-06:00',
      fallbackOffset: Duration.zero,
    );
    final date = tz.TZDateTime.from(DateTime.utc(2026), location);
    expect(date.timeZoneOffset, const Duration(hours: -6));
    expect(date.day, 31);
    expect(date.hour, 18);
  });

  test(
    'un identificador no reconocido usa el desfase real del dispositivo',
    () {
      final location = resolveLocalTimezone(
        'Unknown/Zone',
        fallbackOffset: const Duration(hours: -3, minutes: -30),
      );
      expect(location.name, 'UTC-03:30');
      expect(
        tz.TZDateTime.from(DateTime.utc(2026), location).timeZoneOffset,
        const Duration(hours: -3, minutes: -30),
      );
    },
  );

  test('nombre vacío o inválido no provoca excepciones al iniciar', () {
    for (final name in ['', 'GMT+99:00']) {
      final location = resolveLocalTimezone(
        name,
        fallbackOffset: Duration.zero,
      );
      expect(
        tz.TZDateTime.from(DateTime.utc(2026), location).timeZoneOffset,
        Duration.zero,
      );
    }
  });
}
