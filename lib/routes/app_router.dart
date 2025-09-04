import 'package:app_receitas/ui/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/di/service_locator.dart';
import '../data/services/auth_service.dart';
import '../ui/auth/auth_view.dart';
import '../ui/base_screen.dart';
import '../ui/favorite_recipes/fav_recipes_view.dart';
import '../ui/recipe_detail/recipe_detail_view.dart';
import '../ui/recipes/recipes_view.dart';

class AppRouter {
  late final GoRouter router;

  late final IAuthService _service;

  late final ValueNotifier<bool> _authStateNotifier;

  AppRouter() {
    _service = getIt<IAuthService>();

    _authStateNotifier = ValueNotifier<bool>(_service.currentUser != null);

    _service.authStateChanges.listen((_) async {
      _authStateNotifier.value = _service.currentUser != null;
    });

    router = GoRouter(
      initialLocation: '/',
      refreshListenable: _authStateNotifier,
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SplashView()),
        GoRoute(path: '/login', builder: (context, state) => const AuthView()),
        ShellRoute(
          builder: (context, state, child) => BaseScreen(child: child),
          routes: [
            GoRoute(path: '/home', builder: (context, state) => RecipesView()),
            GoRoute(
              path: '/recipe/:id',
              builder: (context, state) =>
                  RecipeDetailView(id: state.pathParameters['id']!),
            ),
            GoRoute(
              path: '/favorites',
              builder: (context, state) => FavRecipesView(),
            ),
          ],
        ),
      ],

      redirect: (context, state) {
        final isLoggedIn = _authStateNotifier.value;
        final currentPath = state.uri.path;

        if (currentPath == '/') return null;

        if (!isLoggedIn && currentPath != '/login') {
          return '/login';
        }

        if (isLoggedIn && currentPath == '/login') {
          return '/home';
        }

        return null;
      },
    );
  }
}
