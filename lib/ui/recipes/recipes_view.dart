import 'package:app_receitas/data/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:go_router/go_router.dart';

import '../widgets/recipe_card.dart';
import 'recipe_view_model.dart';

class RecipesView extends StatefulWidget {
  const RecipesView({super.key});

  @override
  State<RecipesView> createState() => _RecipesViewState();
}

class _RecipesViewState extends State<RecipesView> {
  late final IRecipeViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = getIt<IRecipeViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.onInit();
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
                    _viewModel.getRecipes();
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
              child: _viewModel.recipes.isNotEmpty
                  ? Center(
                      child: Column(
                        children: [
                          Text(
                            '${_viewModel.recipes.length} receitas(s)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _viewModel.recipes.length,
                              itemBuilder: (context, index) {
                                final recipe = _viewModel.recipes[index];
                                return Stack(
                                  children: [
                                    GestureDetector(
                                      child: RecipeCard(recipe: recipe),
                                      onTap: () =>
                                          context.go('/recipe/${recipe.id}'),
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
