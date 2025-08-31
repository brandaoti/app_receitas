import 'package:app_receitas/ui/recipe_detail/recipe_detail_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../data/di/service_locator.dart';
import '../widgets/recipe_row_details.dart';

class RecipeDetailView extends StatefulWidget {
  const RecipeDetailView({super.key, required this.id});

  final String id;

  @override
  State<RecipeDetailView> createState() => _RecipeDetailViewState();
}

class _RecipeDetailViewState extends State<RecipeDetailView> {
  late final IRecipeDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = getIt<IRecipeDetailViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadRecipe(widget.id);
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

      if (_viewModel.errorMessage! != '') {
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
                    context.go('/');
                  },
                  child: Text('VOLTAR'),
                ),
              ],
            ),
          ),
        );
      }

      final recipe = _viewModel.recipe!;
      return SingleChildScrollView(
        child: Column(
          children: [
            Image.network(
              recipe.image!,
              height: 400,
              width: double.infinity,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) =>
                  loadingProgress == null
                  ? child
                  : Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
              errorBuilder: (context, child, stackTrace) => Container(
                height: 400,
                width: double.infinity,
                color: Theme.of(context).colorScheme.primary,
                child: Icon(Icons.error),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(recipe.name),
                  const SizedBox(height: 16),
                  RecipeRowDetails(recipe: recipe),
                  const SizedBox(height: 16),
                  recipe.ingredients.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Ingredientes:'),
                            const SizedBox(height: 8),
                            Text(recipe.ingredients.join('\n')),
                          ],
                        )
                      : Text('Nenhum ingrediente listado.'),
                  const SizedBox(height: 16),
                  recipe.instructions.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Instruções:'),
                            const SizedBox(height: 8),
                            Text(recipe.instructions.join('\n')),
                          ],
                        )
                      : Text('Nenhuma instrução :('),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => context.go('/favorites'),
                        child: Text('VOLTAR'),
                      ),
                      ElevatedButton(
                        onPressed: () => _viewModel.toggleFavorite(),
                        child: Text(
                          _viewModel.isFavorite ? 'DESFAVORITAR' : 'FAVORITAR',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
