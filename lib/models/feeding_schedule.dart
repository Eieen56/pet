import 'package:cloud_firestore/cloud_firestore.dart';

class FeedingSchedule {
  const FeedingSchedule({
    required this.id,
    required this.time,
    required this.active,
    required this.createdAt,
  });

  final String id;
  final String time;
  final bool active;
  final DateTime createdAt;

  int get minutesSinceMidnight {
    final parts = time.split(':');
    return (int.parse(parts[0]) * 60) + int.parse(parts[1]);
  }

  factory FeedingSchedule.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    final timestamp = data['createdAt'];

    return FeedingSchedule(
      id: document.id,
      time: data['time'] as String? ?? '00:00',
      active: data['active'] as bool? ?? true,
      createdAt: timestamp is Timestamp
          ? timestamp.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static bool isValidTime(String value) {
    final match = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(value);
    if (match == null) {
      return false;
    }
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
  }
}
