import 'package:flutter/material.dart';

enum ParallelType {
  universal(
    backgroundGradient: LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [
        Colors.black87,
        Colors.transparent,
      ],
    ),
  ),
  augencore(
    backgroundGradient: LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [
        Color.fromARGB(225, 255, 116, 50),
        Colors.transparent,
      ],
    ),
  ),
  earthen(
    backgroundGradient: LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [
        Color.fromARGB(225, 73, 188, 49),
        Colors.transparent,
      ],
    ),
  ),
  kathari(
    backgroundGradient: LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [
        Color.fromARGB(225, 30, 144, 221),
        Colors.transparent,
      ],
    ),
  ),
  marcolian(
    backgroundGradient: LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [
        Color.fromARGB(225, 226, 10, 26),
        Colors.transparent,
      ],
    ),
  ),
  shroud(
    backgroundGradient: LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [
        Color.fromARGB(225, 100, 56, 198),
        Colors.transparent,
      ],
    ),
  );

  const ParallelType({
    required this.backgroundGradient,
  });

  final Gradient backgroundGradient;
}

enum Paragon {
  // unknown
  unknown(
    name: "Unknown",
    parallel: ParallelType.universal,
    image: "assets/unknown_origin.png",
  ),

  // augencore
  jahn(
    name: 'Jahn',
    parallel: ParallelType.augencore,
    image: "/assets/paragons/paragon-jahn-chief-engineer.webp",
    description: 'Chief Engineer',
  ),
  arak(
    name: 'Arak',
    image: "/assets/paragons/paragon-arak-combat-overseer.webp",
    parallel: ParallelType.augencore,
    description: 'Combat Overseer',
  ),
  juggernautWorkshop(
    name: 'Juggernaut Workshop',
    parallel: ParallelType.augencore,
    image: "/assets/paragons/paragon-juggernaut-workshop.webp",
  ),

  // earthen
  gaffar(
    name: "Gaffar",
    parallel: ParallelType.earthen,
    image: "/assets/paragons/paragon-arbiter-of-earth.webp",
    description: "Arbiter of Earth",
  ),
  nehemiah(
    name: "Nehemiah",
    parallel: ParallelType.earthen,
    image: "/assets/paragons/paragon-nehemiah-defender-of-earth.webp",
    description: "Defender of Earth",
  ),
  shoshanna(
    name: "Shoshanna",
    parallel: ParallelType.earthen,
    image: "/assets/paragons/paragon-shoshanna-rebuilder-of-earth.webp",
    description: "Rebuilder of Earth",
  ),

  // kathari
  aetio(
    name: "Aetio",
    parallel: ParallelType.kathari,
    image: "/assets/paragons/paragon-aetio-exalted-hydrolist.webp",
    description: "Exalted Hydrolist",
  ),
  gnaeusValerusAlpha(
    name: "Gnaeus Valerus Alpha",
    parallel: ParallelType.kathari,
    image: "/assets/paragons/paragon-gnaeus-valerus-alpha.webp",
  ),
  scipiusMagnusAlpha(
    name: "Scipius Magnus Alpha",
    parallel: ParallelType.kathari,
    image: "/assets/paragons/paragon-scipius-magnus-alpha.webp",
  ),

  // marcolian
  lemieux(
    name: "Lemieux",
    parallel: ParallelType.marcolian,
    image: "/assets/paragons/paragon-lemieux-master-commando.webp",
    description: "Master Commando",
  ),
  catherine(
    name: "Catherine Lapointe",
    parallel: ParallelType.marcolian,
    image: "/assets/paragons/paragon-catherine-lapointe-mad-general.webp",
    description: "Mad General",
  ),
  armouredDivisionHQ(
    name: "Armored Division HQ",
    parallel: ParallelType.marcolian,
    image: "/assets/paragons/paragon-armoured-division-hq.webp",
  ),

  // shroud
  brand(
    name: "Brand",
    parallel: ParallelType.shroud,
    image: "/assets/paragons/paragon-brand-steward-eternal.webp",
    description: "Eternal Steward",
  ),
  newDawn(
    name: "New Dawn",
    parallel: ParallelType.shroud,
    image: "/assets/paragons/paragon-new-dawn.webp",
  ),
  niamh(
    name: "Niamh",
    parallel: ParallelType.shroud,
    image: "/assets/paragons/paragon-wielder-of-faith.webp",
    description: "Wielder of Faith",
  );

  final String name;
  final ParallelType parallel;
  final String image;
  final String? description;

  const Paragon({
    required this.name,
    required this.parallel,
    required this.image,
    this.description,
  });
}
