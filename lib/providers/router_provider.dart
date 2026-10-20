import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petreminder_admin/features/dashboard/presentation/dashboard_screen.dart'
    as admin;
import 'package:petreminder_admin/features/shell/presentation/admin_shell.dart'
    as admin;
import 'package:petreminder_admin/features/users/presentation/user_detail_screen.dart'
    as admin;
import 'package:petreminder_admin/features/users/presentation/users_screen.dart'
    as admin;
import 'package:petreminder_user/core/router/app_routes.dart';
import 'package:petreminder_user/features/auth/presentation/forgot_password_screen.dart';
import 'package:petreminder_user/features/auth/presentation/account_disabled_screen.dart';
import 'package:petreminder_user/features/auth/presentation/login_screen.dart';
import 'package:petreminder_user/features/auth/presentation/register_screen.dart';
import 'package:petreminder_user/features/history/presentation/history_screen.dart';
import 'package:petreminder_user/features/pets/presentation/pet_form_screen.dart';
import 'package:petreminder_user/features/pets/presentation/pet_detail_screen.dart';
import 'package:petreminder_user/features/pets/presentation/pets_screen.dart';
import 'package:petreminder_user/features/profile/presentation/profile_screen.dart';
import 'package:petreminder_user/features/shell/presentation/app_shell_screen.dart';
import 'package:petreminder_user/models/pet.dart';
import 'package:petreminder_user/providers/auth_providers.dart';
import 'package:petreminder_user/providers/profile_providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  final adminAccess = ref.watch(adminAccessProvider);
  final appUser = ref.watch(appUserProvider);

  final router = GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.accountDisabled,
        builder: (context, state) => const AccountDisabledScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => admin.AdminShell(
          location: state.uri.path,
          routePrefix: '/admin',
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.adminDashboard,
            builder: (_, _) => const admin.DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.adminUsers,
            builder: (_, _) =>
                const admin.UsersScreen(usersRoute: AppRoutes.adminUsers),
            routes: [
              GoRoute(
                path: ':userId',
                builder: (_, state) => admin.UserDetailScreen(
                  userId: state.pathParameters['userId']!,
                  usersRoute: AppRoutes.adminUsers,
                ),
              ),
            ],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShellScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const PetsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.history,
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.addPet,
        builder: (context, state) => const PetFormScreen(),
      ),
      GoRoute(
        path: '/pets/:petId/edit',
        builder: (context, state) {
          final pet = state.extra;
          return pet is Pet ? PetFormScreen(pet: pet) : const PetsScreen();
        },
      ),
      GoRoute(
        path: '/pets/:petId',
        builder: (context, state) {
          final pet = state.extra;
          return pet is Pet ? PetDetailScreen(pet: pet) : const PetsScreen();
        },
      ),
    ],
    redirect: (context, state) {
      if (authState.isLoading) {
        return null;
      }

      final isAuthenticated = authState.value != null;
      final isAdminRoute = state.matchedLocation.startsWith('/admin');
      final isDisabled = appUser.value?.accountStatus == 'disabled';
      final isDisabledRoute =
          state.matchedLocation == AppRoutes.accountDisabled;
      final isPublicRoute = switch (state.matchedLocation) {
        AppRoutes.login ||
        AppRoutes.register ||
        AppRoutes.forgotPassword => true,
        _ => false,
      };

      if (!isAuthenticated && !isPublicRoute) {
        return AppRoutes.login;
      }
      if (isAuthenticated && adminAccess.isLoading) {
        return null;
      }
      if (isAuthenticated && adminAccess.value == true) {
        return isAdminRoute ? null : AppRoutes.adminDashboard;
      }
      if (isAuthenticated && isAdminRoute) {
        return AppRoutes.home;
      }
      if (isAuthenticated && isDisabled && !isDisabledRoute) {
        return AppRoutes.accountDisabled;
      }
      if (isAuthenticated && !isDisabled && isDisabledRoute) {
        return AppRoutes.home;
      }
      if (isAuthenticated && isPublicRoute) {
        return isDisabled ? AppRoutes.accountDisabled : AppRoutes.home;
      }
      return null;
    },
  );

  ref.onDispose(router.dispose);
  return router;
});
