import 'package:parallel_stats/main.dart';
import 'package:parallel_stats/model/deck/card_function.dart';

class Deck {
  static const String deckTableName = 'decks';
  static final RegExp deckCodePattern = RegExp(
    r'^((?<count>\dx|)(?<card>CB-\d+)(?<rarity>:\w+|)(,|))+$',
  );

  String name;
  Map<CardFunction, int> cards;

  Deck({
    required this.name,
    required List<CardFunction> cards,
  }) : cards = {for (var card in cards) card: 1};

  Deck.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        cards = {
          for (var card in json['cards'])
            CardFunction.fromJson(card['id']): card['count'],
        };

  static Future<Deck> fromString(String name, String deckCode) async {
    final List<int> parsedCode = List.empty(growable: true);
    final List<String> deck = deckCode.split(',');

    for (var card in deck) {
      final parts = card.split('CB-');
      final count = parts[0].isEmpty ? 1 : int.parse(parts[0].substring(0, 1));
      final cardId = int.parse(parts[1].split(':')[0]);
      parsedCode.addAll(List.filled(count, cardId));
    }
    final deckResponse = await supabase.from(deckTableName).insert({
      'name': name,
      'cards': parsedCode,
    }).select('name,unnest(cards), ${CardFunction.cardFunctionTableName}(id)');
    print(deckResponse);

    return Deck(name: "", cards: []);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'deck': cards.keys.map((card) {
        final count = cards[card];
        return '${count}x${card.id}';
      }).join(','),
    };
  }
}
