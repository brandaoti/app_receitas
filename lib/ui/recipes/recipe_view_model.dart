import 'package:get/get.dart';
import '../../data/models/recipe.dart';
import '../../data/repositories/recipe_repository.dart';

abstract class IRecipeViewModel {
  bool get isLoading;
  String? get errorMessage;
  List<Recipe> get recipes;

  void onInit();
  Future<void> getRecipes();
}

class RecipeViewModelImpl extends GetxController implements IRecipeViewModel {
  final IRecipeRepository _recipeRepository;

  RecipeViewModelImpl(IRecipeRepository recipeRepository)
    : _recipeRepository = recipeRepository;

  @override
  void onInit() {
    getRecipes();
    super.onInit();
  }

  final RxBool _isLoading = true.obs;
  final RxString _errorMessage = ''.obs;
  final RxList<Recipe> _recipes = <Recipe>[].obs;

  @override
  List<Recipe> get recipes => _recipes;

  @override
  bool get isLoading => _isLoading.value;

  @override
  String? get errorMessage => _errorMessage.value;

  @override
  Future<void> getRecipes() async {
    _isLoading.value = true;

    final result = await _recipeRepository.getRecipes();

    result.fold(
      ifLeft: (error) {
        _errorMessage.value = error.message;
      },
      ifRight: (value) {
        _recipes.value = value;
        _isLoading.value = false;
      },
    );
  }
}
