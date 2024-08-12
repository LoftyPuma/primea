enum CardExpansion {
  baseSet,
  battlepass,
  planetfall;

  String get title {
    switch (this) {
      case CardExpansion.baseSet:
        return 'Base Set';
      case CardExpansion.battlepass:
        return 'Battlepass';
      case CardExpansion.planetfall:
        return 'Planetfall';
    }
  }

  static fromName(String name) {
    switch (name) {
      case 'Base Set':
        return CardExpansion.baseSet;
      case 'Battlepass':
        return CardExpansion.battlepass;
      case 'Planetfall':
        return CardExpansion.planetfall;
      default:
        throw Exception('Unknown expansion: $name');
    }
  }
}
