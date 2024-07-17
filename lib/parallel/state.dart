enum CardState {
  none,
  day,
  night,
  active,
  inactive,
  heads,
  tails,
  earth,
  mars,
  blue,
  orange,
  dark,
  light,
  effect,
  unit,
}

extension CardStateExtension on CardState {
  String get value {
    switch (this) {
      case CardState.none:
        return 'no';
      case CardState.day:
        return 'da';
      case CardState.night:
        return 'ni';
      case CardState.active:
        return 'ac';
      case CardState.inactive:
        return 'in';
      case CardState.heads:
        return 'he';
      case CardState.tails:
        return 'ta';
      case CardState.earth:
        return 'ea';
      case CardState.mars:
        return 'ma';
      case CardState.blue:
        return 'bl';
      case CardState.orange:
        return 'or';
      case CardState.dark:
        return 'dr';
      case CardState.light:
        return 'li';
      case CardState.effect:
        return 'ef';
      case CardState.unit:
        return 'un';
    }
  }

  static CardState fromString(String state) {
    switch (state) {
      case 'no':
        return CardState.none;
      case 'da':
        return CardState.day;
      case 'ni':
        return CardState.night;
      case 'ac':
        return CardState.active;
      case 'in':
        return CardState.inactive;
      case 'he':
        return CardState.heads;
      case 'ta':
        return CardState.tails;
      case 'ea':
        return CardState.earth;
      case 'ma':
        return CardState.mars;
      case 'bl':
        return CardState.blue;
      case 'or':
        return CardState.orange;
      case 'dr':
        return CardState.dark;
      case 'li':
        return CardState.light;
      case 'ef':
        return CardState.effect;
      case 'un':
        return CardState.unit;
      default:
        throw Exception('Unknown CardState: $state');
    }
  }
}
