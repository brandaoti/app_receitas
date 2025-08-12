import 'package:supabase_flutter/supabase_flutter.dart';

import '../di/service_locator.dart';

class RecipeService {
  final _supabaseClient = getIt.get<SupabaseClient>();

  Future<List<Map<String, dynamic>>> fetchRecipes() async {
    final response = await _supabaseClient
        .from('recipes')
        .select()
        .order('id', ascending: true);
    return response;
  }
}
