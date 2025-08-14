import 'package:get/get.dart';

import '../../data/di/service_locator.dart';
import '../../data/models/recipe.dart';
import '../../data/repositories/recipe_repository.dart';

class FavRecipesViewModel extends GetxController {
  final _repository = getIt<RecipeRepository>();

  final RxList<Recipe> _favRecipes = <Recipe>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  // Getters
  List<Recipe> get favRecipes => _favRecipes;
  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;

  Future<void> getFavRecipes() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      // TODO: colocar  dinamicamente
      final userId = '790e503c-30de-438c-9998-d7183cea4532';
      _favRecipes.value = await _repository.getFavRecipes(userId);
    } catch (e) {
      _errorMessage.value = 'Falha ao buscar receitas: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }
}
