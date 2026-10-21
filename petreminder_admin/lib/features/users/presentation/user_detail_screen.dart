import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petreminder_admin/features/users/presentation/widgets/status_badge.dart';
import 'package:petreminder_admin/features/users/presentation/widgets/user_avatar.dart';
import 'package:petreminder_admin/models/admin_pet.dart';
import 'package:petreminder_admin/models/admin_user.dart';
import 'package:petreminder_admin/providers/admin_providers.dart';

class UserDetailScreen extends ConsumerWidget {
  const UserDetailScreen({
    required this.userId,
    this.usersRoute = '/users',
    super.key,
  });

  final String userId;
  final String usersRoute;

  Future<void> _changeStatus(
    BuildContext context,
    WidgetRef ref,
    AdminUser user,
  ) async {
    final disabling = user.isActive;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(disabling ? 'Deshabilitar cuenta' : 'Reactivar cuenta'),
        content: Text(
          disabling
              ? '¿Deseas deshabilitar la cuenta de este usuario?'
              : '¿Deseas reactivar la cuenta de este usuario?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(disabling ? 'Deshabilitar' : 'Reactivar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final success = await ref
        .read(accountControllerProvider.notifier)
        .setStatus(user, disabling ? 'disabled' : 'active');
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? disabling
                    ? 'Cuenta deshabilitada.'
                    : 'Cuenta reactivada.'
              : 'No fue posible actualizar la cuenta.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider);
    final pets = ref.watch(allPetsProvider);
    final schedules = ref.watch(allSchedulesProvider);
    final operation = ref.watch(accountControllerProvider);

    if (users.isLoading || pets.isLoading || schedules.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final user = users.value?.where((item) => item.uid == userId).firstOrNull;
    if (user == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('El usuario no existe.'),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.go(usersRoute),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Volver'),
            ),
          ],
        ),
      );
    }

    final userPets = (pets.value ?? [])
        .where((pet) => pet.userId == userId)
        .toList();
    final scheduleCounts = <String, int>{};
    for (final schedule in schedules.value ?? []) {
      if (schedule.userId == userId) {
        scheduleCounts[schedule.petId] =
            (scheduleCounts[schedule.petId] ?? 0) + 1;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () => context.go(usersRoute),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Usuarios'),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 24,
                    runSpacing: 20,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          UserAvatar(
                            name: user.name,
                            photoUrl: user.photoUrl,
                            radius: 32,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              Text(user.email),
                              const SizedBox(height: 8),
                              StatusBadge(active: user.isActive),
                            ],
                          ),
                        ],
                      ),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: user.isActive
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: operation.isLoading
                            ? null
                            : () => _changeStatus(context, ref, user),
                        icon: Icon(
                          user.isActive
                              ? Icons.block_rounded
                              : Icons.replay_rounded,
                        ),
                        label: Text(
                          user.isActive
                              ? 'Deshabilitar cuenta'
                              : 'Reactivar cuenta',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Mascotas (${userPets.length})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (userPets.isEmpty)
                const Card(
                  child: SizedBox(
                    height: 160,
                    child: Center(
                      child: Text(
                        'Este usuario no tiene mascotas registradas.',
                      ),
                    ),
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final columns = width >= 900
                        ? 3
                        : width >= 560
                        ? 2
                        : 1;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.55,
                      ),
                      itemCount: userPets.length,
                      itemBuilder: (context, index) {
                        final pet = userPets[index];
                        return _PetCard(
                          pet: pet,
                          schedules: scheduleCounts[pet.id] ?? 0,
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  const _PetCard({required this.pet, required this.schedules});

  final AdminPet pet;
  final int schedules;

  @override
  Widget build(BuildContext context) {
    final url = pet.photoUrl;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          SizedBox(
            width: 112,
            height: double.infinity,
            child: url != null && url.startsWith('http')
                ? Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const _PetPlaceholder(),
                  )
                : const _PetPlaceholder(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(pet.speciesLabel),
                  Text(pet.ageLabel),
                  if (pet.breed.isNotEmpty)
                    Text(
                      pet.breed,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 17),
                      const SizedBox(width: 6),
                      Text('$schedules horarios'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PetPlaceholder extends StatelessWidget {
  const _PetPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Icon(
        Icons.pets_rounded,
        size: 38,
        color: Theme.of(context).colorScheme.onSecondaryContainer,
      ),
    );
  }
}
