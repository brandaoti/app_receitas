class Recipe {
  final String id;
  final String name;
  final List<String> ingredients;
  final List<String> instructions;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final String difficulty;
  final String cuisine;
  final int caloriesPerServing;
  final List<String> tags;
  final String userId;
  final String? image;
  final double? rating;
  final int? reviewCount;
  final List<String> mealType;

  int get totalTimeMinutes => prepTimeMinutes + cookTimeMinutes;

  Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.instructions,
    this.prepTimeMinutes = 0,
    this.cookTimeMinutes = 0,
    this.servings = 0,
    this.difficulty = '',
    this.cuisine = '',
    this.caloriesPerServing = 0,
    this.tags = const [],
    required this.userId,
    this.image,
    this.rating,
    this.reviewCount,
    this.mealType = const [],
  });

  factory Recipe.fromMap(Map<String, dynamic> json) {
    return Recipe(
      id: json['id']?.toString() ?? '', // garante string
      name: json['name']?.toString() ?? '',
      ingredients: _parseJsonList(json['ingredients']),
      instructions: _parseJsonList(json['instructions']),
      prepTimeMinutes: json['prep_time_minutes'] ?? 0,
      cookTimeMinutes: json['cook_time_minutes'] ?? 0,
      servings: json['servings'] ?? 0,
      difficulty: json['difficulty']?.toString() ?? '',
      cuisine: json['cuisine']?.toString() ?? '',
      caloriesPerServing: json['calories_per_serving'] ?? 0,
      tags: _parseJsonListOptional(json['tags']) ?? [],
      userId: json['user_id']?.toString() ?? '',
      image: json['image'] as String?,
      rating: json['rating'] != null
          ? (json['rating'] as num).toDouble()
          : null,
      reviewCount: json['review_count'] as int?,
      mealType: _parseJsonListOptional(json['meal_type']) ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ingredients': ingredients,
      'instructions': instructions,
      'prep_time_minutes': prepTimeMinutes,
      'cook_time_minutes': cookTimeMinutes,
      'servings': servings,
      'difficulty': difficulty,
      'cuisine': cuisine,
      'calories_per_serving': caloriesPerServing,
      'tags': tags,
      'user_id': userId,
      'image': image,
      'rating': rating,
      'review_count': reviewCount,
      'meal_type': mealType,
    };
  }

  static List<String> _parseJsonList(dynamic json) {
    if (json is List) return json.map((e) => e.toString()).toList();
    if (json is String) return json.split(',').map((e) => e.trim()).toList();
    return [];
  }

  static List<String>? _parseJsonListOptional(dynamic json) {
    if (json == null) return [];
    return _parseJsonList(json);
  }
}
