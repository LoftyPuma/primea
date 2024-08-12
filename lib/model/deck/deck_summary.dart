import 'package:primea/model/deck/card_type.dart';
import 'package:primea/model/deck/deck.dart';
import 'package:primea/tracker/paragon.dart';

class DeckSummary {
  int paragonCount = 0;
  int effectCount = 0;
  int relicCount = 0;
  int upgradeCount = 0;
  int unitCount = 0;
  int splitUnitEffectCount = 0;
  Map<ParallelType, int> parallelTypeCount = {};

  DeckSummary({
    required Deck deck,
  }) {
    deck.cards.forEach((card, count) {
      switch (card.cardType) {
        case CardType.paragon:
          paragonCount += count;
          // Paragon cards are not counted in the parallel type count
          return;
        case CardType.effect:
          effectCount += count;
          break;
        case CardType.relic:
          relicCount += count;
          break;
        case CardType.upgrade:
          upgradeCount += count;
          break;
        case CardType.unit:
          unitCount += count;
          break;
        case CardType.splitUnitEffect:
          splitUnitEffectCount += count;
          break;
      }

      parallelTypeCount[card.parallel] =
          (parallelTypeCount[card.parallel] ?? 0) + count;
    });
  }
}
