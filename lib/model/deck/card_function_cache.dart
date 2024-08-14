import 'package:primea/model/deck/card_function.dart';

class CardFunctionCacheResults {
  final Map<int, CardFunction> cardFunctions;
  final List<int> cardIds;

  CardFunctionCacheResults()
      : cardFunctions = {},
        cardIds = [];
}

class CardFunctionCache {
  static final Map<int, CardFunction> _cache = {};

  static CardFunction? get(int id) {
    return _cache[id];
  }

  static void set(CardFunction cardFunction) {
    _cache[cardFunction.id] = cardFunction;
  }

  static CardFunctionCacheResults getAll(Iterable<int> cardIds) {
    final results = CardFunctionCacheResults();
    for (var cardId in cardIds) {
      if (_cache.containsKey(cardId)) {
        results.cardFunctions[cardId] = _cache[cardId]!;
      } else {
        results.cardIds.add(cardId);
      }
    }
    return results;
  }

  static void setAll(Map<int, CardFunction> cardFunctions) {
    _cache.addAll(cardFunctions);
  }
}
