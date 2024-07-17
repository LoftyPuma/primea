enum Faction {
  augencore,
  earthen,
  kathari,
  marcolian,
  shroud,
  universal,
  unknownOrigins,
}

extension FactionExtension on Faction {
  String get value {
    switch (this) {
      case Faction.augencore:
        return 'augencore';
      case Faction.earthen:
        return 'earthen';
      case Faction.kathari:
        return 'kathari';
      case Faction.marcolian:
        return 'marcolian';
      case Faction.shroud:
        return 'shroud';
      case Faction.universal:
        return 'universal';
      case Faction.unknownOrigins:
        return 'uo';
    }
  }

  static Faction fromString(String faction) {
    switch (faction.toLowerCase()) {
      case 'augencore':
        return Faction.augencore;
      case 'earthen':
        return Faction.earthen;
      case 'kathari':
        return Faction.kathari;
      case 'marcolian':
        return Faction.marcolian;
      case 'shroud':
        return Faction.shroud;
      case 'universal':
        return Faction.universal;
      case 'uo':
        return Faction.unknownOrigins;
      default:
        throw Exception('Unknown Faction: $faction');
    }
  }
}
