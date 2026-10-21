import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petreminder_admin/providers/auth_providers.dart';

class AdminShell extends ConsumerWidget {
  const AdminShell({
    required this.location,
    required this.child,
    this.routePrefix = '',
    super.key,
  });

  final String location;
  final Widget child;
  final String routePrefix;

  String get _dashboardRoute =>
      routePrefix.isEmpty ? '/dashboard' : '$routePrefix/dashboard';

  String get _usersRoute =>
      routePrefix.isEmpty ? '/users' : '$routePrefix/users';

  int get _selectedIndex => location.startsWith(_usersRoute) ? 1 : 0;

  void _navigate(BuildContext context, int index) {
    context.go(index == 0 ? _dashboardRoute : _usersRoute);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wide = MediaQuery.sizeOf(context).width >= 760;
    final destinations = const [
      NavigationRailDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard_rounded),
        label: Text('Dashboard'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.people_outline_rounded),
        selectedIcon: Icon(Icons.people_rounded),
        label: Text('Usuarios'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pets_rounded),
            SizedBox(width: 10),
            Text('PetReminder Admin'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          if (wide)
            NavigationRail(
              selectedIndex: _selectedIndex,
              extended: MediaQuery.sizeOf(context).width >= 1080,
              onDestinationSelected: (index) => _navigate(context, index),
              destinations: destinations,
            ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) => _navigate(context, index),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outline_rounded),
                  selectedIcon: Icon(Icons.people_rounded),
                  label: 'Usuarios',
                ),
              ],
            ),
    );
  }
}
