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

  Future<Recipe?> getRecipeById(String id) async {
    final rawData = await _recipeService.fetchRecipeById(id);
    return rawData != null ? Recipe.fromMap(rawData) : null;
  }

  Future<List<Recipe>> getFavRecipes(String userId) async {
    final rawData = await _recipeService.fetchFavRecipes(userId);
    return rawData
        .where((data) => data['recipes'] != null)
        .map((data) => Recipe.fromMap(data['recipes'] as Map<String, dynamic>))
        .toList();
  }

  Future<void> insertFavRecipe(String recipeId, String userId) async {
    await _recipeService.insertFavRecipe(recipeId, userId);
  }

  Future<void> deleteFavRecipe(String recipeId, String userId) async {
    await _recipeService.deleteFavRecipe(recipeId, userId);
  }
}
