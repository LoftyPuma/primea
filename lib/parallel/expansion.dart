enum Expansion {
  baseSet,
  battlepass,
  planetfall,
}

extension ExpansionExtension on Expansion {
  String get value {
    switch (this) {
      case Expansion.baseSet:
        return 'Base Set';
      case Expansion.planetfall:
        return 'Planetfall';
      case Expansion.battlepass:
        return 'Battlepass';
    }
  }

  static Expansion fromString(String expansion) {
    switch (expansion) {
      case 'Base Set':
        return Expansion.baseSet;
      case 'Planetfall':
        return Expansion.planetfall;
      case 'Battlepass':
        return Expansion.battlepass;
      default:
        throw Exception('Unknown Expansion: $expansion');
    }
  }
}
