import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petreminder_admin/features/auth/presentation/access_denied_screen.dart';
import 'package:petreminder_admin/features/auth/presentation/login_screen.dart';
import 'package:petreminder_admin/features/dashboard/presentation/dashboard_screen.dart';
import 'package:petreminder_admin/features/shell/presentation/admin_shell.dart';
import 'package:petreminder_admin/features/users/presentation/user_detail_screen.dart';
import 'package:petreminder_admin/features/users/presentation/users_screen.dart';
import 'package:petreminder_admin/providers/auth_providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(adminSessionProvider);
  final router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/denied', builder: (_, _) => const AccessDeniedScreen()),
      ShellRoute(
        builder: (context, state, child) =>
            AdminShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (_, _) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/users',
            builder: (_, _) => const UsersScreen(),
            routes: [
              GoRoute(
                path: ':userId',
                builder: (_, state) =>
                    UserDetailScreen(userId: state.pathParameters['userId']!),
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      if (session.isLoading) {
        return null;
      }
      final value = session.value;
      final atLogin = state.uri.path == '/login';
      final atDenied = state.uri.path == '/denied';
      if (value == null) {
        return atLogin ? null : '/login';
      }
      if (!value.isAdmin) {
        return atDenied ? null : '/denied';
      }
      if (atLogin || atDenied) {
        return '/dashboard';
      }
      return null;
    },
  );
  ref.onDispose(router.dispose);
  return router;
});
