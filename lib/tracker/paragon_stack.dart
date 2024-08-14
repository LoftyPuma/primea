import 'package:flutter/material.dart';
import 'package:primea/model/match/match_model.dart';
import 'package:primea/tracker/paragon_avatar.dart';

class ParagonStack extends StatelessWidget {
  final MatchModel match;

  const ParagonStack({
    super.key,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 155,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
            left: 64,
            child: ParagonAvatar(
              paragon: match.opponentParagon,
            ),
          ),
          ParagonAvatar(
            paragon: match.paragon,
            deck: match.deck,
          ),
        ],
      ),
    );
  }
}
