import 'package:flutter_test/flutter_test.dart';
import 'package:petreminder_user/core/validators/input_validators.dart';
import 'package:petreminder_user/models/feeding_schedule.dart';
import 'package:petreminder_user/services/notification_service.dart';
import 'package:petreminder_user/models/feeding_record.dart';

void main() {
  group('InputValidators', () {
    test('rejects malformed email addresses', () {
      expect(InputValidators.email('correo-invalido'), isNotNull);
      expect(InputValidators.email('persona@example.com'), isNull);
    });

    test('accepts default admin username on login', () {
      expect(InputValidators.emailOrAdminUsername('eileno'), isNull);
      expect(
        InputValidators.emailOrAdminUsername('persona@example.com'),
        isNull,
      );
      expect(
        InputValidators.emailOrAdminUsername('correo-invalido'),
        isNotNull,
      );
    });

    test('requires passwords with at least six characters', () {
      expect(InputValidators.password('12345'), isNotNull);
      expect(InputValidators.password('123456'), isNull);
    });

    test('requires a meaningful name', () {
      expect(InputValidators.requiredName(' '), isNotNull);
      expect(InputValidators.requiredName('Ana'), isNull);
    });

    test('validates pet names', () {
      expect(InputValidators.petName(''), isNotNull);
      expect(InputValidators.petName('M'), isNotNull);
      expect(InputValidators.petName('Max'), isNull);
    });

    test('validates pet ages', () {
      expect(InputValidators.petAge(''), isNotNull);
      expect(InputValidators.petAge('-1'), isNotNull);
      expect(InputValidators.petAge('251'), isNotNull);
      expect(InputValidators.petAge('4'), isNull);
    });

    test('validates 24-hour feeding times', () {
      expect(FeedingSchedule.isValidTime('00:00'), isTrue);
      expect(FeedingSchedule.isValidTime('23:59'), isTrue);
      expect(FeedingSchedule.isValidTime('24:00'), isFalse);
      expect(FeedingSchedule.isValidTime('8:00'), isFalse);
    });

    test('creates stable daily feeding record ids', () {
      final date = DateTime(2026, 9, 22, 23, 45);

      expect(FeedingRecord.dateKeyFor(date), '2026-09-22');
      expect(
        FeedingRecord.documentId(
          petId: 'pet1',
          scheduleId: 'schedule1',
          date: date,
        ),
        'pet1_schedule1_20260922',
      );
    });

    test('creates stable and distinct notification ids', () {
      final before = NotificationService.notificationId(
        'pet1',
        'schedule1',
        'before',
      );
      final meal = NotificationService.notificationId(
        'pet1',
        'schedule1',
        'meal',
      );

      expect(
        before,
        NotificationService.notificationId('pet1', 'schedule1', 'before'),
      );
      expect(before, isNot(meal));
      expect(before, greaterThanOrEqualTo(0));
    });
  });
}
