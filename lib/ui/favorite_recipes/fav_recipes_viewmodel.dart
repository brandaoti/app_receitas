import 'package:app_receitas/data/repositories/auth_repository.dart';
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
  final IAuthRepository _authRepository;

  FavRecipesViewModelImpl({
    required IRecipeRepository recipeRepository,
    required IAuthRepository authRepository,
  }) : _recipeRepository = recipeRepository,
       _authRepository = authRepository;

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
    _isLoading.value = true;
    _errorMessage.value = '';

    late final String userId;

    final currentUser = await _authRepository.currentUser;

    currentUser.fold(
      ifLeft: (error) {
        _errorMessage.value = error.message;
        _isLoading.value = false;
        return;
      },
      ifRight: (user) => userId = user.id,
    );

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
