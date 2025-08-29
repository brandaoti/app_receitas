import 'package:app_receitas/data/models/recipe.dart';
import 'package:dart_either/dart_either.dart';
import '../../utils/exceptions/default_exception.dart';
import '../../utils/typedef.dart';
import '../services/recipe_service.dart';

abstract class IRecipeRepository {
  Future<Output<List<Recipe>>> getRecipes();
  Future<Recipe?> getRecipeById(String id);
  Future<Output<List<Recipe>>> getFavRecipes(String userId);
  Future<Output<Unit>> insertFavRecipe(String recipeId, String userId);
  Future<Output<Unit>> deleteFavRecipe(String recipeId, String userId);
}

class RecipeRepositoryImpl implements IRecipeRepository {
  final IRecipeService _recipeService;

  const RecipeRepositoryImpl(IRecipeService recipeService)
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
  Future<Output<List<Recipe>>> getFavRecipes(String userId) async {
    final rawData = await _recipeService.fetchFavRecipes(userId);
    try {
      final recipes = rawData
          .where((data) => data['recipes'] != null)
          .map(
            (data) => Recipe.fromMap(data['recipes'] as Map<String, dynamic>),
          )
          .toList();
      return Right(recipes);
    } catch (e) {
      return Left(
        DefaultException(message: 'Failed to load favorite recipes: $e'),
      );
    }
  }

  @override
  Future<Output<Unit>> insertFavRecipe(String recipeId, String userId) async {
    try {
      await _recipeService.insertFavRecipe(recipeId, userId);
      return Right(unit);
    } catch (e) {
      return Left(
        DefaultException(message: 'Failed to insert favorite recipe: $e'),
      );
    }
  }

  @override
  Future<Output<Unit>> deleteFavRecipe(String recipeId, String userId) async {
    try {
      await _recipeService.deleteFavRecipe(recipeId, userId);
      return Right(unit);
    } catch (e) {
      return Left(
        DefaultException(message: 'Failed to delete favorite recipe: $e'),
      );
    }
  }
}
