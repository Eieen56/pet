import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petreminder_user/core/errors/auth_failure.dart';
import 'package:petreminder_user/core/validators/input_validators.dart';
import 'package:petreminder_user/models/feeding_record.dart';
import 'package:petreminder_user/models/pet.dart';
import 'package:petreminder_user/providers/auth_providers.dart';
import 'package:petreminder_user/providers/feeding_history_providers.dart';
import 'package:petreminder_user/providers/pet_providers.dart';
import 'package:petreminder_user/providers/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(appUserProvider);
    final photoPath = ref.watch(profilePhotoPathProvider).value;
    final history = ref.watch(feedingHistoryProvider).value ?? const [];
    final pets = ref.watch(petsProvider).value ?? const <Pet>[];
    final profileOperation = ref.watch(profileControllerProvider);
    final authOperation = ref.watch(authControllerProvider);
    final isBusy = profileOperation.isLoading || authOperation.isLoading;
    final weeklyRecords = _weeklyRecords(history);

    ref.listen(profileControllerProvider, (previous, next) {
      if (!next.hasError || previous?.error == next.error) {
        return;
      }
      final error = next.error;
      final message = error is AuthFailure
          ? error.message
          : 'No se pudo actualizar el perfil.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: profile.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  const Center(child: Text('No se pudo cargar el perfil.')),
              data: (user) => ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                children: [
                  Center(
                    child: _ProfilePhoto(
                      localPath: photoPath,
                      networkUrl: user?.photoUrl,
                      disabled: isBusy,
                      onEdit: () => _selectPhoto(context, ref, photoPath),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name.isNotEmpty == true ? user!.name : 'Usuario',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: isBusy
                          ? null
                          : () => _editName(context, ref, user?.name ?? ''),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Editar nombre'),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Esta semana',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _StatsSummary(records: weeklyRecords),
                  const SizedBox(height: 28),
                  Text(
                    'Por mascota',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (pets.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Todavía no hay mascotas registradas.'),
                    )
                  else
                    for (final pet in pets)
                      _PetStatsTile(
                        pet: pet,
                        records: weeklyRecords
                            .where((record) => record.petId == pet.id)
                            .toList(),
                      ),
                  const SizedBox(height: 28),
                  OutlinedButton.icon(
                    onPressed: isBusy
                        ? null
                        : () => ref
                              .read(authControllerProvider.notifier)
                              .signOut(),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Cerrar sesión'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<FeedingRecord> _weeklyRecords(List<FeedingRecord> records) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return records.where((record) {
      final date = DateTime.tryParse(record.dateKey);
      if (date == null) {
        return false;
      }
      final difference = today.difference(date).inDays;
      return difference >= 0 && difference < 7;
    }).toList();
  }

  Future<void> _editName(
    BuildContext context,
    WidgetRef ref,
    String currentName,
  ) async {
    final controller = TextEditingController(text: currentName);
    final formKey = GlobalKey<FormState>();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar nombre'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              border: OutlineInputBorder(),
            ),
            validator: InputValidators.requiredName,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(context).pop(controller.text);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name != null) {
      await ref.read(profileControllerProvider.notifier).updateName(name);
    }
  }

  Future<void> _selectPhoto(
    BuildContext context,
    WidgetRef ref,
    String? currentPath,
  ) async {
    final choice = await showModalBottomSheet<_PhotoChoice>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Cámara'),
              onTap: () => Navigator.of(context).pop(_PhotoChoice.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galería'),
              onTap: () => Navigator.of(context).pop(_PhotoChoice.gallery),
            ),
            if (currentPath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded),
                title: const Text('Quitar fotografía'),
                onTap: () => Navigator.of(context).pop(_PhotoChoice.remove),
              ),
          ],
        ),
      ),
    );
    if (choice == null) {
      return;
    }
    if (choice == _PhotoChoice.remove) {
      await ref.read(profileControllerProvider.notifier).removePhoto();
      return;
    }
    try {
      final source = choice == _PhotoChoice.camera
          ? ImageSource.camera
          : ImageSource.gallery;
      final path = await ref
          .read(profilePhotoServiceProvider)
          .pickPhoto(source);
      if (path != null) {
        await ref.read(profileControllerProvider.notifier).savePhoto(path);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo seleccionar la fotografía.'),
          ),
        );
      }
    }
  }
}

enum _PhotoChoice { camera, gallery, remove }

class _ProfilePhoto extends StatelessWidget {
  const _ProfilePhoto({
    required this.localPath,
    required this.networkUrl,
    required this.disabled,
    required this.onEdit,
  });

  final String? localPath;
  final String? networkUrl;
  final bool disabled;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipOval(
          child: SizedBox.square(
            dimension: 112,
            child: ColoredBox(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: localPath != null
                  ? Image.file(
                      File(localPath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.person_rounded, size: 52),
                    )
                  : networkUrl?.isNotEmpty == true
                  ? Image.network(
                      networkUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.person_rounded, size: 52),
                    )
                  : const Icon(Icons.person_rounded, size: 52),
            ),
          ),
        ),
        Positioned(
          right: -8,
          bottom: -8,
          child: IconButton.filled(
            tooltip: 'Cambiar fotografía',
            onPressed: disabled ? null : onEdit,
            icon: const Icon(Icons.photo_camera_outlined),
          ),
        ),
      ],
    );
  }
}

class _StatsSummary extends StatelessWidget {
  const _StatsSummary({required this.records});

  final List<FeedingRecord> records;

  @override
  Widget build(BuildContext context) {
    final fed = records.where((record) => record.isFed).length;
    return Row(
      children: [
        Expanded(
          child: _StatValue(
            label: 'Programadas',
            value: records.length,
            icon: Icons.event_note_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatValue(
            label: 'Realizadas',
            value: fed,
            icon: Icons.check_circle_outline_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatValue(
            label: 'Pendientes',
            value: records.length - fed,
            icon: Icons.schedule_rounded,
          ),
        ),
      ],
    );
  }
}

class _StatValue extends StatelessWidget {
  const _StatValue({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        height: 112,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22),
              const SizedBox(height: 4),
              Text(
                '$value',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PetStatsTile extends StatelessWidget {
  const _PetStatsTile({required this.pet, required this.records});

  final Pet pet;
  final List<FeedingRecord> records;

  @override
  Widget build(BuildContext context) {
    final fed = records.where((record) => record.isFed).length;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.pets_rounded),
      title: Text(pet.name),
      subtitle: Text('$fed de ${records.length} alimentaciones realizadas'),
    );
  }
}
