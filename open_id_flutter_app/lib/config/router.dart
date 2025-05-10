import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/blocs/auth_bloc.dart';
import '../features/auth/models/auth_state.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';

GoRouter createRouter(BuildContext context) {
  final authBloc = context.read<AuthBloc>();

  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authBloc),
    redirect: (context, state) {
      debugPrint('GoRouter redirect проверяет состояние: ${authBloc.state}');
      final authState = authBloc.state;

      final isLoginRoute = state.matchedLocation == '/login';

      if (authState is! Unauthenticated && authState is! Initial) {
        debugPrint(
          'Пользователь авторизован, перенаправление с $isLoginRoute на /',
        );
        if (isLoginRoute) {
          return '/';
        }
        return null;
      }

      if (!isLoginRoute) {
        debugPrint('Пользователь не авторизован, перенаправление на /login');
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(AuthBloc bloc) {
    _subscription = bloc.stream.listen((state) {
      debugPrint('AuthBloc изменил состояние: $state');
      notifyListeners();
    });
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
