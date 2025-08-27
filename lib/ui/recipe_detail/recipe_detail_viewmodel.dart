import 'package:get/get.dart';
import '../../data/models/recipe.dart';
import '../../data/repositories/recipe_repository.dart';

abstract class IRecipeDetailViewModel {
  Recipe? get recipe;
  bool get isLoading;
  bool get isFavorite;
  String? get errorMessage;

  Future<void> loadRecipe(String id);
  Future<bool> isRecipeFavorite(String recipeId, String userId);
  Future<void> toggleFavorite();
}

class RecipeDetailViewModelImpl extends GetxController
    implements IRecipeDetailViewModel {
  final IRecipeRepository _recipeRepository;

  RecipeDetailViewModelImpl(IRecipeRepository recipeRepository)
    : _recipeRepository = recipeRepository;

  final _recipe = Rxn<Recipe>();
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  final _isFavorite = false.obs;

  @override
  String? get errorMessage => _errorMessage.value;

  @override
  bool get isFavorite => _isFavorite.value;

  @override
  bool get isLoading => _isLoading.value;

  @override
  Recipe? get recipe => _recipe.value;

  @override
  Future<void> loadRecipe(String id) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      _recipe.value = await _recipeRepository.getRecipeById(id);
    } catch (e) {
      _errorMessage.value = 'Falha ao buscar receita: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Future<bool> isRecipeFavorite(String recipeId, String userId) async {
    if (recipeId.isEmpty || userId.isEmpty) {
      return false;
    }

    _isLoading.value = true;
    _errorMessage.value = '';

    final result = await _recipeRepository.getFavRecipes(userId);

    final isTempFavorite = result.fold(
      ifLeft: (error) {
        _errorMessage.value =
            'Falha ao buscar receita favorita: ${error.toString()}';
        return false;
      },
      ifRight: (favRecipes) {
        return favRecipes.any((recipe) => recipe.id == recipeId);
      },
    );
    return isTempFavorite;
  }

  @override
  Future<void> toggleFavorite() async {
    if (recipe == null) return;

    _isLoading.value = true;
    _errorMessage.value = '';

    final result = _isFavorite.value
        ? await _recipeRepository.deleteFavRecipe(recipe!.id, recipe!.userId)
        : await _recipeRepository.insertFavRecipe(recipe!.id, recipe!.userId);

    result.fold(
      ifLeft: (error) {
        _errorMessage.value =
            'Falha ao atualizar favorito: ${error.toString()}';
      },
      ifRight: (success) => _isFavorite.value = !_isFavorite.value,
    );

    _isLoading.value = false;
  }
}
