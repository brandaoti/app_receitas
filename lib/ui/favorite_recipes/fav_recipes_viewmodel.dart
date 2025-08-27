import 'package:get/get.dart';

import '../../data/models/recipe.dart';
import '../../data/repositories/recipe_repository.dart';

abstract class IFavRecipesViewModel {
  bool get isLoading;
  String? get errorMessage;
  List<Recipe> get favRecipes;

  Future<void> getFavRecipes();
}

class FavRecipesViewModelImpl extends GetxController
    implements IFavRecipesViewModel {
  final IRecipeRepository _recipeRepository;

  FavRecipesViewModelImpl(IRecipeRepository recipeRepository)
    : _recipeRepository = recipeRepository;

  final _favRecipes = <Recipe>[].obs;
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;

  @override
  String? get errorMessage => _errorMessage.value;

  @override
  List<Recipe> get favRecipes => _favRecipes;

  @override
  bool get isLoading => _isLoading.value;

  @override
  Future<void> getFavRecipes() async {
    if (favRecipes.isNotEmpty) return;

    _isLoading.value = true;
    _errorMessage.value = '';

    final userId = '18e2ed83-1e9c-4537-a839-953d56552e1e';

    final result = await _recipeRepository.getFavRecipes(userId);

    result.fold(
      ifLeft: (error) {
        _errorMessage.value =
            'Falha ao buscar receitas favoritas: ${error.toString()}';
      },
      ifRight: (recipes) => _favRecipes.value = recipes,
    );

    _isLoading.value = false;
  }
}
