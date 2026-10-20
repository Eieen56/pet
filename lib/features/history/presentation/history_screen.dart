import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petreminder_user/models/feeding_record.dart';
import 'package:petreminder_user/providers/feeding_history_providers.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(feedingHistoryProvider);
    final ensureState = ref.watch(ensureTodayForAllPetsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: history.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => _HistoryError(
                onRetry: () {
                  ref.invalidate(ensureTodayForAllPetsProvider);
                  ref.invalidate(feedingHistoryProvider);
                },
              ),
              data: (records) {
                if (ensureState.isLoading && records.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (records.isEmpty) {
                  return const _EmptyHistory();
                }
                final groups = <String, List<FeedingRecord>>{};
                for (final record in records) {
                  groups.putIfAbsent(record.dateKey, () => []).add(record);
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final entry = groups.entries.elementAt(index);
                    return _HistoryGroup(
                      dateKey: entry.key,
                      records: entry.value,
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryGroup extends StatelessWidget {
  const _HistoryGroup({required this.dateKey, required this.records});

  final String dateKey;
  final List<FeedingRecord> records;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              _dateLabel(dateKey),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          for (final record in records)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: Icon(
                    record.isFed
                        ? Icons.check_circle_outline_rounded
                        : Icons.schedule_rounded,
                    color: record.isFed
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  title: Text(record.petName),
                  subtitle: Text(
                    record.isFed
                        ? '${record.scheduledTime} · Alimentada${_fedTime(record)}'
                        : '${record.scheduledTime} · Pendiente',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _fedTime(FeedingRecord record) {
    final date = record.fedAt?.toLocal();
    if (date == null) {
      return '';
    }
    final time =
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
    return ' a las $time';
  }

  String _dateLabel(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) {
      return value;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final difference = today.difference(date).inDays;
    if (difference == 0) {
      return 'Hoy';
    }
    if (difference == 1) {
      return 'Ayer';
    }
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded, size: 56),
            SizedBox(height: 12),
            Text('Todavía no hay alimentaciones programadas.'),
          ],
        ),
      ),
    );
  }
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Reintentar'),
      ),
    );
  }
}
