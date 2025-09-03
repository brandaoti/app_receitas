import 'package:get/get.dart';
import '../../data/models/recipe.dart';
import '../../data/repositories/auth_repository.dart';
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
  final IAuthRepository _authRepository;

  RecipeDetailViewModelImpl({
    required IRecipeRepository recipeRepository,
    required IAuthRepository authRepository,
  }) : _recipeRepository = recipeRepository,
       _authRepository = authRepository;

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

      var userId = '';

      final currentUserResult = await _authRepository.currentUser;
      currentUserResult.fold(
        ifLeft: (error) {
          _errorMessage.value = error.message;
          return;
        },
        ifRight: (user) => userId = user.id,
      );
      _isFavorite.value = await isRecipeFavorite(id, userId);
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

    var userId = '';

    final currentUserResult = await _authRepository.currentUser;
    currentUserResult.fold(
      ifLeft: (error) {
        _errorMessage.value = error.message;
        return;
      },
      ifRight: (user) => userId = user.id,
    );

    final result = _isFavorite.value
        ? await _recipeRepository.deleteFavRecipe(recipe!.id, userId)
        : await _recipeRepository.insertFavRecipe(recipe!.id, userId);

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
