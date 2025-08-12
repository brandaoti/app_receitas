import 'package:app_receitas/data/models/recipe.dart';

import '../di/service_locator.dart';
import '../services/recipe_service.dart';

class RecipeRepository {
  final _recipeService = getIt<RecipeService>();

  Future<List<Recipe>> getRecipes() async {
    try {
      final recipesData = await _recipeService.fetchRecipes();
      return recipesData.map((data) => Recipe.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to load recipes: $e');
    }
  }
}
