import 'package:get/get.dart';

import '../../data/di/service_locator.dart';
import '../../data/models/recipe.dart';
import '../../data/repositories/recipe_repository.dart';

class RecipeViewModel extends GetxController {
  final _recipeRepository = getIt<RecipeRepository>();

  final RxList<Recipe> _recipes = <Recipe>[].obs;
  final RxBool _isLoading = true.obs;
  final RxString _errorMessage = ''.obs;

  @override
  void onInit() {
    getRecipes();
    super.onInit();
  }

  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;

  void getRecipes() async {
    _isLoading.value = true;
    try {
      _errorMessage.value = '';
      _recipes.value = await _recipeRepository.getRecipes();
    } catch (e) {
      _errorMessage.value = 'Falha ao buscar receitas';
    } finally {
      _isLoading.value = false;
    }
  }
}
