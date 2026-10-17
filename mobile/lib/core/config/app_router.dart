import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eazzio_school/features/auth/models/auth_user.dart';
import 'package:eazzio_school/features/auth/presentation/auth_controller.dart';
import 'package:eazzio_school/features/auth/presentation/role_selection_screen.dart';
import 'package:eazzio_school/features/auth/presentation/login_screen.dart';
import 'package:eazzio_school/features/student/presentation/student_main_screen.dart';
import 'package:eazzio_school/features/teacher/presentation/teacher_main_screen.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authNotifierProvider,
      (_, __) => notifyListeners(),
    );
  }

  String? redirect(context, GoRouterState state) {
    final authState = _ref.read(authNotifierProvider);
    final isAuth = authState.status == AuthStatus.authenticated;
    final loc = state.matchedLocation;
    final isAuthRoute = loc == '/' || loc == '/login';

    if (!isAuth) {
      return isAuthRoute ? null : '/';
    }

    // If authenticated and trying to access role selection or /login, redirect to role dashboard
    if (isAuthRoute) {
      if (authState.user?.role == UserRole.teacher ||
          authState.user?.role == UserRole.admin ||
          authState.user?.role == UserRole.principal) {
        return '/teacher';
      } else {
        return '/student';
      }
    }

    // Role guards: prevent students accessing /teacher and vice versa
    if (loc.startsWith('/teacher') &&
        authState.user?.role == UserRole.student) {
      return '/student';
    }
    if (loc.startsWith('/student') &&
        (authState.user?.role == UserRole.teacher ||
            authState.user?.role == UserRole.admin ||
            authState.user?.role == UserRole.principal)) {
      return '/teacher';
    }

    return null;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/student',
        builder: (context, state) => const StudentMainScreen(),
      ),
      GoRoute(
        path: '/teacher',
        builder: (context, state) => const TeacherMainScreen(),
      ),
    ],
  );
});
