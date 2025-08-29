import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:go_router/go_router.dart';

import '../../data/di/service_locator.dart';
import '../widgets/recipe_card.dart';
import 'fav_recipes_viewmodel.dart';

class FavRecipesView extends StatefulWidget {
  const FavRecipesView({super.key});

  @override
  State<FavRecipesView> createState() => _FavRecipesViewState();
}

class _FavRecipesViewState extends State<FavRecipesView> {
  late final IFavRecipesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<IFavRecipesViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.getFavRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_viewModel.isLoading) {
        return Center(
          child: SizedBox(
            height: 96,
            width: 96,
            child: CircularProgressIndicator(strokeWidth: 12),
          ),
        );
      }

      if (_viewModel.errorMessage != '') {
        return Center(
          child: Container(
            padding: EdgeInsets.all(32),
            child: Column(
              spacing: 32,
              children: [
                Text(
                  'Erro: ${_viewModel.errorMessage}',
                  style: TextStyle(fontSize: 24),
                ),
                ElevatedButton(
                  onPressed: () {
                    _viewModel.getFavRecipes();
                  },
                  child: Text('TENTAR NOVAMENTE'),
                ),
              ],
            ),
          ),
        );
      }

      return Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: _viewModel.favRecipes.isNotEmpty
                  ? Center(
                      child: Column(
                        children: [
                          Text(
                            '${_viewModel.favRecipes.length} favorita(s)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _viewModel.favRecipes.length,
                              itemBuilder: (context, index) {
                                final recipe = _viewModel.favRecipes[index];
                                return Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: () =>
                                          context.go('/recipe/${recipe.id}'),
                                      child: RecipeCard(recipe: recipe),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 64),
                          Icon(
                            Icons.favorite,
                            size: 96,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Adicione suas receitas favoritas!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      );
    });
  }
}
