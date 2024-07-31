import 'package:flutter/material.dart';

enum ParallelType {
  universal(color: Colors.black87),
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
    title: 'Jahn',
    parallel: ParallelType.augencore,
    image: "assets/paragons/paragon-jahn-chief-engineer.webp",
    description: 'Chief Engineer',
  ),
  arak(
    title: 'Arak',
    image: "assets/paragons/paragon-arak-combat-overseer.webp",
    parallel: ParallelType.augencore,
    description: 'Combat Overseer',
  ),
  juggernautWorkshop(
    title: 'Juggernaut Workshop',
    parallel: ParallelType.augencore,
    image: "assets/paragons/paragon-juggernaut-workshop.webp",
  ),

  // earthen
  earthen(
    title: "",
    parallel: ParallelType.earthen,
  ),
  gaffar(
    title: "Gaffar",
    parallel: ParallelType.earthen,
    image: "assets/paragons/paragon-arbiter-of-earth.webp",
    description: "Arbiter of Earth",
  ),
  nehemiah(
    title: "Nehemiah",
    parallel: ParallelType.earthen,
    image: "assets/paragons/paragon-nehemiah-defender-of-earth.webp",
    description: "Defender of Earth",
  ),
  shoshanna(
    title: "Shoshanna",
    parallel: ParallelType.earthen,
    image: "assets/paragons/paragon-shoshanna-rebuilder-of-earth.webp",
    description: "Rebuilder of Earth",
  ),

  // kathari
  kathari(
    title: "",
    parallel: ParallelType.kathari,
  ),
  aetio(
    title: "Aetio",
    parallel: ParallelType.kathari,
    image: "assets/paragons/paragon-aetio-exalted-hydrolist.webp",
    description: "Exalted Hydrolist",
  ),
  gnaeusValerusAlpha(
    title: "Gnaeus Valerus Alpha",
    parallel: ParallelType.kathari,
    image: "assets/paragons/paragon-gnaeus-valerus-alpha.webp",
  ),
  scipiusMagnusAlpha(
    title: "Scipius Magnus Alpha",
    parallel: ParallelType.kathari,
    image: "assets/paragons/paragon-scipius-magnus-alpha.webp",
  ),

  // marcolian
  marcolian(
    title: "",
    parallel: ParallelType.marcolian,
  ),
  lemieux(
    title: "Lemieux",
    parallel: ParallelType.marcolian,
    image: "assets/paragons/paragon-lemieux-master-commando.webp",
    description: "Master Commando",
  ),
  catherine(
    title: "Catherine Lapointe",
    parallel: ParallelType.marcolian,
    image: "assets/paragons/paragon-catherine-lapointe-mad-general.webp",
    description: "Mad General",
  ),
  armouredDivisionHQ(
    title: "Armored Division HQ",
    parallel: ParallelType.marcolian,
    image: "assets/paragons/paragon-armoured-division-hq.webp",
  ),

  // shroud
  shroud(
    title: "",
    parallel: ParallelType.shroud,
  ),
  brand(
    title: "Brand",
    parallel: ParallelType.shroud,
    image: "assets/paragons/paragon-brand-steward-eternal.webp",
    description: "Eternal Steward",
  ),
  newDawn(
    title: "New Dawn",
    parallel: ParallelType.shroud,
    image: "assets/paragons/paragon-new-dawn.webp",
  ),
  niamh(
    title: "Niamh",
    parallel: ParallelType.shroud,
    image: "assets/paragons/paragon-wielder-of-faith.webp",
    description: "Wielder of Faith",
  );

  final String title;
  final ParallelType parallel;
  final String? image;
  final String? description;

  const Paragon({
    required this.title,
    required this.parallel,
    this.image,
    this.description,
  });
}
