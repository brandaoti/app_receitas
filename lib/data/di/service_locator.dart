import 'package:app_receitas/data/repositories/recipe_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../ui/recipes/recipe_view_model.dart';
import '../services/recipe_service.dart';

final getIt = GetIt.instance;

class ServiceLocator {
  void setup() {
    getIt.registerSingleton<SupabaseClient>(Supabase.instance.client);

    getIt.registerLazySingleton<RecipeService>(() => RecipeService());
    getIt.registerLazySingleton<RecipeRepository>(() => RecipeRepository());
    getIt.registerLazySingleton<RecipeViewModel>(() => RecipeViewModel());
  }
}
