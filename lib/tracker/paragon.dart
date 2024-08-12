import 'package:flutter/material.dart';

enum ParallelType {
  universal(color: Colors.white70),
  augencore(color: Color(0xFFFF7432)),
  earthen(color: Color(0xFF49BC31)),
  kathari(color: Color(0xFF1E90DD)),
  marcolian(color: Color(0xFFE20A1A)),
  shroud(color: Color(0xFF6438C6));

  const ParallelType({
    required this.color,
  });

  final Color color;

  Paragon get paragon {
    switch (this) {
      case ParallelType.augencore:
        return Paragon.augencore;
      case ParallelType.earthen:
        return Paragon.earthen;
      case ParallelType.kathari:
        return Paragon.kathari;
      case ParallelType.marcolian:
        return Paragon.marcolian;
      case ParallelType.shroud:
        return Paragon.shroud;
      default:
        return Paragon.unknown;
    }
  }
}

enum Paragon {
  // unknown
  unknown(
    title: "Unknown",
    parallel: ParallelType.universal,
    image: "assets/unknown_origin.png",
  ),

  // augencore
  augencore(
    title: "",
    parallel: ParallelType.augencore,
  ),
  jahn(
    cardID: 9,
    title: 'Jahn',
    parallel: ParallelType.augencore,
    image: "assets/paragons/paragon-jahn-chief-engineer.webp",
    art: "assets/paragons/art/Jahn.webp",
    description: 'Chief Engineer',
  ),
  arak(
    cardID: 21,
    title: 'Arak',
    image: "assets/paragons/paragon-arak-combat-overseer.webp",
    art: "assets/paragons/art/Arak.webp",
    parallel: ParallelType.augencore,
    description: 'Combat Overseer',
  ),
  juggernautWorkshop(
    cardID: 376,
    title: 'Juggernaut Workshop',
    parallel: ParallelType.augencore,
    image: "assets/paragons/paragon-juggernaut-workshop.webp",
    art: "assets/paragons/art/Juggernaut Workshop.webp",
  ),

  // earthen
  earthen(
    title: "",
    parallel: ParallelType.earthen,
  ),
  gaffar(
    cardID: 62,
    title: "Gaffar",
    parallel: ParallelType.earthen,
    image: "assets/paragons/paragon-arbiter-of-earth.webp",
    art: "assets/paragons/art/Gaffar.webp",
    description: "Arbiter of Earth",
  ),
  nehemiah(
    cardID: 390,
    title: "Nehemiah",
    parallel: ParallelType.earthen,
    image: "assets/paragons/paragon-nehemiah-defender-of-earth.webp",
    art: "assets/paragons/art/Nehemiah.webp",
    description: "Defender of Earth",
  ),
  shoshanna(
    cardID: 389,
    title: "Shoshanna",
    parallel: ParallelType.earthen,
    image: "assets/paragons/paragon-shoshanna-rebuilder-of-earth.webp",
    art: "assets/paragons/art/Shoshanna.webp",
    description: "Rebuilder of Earth",
  ),

  // kathari
  kathari(
    title: "",
    parallel: ParallelType.kathari,
  ),
  aetio(
    cardID: 375,
    title: "Aetio",
    parallel: ParallelType.kathari,
    image: "assets/paragons/paragon-aetio-exalted-hydrolist.webp",
    art: "assets/paragons/art/Aetio.webp",
    description: "Exalted Hydrolist",
  ),
  gnaeusValerusAlpha(
    cardID: 371,
    title: "Gnaeus Valerus Alpha",
    parallel: ParallelType.kathari,
    image: "assets/paragons/paragon-gnaeus-valerus-alpha.webp",
    art: "assets/paragons/art/Gnaeus.webp",
  ),
  scipiusMagnusAlpha(
    cardID: 373,
    title: "Scipius Magnus Alpha",
    parallel: ParallelType.kathari,
    image: "assets/paragons/paragon-scipius-magnus-alpha.webp",
    art: "assets/paragons/art/Scipius.webp",
  ),

  // marcolian
  marcolian(
    title: "",
    parallel: ParallelType.marcolian,
  ),
  lemieux(
    cardID: 171,
    title: "Lemieux",
    parallel: ParallelType.marcolian,
    image: "assets/paragons/paragon-lemieux-master-commando.webp",
    art: "assets/paragons/art/Lemieux.webp",
    description: "Master Commando",
  ),
  catherine(
    cardID: 197,
    title: "Catherine Lapointe",
    parallel: ParallelType.marcolian,
    image: "assets/paragons/paragon-catherine-lapointe-mad-general.webp",
    art: "assets/paragons/art/Catherine.webp",
    description: "Mad General",
  ),
  armouredDivisionHQ(
    cardID: 277,
    title: "Armored Division HQ",
    parallel: ParallelType.marcolian,
    image: "assets/paragons/paragon-armoured-division-hq.webp",
    art: "assets/paragons/art/Armoured Division HQ.webp",
  ),

  // shroud
  shroud(
    title: "",
    parallel: ParallelType.shroud,
  ),
  brand(
    cardID: 378,
    title: "Brand",
    parallel: ParallelType.shroud,
    image: "assets/paragons/paragon-brand-steward-eternal.webp",
    art: "assets/paragons/art/Brand.webp",
    description: "Eternal Steward",
  ),
  newDawn(
    cardID: 380,
    title: "New Dawn",
    parallel: ParallelType.shroud,
    image: "assets/paragons/paragon-new-dawn.webp",
    art: "assets/paragons/art/New Dawn.webp",
  ),
  niamh(
    cardID: 379,
    title: "Niamh",
    parallel: ParallelType.shroud,
    image: "assets/paragons/paragon-niamh-wielder-of-faith.webp",
    art: "assets/paragons/art/Niamh.webp",
    description: "Wielder of Faith",
  );

  final String title;
  final ParallelType parallel;
  final String? image;
  final String? art;
  final String? description;
  final int? cardID;

  const Paragon({
    required this.title,
    required this.parallel,
    this.cardID,
    this.image,
    this.art,
    this.description,
  });

  static Paragon fromCardID(int cardID) {
    switch (cardID) {
      case 9:
        return Paragon.jahn;
      case 21:
        return Paragon.arak;
      case 62:
        return Paragon.gaffar;
      case 171:
        return Paragon.lemieux;
      case 197:
        return Paragon.catherine;
      case 277:
        return Paragon.armouredDivisionHQ;
      case 371:
        return Paragon.gnaeusValerusAlpha;
      case 373:
        return Paragon.scipiusMagnusAlpha;
      case 375:
        return Paragon.aetio;
      case 376:
        return Paragon.juggernautWorkshop;
      case 378:
        return Paragon.brand;
      case 379:
        return Paragon.niamh;
      case 380:
        return Paragon.newDawn;
      case 389:
        return Paragon.shoshanna;
      case 390:
        return Paragon.nehemiah;
      default:
        return Paragon.unknown;
    }
  }
}
