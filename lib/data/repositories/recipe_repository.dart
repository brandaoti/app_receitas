import 'package:app_receitas/data/models/recipe.dart';
import 'package:dart_either/dart_either.dart';
import '../../utils/exceptions/default_exception.dart';
import '../../utils/typedef.dart';
import '../services/recipe_service.dart';

abstract class IRecipeRepository {
  Future<Output<List<Recipe>>> getRecipes();
  Future<Recipe?> getRecipeById(String id);
  Future<List<Recipe>> getFavRecipes(String userId);
  Future<void> insertFavRecipe(String recipeId, String userId);
  Future<void> deleteFavRecipe(String recipeId, String userId);
}

class RecipeRepositoryImpl implements IRecipeRepository {
  final RecipeService _recipeService;

  RecipeRepositoryImpl(RecipeService recipeService)
    : _recipeService = recipeService;

  @override
  Future<Output<List<Recipe>>> getRecipes() async {
    try {
      final recipesData = await _recipeService.fetchRecipes();
      return Right(recipesData.map((data) => Recipe.fromMap(data)).toList());
    } catch (e) {
      return Left(DefaultException(message: 'Failed to load recipes: $e'));
    }
  }

  @override
  Future<Recipe?> getRecipeById(String id) async {
    final rawData = await _recipeService.fetchRecipeById(id);
    return rawData != null ? Recipe.fromMap(rawData) : null;
  }

  @override
  Future<List<Recipe>> getFavRecipes(String userId) async {
    final rawData = await _recipeService.fetchFavRecipes(userId);
    return rawData
        .where((data) => data['recipes'] != null)
        .map((data) => Recipe.fromMap(data['recipes'] as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> insertFavRecipe(String recipeId, String userId) async {
    await _recipeService.insertFavRecipe(recipeId, userId);
  }

  @override
  Future<void> deleteFavRecipe(String recipeId, String userId) async {
    await _recipeService.deleteFavRecipe(recipeId, userId);
  }
}
