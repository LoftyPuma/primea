import 'package:flutter/material.dart';
import 'package:parallel_stats/tracker/match_model.dart';
import 'package:parallel_stats/tracker/paragon_avatar.dart';

class ParagonStack extends StatelessWidget {
  final MatchModel game;

  const ParagonStack({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 172,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
            left: 64,
            child: ParagonAvatar(paragon: game.opponentParagon),
          ),
          ParagonAvatar(paragon: game.paragon),
        ],
      ),
    );
  }
}
