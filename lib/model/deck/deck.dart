import 'package:primea/main.dart';
import 'package:primea/model/deck/card_function.dart';
import 'package:primea/model/deck/card_type.dart';
import 'package:primea/tracker/paragon.dart';

class Deck {
  static const String deckTableName = 'decks';
  static final RegExp deckCodePattern = RegExp(
    r'^((?<count>\dx|)(?<card>CB-\d+)(?<rarity>:\w+|)(,|))+$',
  );

  String id;
  String name;
  Map<CardFunction, int> cards;
  DateTime createdAt;
  DateTime updatedAt;

  CardFunction get paragon => cards.keys.singleWhere(
        (card) => card.cardType == CardType.paragon,
      );

  bool get isUniversal => cards.keys
      .where((card) => card.cardType != CardType.paragon)
      .every((card) => card.parallel == ParallelType.universal);

  Deck({
    required this.id,
    required this.name,
    required Iterable<CardFunction> cards,
    required this.createdAt,
    required this.updatedAt,
  }) : cards = cards.fold(
          {},
          (acc, card) {
            acc[card] = (acc[card] ?? 0) + 1;
            return acc;
          },
        );

  Deck.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        createdAt = DateTime.parse(json['created_at']),
        updatedAt = DateTime.parse(json['updated_at']),
        cards = {
          for (var card in json['cards'])
            CardFunction.fromJson(card['id']): card['count'],
        };

  static Future<Deck> byID(String id) async {
    final deckJson =
        await supabase.from(deckTableName).select().eq('id', id).single();

    final cardFunctionsJson = await supabase
        .from(CardFunction.cardFunctionTableName)
        .select()
        .inFilter('id', deckJson['cards']);

    final cardFunctions = Map.fromEntries(cardFunctionsJson.map(
      (json) => MapEntry(
        json['id'] as int,
        CardFunction.fromJson(json),
      ),
    ));

    final cards = deckJson['cards'] as List;
    final cardList = cards.map((card) => cardFunctions[card]!);

    final deck = Deck(
      id: id,
      name: deckJson['name'],
      cards: cardList,
      createdAt: DateTime.parse(deckJson['created_at']),
      updatedAt: DateTime.parse(deckJson['updated_at']),
    );
    return deck;
  }

  String toCode() {
    final Iterable<String> cardCodes = cards.entries.map((entry) {
      final card = entry.key;
      final count = entry.value;
      return count == 1
          ? "${CardFunction.cardPrefix}${card.id}"
          : '${count}x${CardFunction.cardPrefix}${card.id}';
    });

    return cardCodes.join(',');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'deck': cards.keys.map((card) {
        final count = cards[card];
        return '${count}x${card.id}';
      }).join(','),
    };
  }
}
