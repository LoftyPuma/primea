import 'package:parallel_stats/model/deck/card_expansion.dart';
import 'package:parallel_stats/model/deck/card_rarity.dart';
import 'package:parallel_stats/model/deck/card_subtype.dart';
import 'package:parallel_stats/model/deck/card_type.dart';
import 'package:parallel_stats/tracker/paragon.dart';

class CardFunction {
  static const String cardFunctionTableName = 'card_functions';

  int id;
  String basename;
  String title;
  ParallelType parallel;
  CardRarity rarity;
  String functionText;
  String flavourText;
  String? passiveAbility;
  int cost;
  int attack;
  int health;
  CardType cardType;
  CardSubtype? subtype;
  CardExpansion expansion;

  CardFunction({
    required this.id,
    required this.basename,
    required this.title,
    required this.parallel,
    required this.rarity,
    required this.functionText,
    required this.flavourText,
    this.passiveAbility,
    required this.cost,
    required this.attack,
    required this.health,
    required this.cardType,
    this.subtype,
    required this.expansion,
  });

  CardFunction.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        basename = json['basename'],
        title = json['title'],
        parallel = ParallelType.values.byName(json['parallel']),
        rarity = CardRarity.values.byName(json['rarity']),
        functionText = json['function_text'],
        flavourText = json['flavour_text'],
        passiveAbility = json['passive_ability'],
        cost = json['cost'],
        attack = json['attack'],
        health = json['health'],
        cardType = CardType.values.byName(json['card_type']),
        subtype = json['subtype'] != null
            ? CardSubtype.values.byName(json['subtype'])
            : null,
        expansion = CardExpansion.values.byName(json['expansion']);
}
