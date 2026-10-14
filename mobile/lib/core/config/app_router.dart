import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eazzio_school/features/auth/models/auth_user.dart';
import 'package:eazzio_school/features/auth/presentation/auth_controller.dart';
import 'package:eazzio_school/features/auth/presentation/login_screen.dart';
import 'package:eazzio_school/features/student/presentation/student_main_screen.dart';
import 'package:eazzio_school/features/teacher/presentation/teacher_main_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuth = authState.status == AuthStatus.authenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isAuth) {
        return isLoggingIn ? null : '/login';
      }

      // If authenticated and trying to access /login, redirect to appropriate role portal
      if (isLoggingIn) {
        if (authState.user?.role == UserRole.teacher ||
            authState.user?.role == UserRole.admin ||
            authState.user?.role == UserRole.principal) {
          return '/teacher';
        } else {
          return '/student';
        }
      }

      // Role guards: prevent students accessing /teacher and vice versa
      final target = state.matchedLocation;
      if (target.startsWith('/teacher') &&
          authState.user?.role == UserRole.student) {
        return '/student';
      }
      if (target.startsWith('/student') &&
          (authState.user?.role == UserRole.teacher ||
              authState.user?.role == UserRole.admin ||
              authState.user?.role == UserRole.principal)) {
        return '/teacher';
      }

      return null;
    },
    routes: [
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
