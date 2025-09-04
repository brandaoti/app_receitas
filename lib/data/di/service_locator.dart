import 'package:app_receitas/data/repositories/recipe_repository.dart';
import 'package:app_receitas/data/services/auth_service.dart';
import 'package:app_receitas/ui/recipe_detail/recipe_detail_viewmodel.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../ui/auth/auth_viewmodel.dart';
import '../../ui/favorite_recipes/fav_recipes_viewmodel.dart';
import '../../ui/recipes/recipe_view_model.dart';

import '../repositories/auth_repository.dart';
import '../services/recipe_service.dart';

final getIt = GetIt.instance;

class ServiceLocator {
  void setup() {
    getIt.registerSingleton<SupabaseClient>(Supabase.instance.client);

    // Services
    getIt.registerLazySingleton<IRecipeService>(
      () => RecipeServiceImpl(getIt<SupabaseClient>()),
    );
    getIt.registerLazySingleton<IAuthService>(
      () => AuthServiceImpl(getIt<SupabaseClient>()),
    );

    // Repositories
    getIt.registerLazySingleton<IRecipeRepository>(
      () => RecipeRepositoryImpl(getIt<IRecipeService>()),
    );
    getIt.registerLazySingleton<IAuthRepository>(
      () => AuthRepositoryImpl(getIt<IAuthService>()),
    );

    // Controllers
    getIt.registerLazySingleton<IRecipeViewModel>(
      () => RecipeViewModelImpl(getIt<IRecipeRepository>()),
    );
    getIt.registerLazySingleton<AuthViewModel>(
      () => AuthViewModel(getIt<IAuthRepository>()),
    );
    getIt.registerLazySingleton<IFavRecipesViewModel>(
      () => FavRecipesViewModelImpl(
        authRepository: getIt<IAuthRepository>(),
        recipeRepository: getIt<IRecipeRepository>(),
      ),
    );
    getIt.registerLazySingleton<IRecipeDetailViewModel>(
      () => RecipeDetailViewModelImpl(
        recipeRepository: getIt<IRecipeRepository>(),
        authRepository: getIt<IAuthRepository>(),
      ),
    );
  }
}
