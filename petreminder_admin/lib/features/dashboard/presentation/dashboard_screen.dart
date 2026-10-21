import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petreminder_admin/models/admin_pet.dart';
import 'package:petreminder_admin/providers/admin_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const _speciesOrder = [
    'Perro',
    'Gato',
    'Conejo',
    'Ave',
    'Hámster',
    'Tortuga',
    'Pez',
    'Otro',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider);
    final pets = ref.watch(allPetsProvider);
    final schedules = ref.watch(allSchedulesProvider);
    final loading = users.isLoading || pets.isLoading || schedules.isLoading;
    final error = users.error ?? pets.error ?? schedules.error;

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return _DashboardError(
        onRetry: () {
          ref.invalidate(usersProvider);
          ref.invalidate(allPetsProvider);
          ref.invalidate(allSchedulesProvider);
        },
      );
    }

    final userList = users.value ?? [];
    final petList = pets.value ?? [];
    final scheduleList = schedules.value ?? [];
    final activeScheduleCount = scheduleList
        .where((schedule) => schedule.active)
        .length;
    final scheduledAlarmCount = activeScheduleCount * 2;
    final species = <String, int>{for (final name in _speciesOrder) name: 0};
    for (final pet in petList) {
      final key = species.containsKey(pet.species) ? pet.species : 'Otro';
      species[key] = (species[key] ?? 0) + 1;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Resumen general de PetReminder',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 960
                      ? 4
                      : constraints.maxWidth >= 560
                      ? 2
                      : 1;
                  return GridView.count(
                    crossAxisCount: columns,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: columns == 1 ? 3.2 : 2.0,
                    children: [
                      _MetricCard(
                        label: 'Usuarios activos',
                        value: userList.where((user) => user.isActive).length,
                        icon: Icons.verified_user_outlined,
                        color: const Color(0xFF247A57),
                      ),
                      _MetricCard(
                        label: 'Usuarios registrados',
                        value: userList.length,
                        icon: Icons.people_outline_rounded,
                        color: const Color(0xFF3567A8),
                      ),
                      _MetricCard(
                        label: 'Mascotas registradas',
                        value: petList.length,
                        icon: Icons.pets_outlined,
                        color: const Color(0xFFA86424),
                      ),
                      _MetricCard(
                        label: 'Alarmas programadas',
                        value: scheduledAlarmCount,
                        icon: Icons.alarm_outlined,
                        color: const Color(0xFF80559C),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              _SpeciesPanel(species: species, pets: petList),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$value',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(label, maxLines: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeciesPanel extends StatelessWidget {
  const _SpeciesPanel({required this.species, required this.pets});

  final Map<String, int> species;
  final List<AdminPet> pets;

  static const colors = [
    Color(0xFF247A57),
    Color(0xFF3567A8),
    Color(0xFFA86424),
    Color(0xFF80559C),
    Color(0xFFC34F5C),
    Color(0xFF41838A),
    Color(0xFF9B7B2F),
    Color(0xFF69736E),
  ];

  @override
  Widget build(BuildContext context) {
    final entries = species.entries.where((entry) => entry.value > 0).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mascotas por especie',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),
            if (pets.isEmpty)
              const SizedBox(
                height: 180,
                child: Center(child: Text('Aún no hay mascotas registradas.')),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final chart = SizedBox(
                    height: 260,
                    child: PieChart(
                      PieChartData(
                        centerSpaceRadius: 54,
                        sectionsSpace: 3,
                        sections: [
                          for (var index = 0; index < entries.length; index++)
                            PieChartSectionData(
                              value: entries[index].value.toDouble(),
                              title: '${entries[index].value}',
                              color: colors[index % colors.length],
                              radius: 70,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                  final legend = Wrap(
                    spacing: 24,
                    runSpacing: 16,
                    children: [
                      for (var index = 0; index < species.length; index++)
                        SizedBox(
                          width: 150,
                          child: _LegendItem(
                            color: colors[index % colors.length],
                            name: species.keys.elementAt(index),
                            value: species.values.elementAt(index),
                          ),
                        ),
                    ],
                  );
                  if (constraints.maxWidth < 700) {
                    return Column(
                      children: [chart, const SizedBox(height: 20), legend],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: chart),
                      const SizedBox(width: 32),
                      Expanded(child: legend),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.name,
    required this.value,
  });

  final Color color;
  final String name;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(name)),
        Text('$value', style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 48),
          const SizedBox(height: 12),
          const Text('No fue posible cargar el dashboard.'),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
