import 'package:supabase_flutter/supabase_flutter.dart';

abstract class IRecipeService {
  Future<List<PostgrestMap>> fetchRecipes();
  Future<Map<String, dynamic>?> fetchRecipeById(String id);
  Future<List<PostgrestMap>> fetchFavRecipes(String userId);
  Future<void> insertFavRecipe(String recipeId, String userId);
  Future<void> deleteFavRecipe(String recipeId, String userId);
}

class RecipeServiceImpl implements IRecipeService {
  final SupabaseClient _client;

  const RecipeServiceImpl(SupabaseClient client) : _client = client;

  @override
  Future<List<PostgrestMap>> fetchRecipes() async {
    final response = await _client
        .from('recipes')
        .select()
        .order('id', ascending: true);
    return response;
  }

  @override
  Future<Map<String, dynamic>?> fetchRecipeById(String id) async {
    return await _client.from('recipes').select().eq('id', id).single();
  }

  @override
  Future<List<PostgrestMap>> fetchFavRecipes(String userId) async {
    return await _client
        .from('favorites')
        .select('''
        recipes(
          id,
          name,
          ingredients,
          instructions,
          prep_time_minutes,
          cook_time_minutes,
          servings,
          difficulty,
          cuisine,
          calories_per_serving,
          tags,
          user_id,
          image,
          rating,
          review_count,
          meal_type
        )
      ''')
        .eq('user_id', userId);
  }

  @override
  Future<void> insertFavRecipe(String recipeId, String userId) async {
    await _client.from('favorites').insert({
      'recipe_id': recipeId,
      'user_id': userId,
    });
  }

  @override
  Future<void> deleteFavRecipe(String recipeId, String userId) async {
    await _client
        .from('favorites')
        .delete()
        .eq('recipe_id', recipeId)
        .eq('user_id', userId);
  }
}
