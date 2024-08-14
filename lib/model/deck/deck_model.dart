import 'package:primea/main.dart';
import 'package:primea/model/deck/deck.dart';
import 'package:primea/model/deck/card_function.dart';

class DeckModel {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<int> cards;

  const DeckModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.cards,
  });

  DeckModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        createdAt = DateTime.parse(json['created_at']),
        updatedAt = DateTime.parse(json['updated_at']),
        cards = List<int>.from(json['cards']);

  static Future<DeckModel> fromCode(
    String name,
    String code, {
    String? id,
  }) async {
    final List<int> parsedCodes = List.empty(growable: true);
    final List<String> deck = code.split(',');

    for (var card in deck) {
      final parts = card.split(CardFunction.cardPrefix);
      final count = parts[0].isEmpty ? 1 : int.parse(parts[0].substring(0, 1));
      final cardId = int.parse(parts[1].split(':')[0]);
      parsedCodes.addAll(List.filled(count, cardId));
    }
    if (id == null) {
      return DeckModel.fromJson(
        await supabase
            .from(Deck.deckTableName)
            .insert({
              'name': name,
              'cards': parsedCodes,
            })
            .select()
            .single(),
      );
    } else {
      return DeckModel.fromJson(
        await supabase
            .from(Deck.deckTableName)
            .update({
              'name': name,
              'cards': parsedCodes,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('id', id)
            .select()
            .single(),
      );
    }
  }

  static Future<DeckModel> fromID(String id) async {
    final deckJson =
        await supabase.from(Deck.deckTableName).select().eq('id', id).single();

    return DeckModel.fromJson(deckJson);
  }

  static Future<Iterable<DeckModel>> fetchAll() async {
    final deckJson = await supabase
        .from(Deck.deckTableName)
        .select()
        .order('updated_at', ascending: false);

    return deckJson.map((json) => DeckModel.fromJson(json));
  }

  static Future<Iterable<Deck>> toDeckList(
    Iterable<DeckModel> deckModels,
  ) async {
    final cardIds = deckModels.fold(
      <int>{},
      (acc, deckModel) => acc..addAll(deckModel.cards),
    );
    final cardFunctionsJson = await supabase
        .from(CardFunction.cardFunctionTableName)
        .select()
        .inFilter('id', cardIds.toList());

    final cardFunctions = Map.fromEntries(cardFunctionsJson.map(
      (json) => MapEntry(
        json['id'] as int,
        CardFunction.fromJson(json),
      ),
    ));

    return deckModels.map(
      (deckModel) => Deck(
        id: deckModel.id,
        name: deckModel.name,
        cards: deckModel.cards.map((card) => cardFunctions[card]!),
        createdAt: deckModel.createdAt,
        updatedAt: deckModel.updatedAt,
      ),
    );
  }

  Future<Deck> toDeck() async {
    final cardFunctionsJson = await supabase
        .from(CardFunction.cardFunctionTableName)
        .select()
        .inFilter('id', cards);

    final cardFunctions = Map.fromEntries(cardFunctionsJson.map(
      (json) => MapEntry(
        json['id'] as int,
        CardFunction.fromJson(json),
      ),
    ));

    final cardList = cards.map((card) => cardFunctions[card]!);

    return Deck(
      id: id,
      name: name,
      cards: cardList,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  String toCode() {
    final cardCounts = <int, int>{};
    for (var card in cards) {
      cardCounts.update(card, (value) => value + 1, ifAbsent: () => 1);
    }

    final cardCodes = cardCounts.entries.map((entry) {
      final card = entry.key;
      final count = entry.value;
      return count == 1
          ? "${CardFunction.cardPrefix}$card"
          : '${count}x${CardFunction.cardPrefix}$card';
    });

    return cardCodes.join(',');
  }

  @override
  String toString() {
    return 'DeckModel(name: $name, createdAt: $createdAt, updatedAt: $updatedAt, cards: $cards)';
  }
}
