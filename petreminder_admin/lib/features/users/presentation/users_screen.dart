import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:petreminder_admin/features/users/presentation/widgets/status_badge.dart';
import 'package:petreminder_admin/features/users/presentation/widgets/user_avatar.dart';
import 'package:petreminder_admin/models/admin_user.dart';
import 'package:petreminder_admin/providers/admin_providers.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({this.usersRoute = '/users', super.key});

  final String usersRoute;

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(usersProvider);
    final pets = ref.watch(allPetsProvider);
    final petCounts = <String, int>{};
    for (final pet in pets.value ?? []) {
      petCounts[pet.userId] = (petCounts[pet.userId] ?? 0) + 1;
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Usuarios',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text('Consulta y gestión del estado de las cuentas.'),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: TextField(
                  onChanged: (value) => setState(() => _query = value),
                  decoration: const InputDecoration(
                    hintText: 'Buscar por nombre o correo',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: users.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) =>
                      _UsersError(onRetry: () => ref.invalidate(usersProvider)),
                  data: (items) {
                    final normalized = _query.trim().toLowerCase();
                    final filtered = items.where((user) {
                      return normalized.isEmpty ||
                          user.name.toLowerCase().contains(normalized) ||
                          user.email.toLowerCase().contains(normalized);
                    }).toList();
                    if (filtered.isEmpty) {
                      return const Center(
                        child: Text('No se encontraron usuarios.'),
                      );
                    }
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final user = filtered[index];
                          return _UserRow(
                            user: user,
                            petCount: petCounts[user.uid] ?? 0,
                            onOpen: () =>
                                context.go('${widget.usersRoute}/${user.uid}'),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({
    required this.user,
    required this.petCount,
    required this.onOpen,
  });

  final AdminUser user;
  final int petCount;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final date = user.createdAt == null
        ? 'Sin fecha'
        : DateFormat('dd/MM/yyyy').format(user.createdAt!);
    final narrow = MediaQuery.sizeOf(context).width < 720;
    return InkWell(
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            UserAvatar(name: user.name, photoUrl: user.photoUrl),
            const SizedBox(width: 14),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    user.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (narrow) ...[
                    const SizedBox(height: 6),
                    Text('$petCount mascotas · $date'),
                  ],
                ],
              ),
            ),
            if (!narrow) ...[
              Expanded(child: Text(date)),
              Expanded(child: Text('$petCount mascotas')),
            ],
            StatusBadge(active: user.isActive),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _UsersError extends StatelessWidget {
  const _UsersError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('No se pudieron cargar. Reintentar'),
      ),
    );
  }
}
