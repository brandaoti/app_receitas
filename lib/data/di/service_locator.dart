import 'package:app_receitas/data/repositories/recipe_repository.dart';
import 'package:app_receitas/ui/recipe_detail/recipe_detail_viewmodel.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../ui/auth/auth_viewmodel.dart';
import '../../ui/favorite_recipes/fav_recipes_viewmodel.dart';
import '../../ui/recipes/recipe_view_model.dart';
import '../services/recipe_service.dart';

final getIt = GetIt.instance;

class ServiceLocator {
  void setup() {
    getIt.registerSingleton<SupabaseClient>(Supabase.instance.client);

    getIt.registerLazySingleton<RecipeService>(() => RecipeService());

    getIt.registerLazySingleton<IRecipeRepository>(
      () => RecipeRepositoryImpl(getIt<RecipeService>()),
    );

    //Views models
    getIt.registerLazySingleton<IRecipeViewModel>(
      () => RecipeViewModelImpl(getIt<IRecipeRepository>()),
    );
    getIt.registerLazySingleton<AuthViewModel>(() => AuthViewModel());

    getIt.registerLazySingleton<IFavRecipesViewModel>(
      () => FavRecipesViewModelImpl(getIt<IRecipeRepository>()),
    );

    getIt.registerLazySingleton<IRecipeDetailViewModel>(
      () => RecipeDetailViewModelImpl(getIt<IRecipeRepository>()),
    );
  }
}
