import 'package:finly/core/db/app_database.dart';

class ReceiptCategoryResolver {
  const ReceiptCategoryResolver._();

  static final _tokenPattern = RegExp('[a-z0-9]+');

  static String resolve({
    required List<Category> categories,
    required String? proposedCategory,
    required String merchant,
    required String ocrText,
  }) {
    if (categories.isEmpty) return 'Other';

    final directMatch = _matchByName(categories, proposedCategory);
    if (directMatch != null && directMatch.name.toLowerCase() != 'other') {
      return directMatch.name;
    }

    final text = '$merchant\n$ocrText'.toLowerCase();
    Category? best;
    var bestScore = 0;
    for (final category in categories) {
      final score = _scoreCategory(category.name, text);
      if (score > bestScore) {
        bestScore = score;
        best = category;
      }
    }

    if (best != null) return best.name;
    final other = _findOther(categories);
    return other?.name ?? categories.first.name;
  }

  static Category? _matchByName(List<Category> categories, String? name) {
    if (name == null || name.trim().isEmpty) return null;
    final lower = name.trim().toLowerCase();

    for (final category in categories) {
      if (category.name.toLowerCase() == lower) return category;
    }
    for (final category in categories) {
      final categoryLower = category.name.toLowerCase();
      if (categoryLower.contains(lower) || lower.contains(categoryLower)) {
        return category;
      }
    }
    return null;
  }

  static Category? _findOther(List<Category> categories) {
    for (final category in categories) {
      if (category.name.toLowerCase() == 'other') return category;
    }
    return null;
  }

  static int _scoreCategory(String categoryName, String text) {
    final lowerName = categoryName.toLowerCase();
    var score = 0;

    for (final match in _tokenPattern.allMatches(lowerName)) {
      final token = match.group(0);
      if (token == null || token.length <= 2) continue;
      if (token == 'and' || token == 'other') continue;
      if (text.contains(token)) score += 2;
    }

    for (final hint in _hintsFor(lowerName)) {
      if (text.contains(hint)) score += 3;
    }

    if (lowerName.contains('other')) score -= 1;
    return score;
  }

  static List<String> _hintsFor(String lowerName) {
    if (lowerName.contains('food') || lowerName.contains('dining')) {
      return const [
        'restaurant',
        'cafe',
        'diner',
        'meal',
        'lunch',
        'dinner',
        'breakfast',
        'snack',
        'bakery',
        'coffee',
        'milk tea',
        'fries',
        'burger',
        'pizza',
        'chicken',
        'rice',
        'ramen',
        'samgyup',
        'jollibee',
        'mcdonald',
        'chowking',
        'kfc',
        'greenwich',
        'mang inasal',
        'starbucks',
      ];
    }
    if (lowerName.contains('transport')) {
      return const [
        'grab',
        'move it',
        'joyride',
        'taxi',
        'fare',
        'terminal',
        'fuel',
        'gas',
        'petrol',
        'diesel',
        'petron',
        'shell',
        'caltex',
        'toll',
        'parking',
        'jeep',
        'bus',
        'mrt',
        'lrt',
      ];
    }
    if (lowerName.contains('shop')) {
      return const [
        'mall',
        'store',
        'mart',
        'supermarket',
        'grocery',
        'groceries',
        'department',
        'puregold',
        'savemore',
        'waltermart',
        'robinsons',
        'sm hypermarket',
        'lazada',
        'shopee',
      ];
    }
    if (lowerName.contains('bill') || lowerName.contains('utilit')) {
      return const [
        'electric',
        'water',
        'internet',
        'wifi',
        'load',
        'meralco',
        'pldt',
        'globe',
        'smart',
      ];
    }
    if (lowerName.contains('health') || lowerName.contains('medical')) {
      return const [
        'pharmacy',
        'drugstore',
        'medicine',
        'clinic',
        'hospital',
        'dental',
        'mercury drug',
        'watsons',
      ];
    }
    if (lowerName.contains('entertain')) {
      return const ['cinema', 'movie', 'netflix', 'spotify', 'game', 'arcade'];
    }
    if (lowerName.contains('personal') || lowerName.contains('care')) {
      return const ['salon', 'spa', 'barber', 'haircut', 'skincare'];
    }
    if (lowerName.contains('educat')) {
      return const ['school', 'tuition', 'course', 'class', 'bookstore'];
    }
    return const <String>[];
  }
}
