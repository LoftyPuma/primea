import 'package:primea/main.dart';
import 'package:primea/model/deck/card_function.dart';
import 'package:primea/model/deck/card_type.dart';
import 'package:primea/tracker/paragon.dart';

class Deck {
  static const String deckTableName = 'decks';
  static final RegExp deckCodePattern = RegExp(
    r'^((?<count>\dx|)(?<card>CB-\d+)(?<rarity>:\w+|)(,|))+$',
  );

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
      : name = json['name'],
        createdAt = DateTime.parse(json['created_at']),
        updatedAt = DateTime.parse(json['updated_at']),
        cards = {
          for (var card in json['cards'])
            CardFunction.fromJson(card['id']): card['count'],
        };

  static Future<Deck> byName(String name) async {
    final deckJson =
        await supabase.from(deckTableName).select().eq('name', name).single();

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
      name: name,
      cards: cardList,
      createdAt: DateTime.parse(deckJson['created_at']),
      updatedAt: DateTime.parse(deckJson['updated_at']),
    );
    return deck;
  }

  // static Future<Deck> fromString(String name, String deckCode) async {
  //   final List<int> parsedCodes = List.empty(growable: true);
  //   final List<String> deck = deckCode.split(',');

  //   for (var card in deck) {
  //     final parts = card.split(CardFunction.cardPrefix);
  //     final count = parts[0].isEmpty ? 1 : int.parse(parts[0].substring(0, 1));
  //     final cardId = int.parse(parts[1].split(':')[0]);
  //     parsedCodes.addAll(List.filled(count, cardId));
  //   }
  //   await supabase.from(deckTableName).insert({
  //     'name': name,
  //     'cards': parsedCodes,
  //   });

  //   final cardFunctionsJson = await supabase
  //       .from(CardFunction.cardFunctionTableName)
  //       .select()
  //       .inFilter('id', parsedCodes);

  //   final cardFunctions =
  //       cardFunctionsJson.map((json) => CardFunction.fromJson(json));

  //   return Deck(name: name, cards: cardFunctions);
  // }

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
      'name': name,
      'deck': cards.keys.map((card) {
        final count = cards[card];
        return '${count}x${card.id}';
      }).join(','),
    };
  }
}
