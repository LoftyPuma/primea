import 'dart:math';

import 'package:flutter/material.dart';
import 'package:parallel_stats/tracker/game_model.dart';
import 'package:parallel_stats/tracker/paragon.dart';
import 'package:parallel_stats/tracker/paragon_stack.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

int paragonsCount = Paragon.values.length;
int gameResultCount = GameResult.values.length;

class _AccountState extends State<Account> {
  final List<GameModel> games = List.generate(
    8,
    (index) => GameModel(
      paragon: Paragon.values[Random().nextInt(paragonsCount)],
      playerOne: true,
      result: GameResult.values[Random().nextInt(gameResultCount)],
      dateTime: DateTime.now(),
      opponentUsername: 'Sparrows___',
      opponentParagon: Paragon.values[Random().nextInt(paragonsCount)],
      // mmrDelta: 18,
      // primeEarned: 0.128,
      keysActivated: [],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: games.map((game) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ParagonStack(game: game),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(game.opponentUsername ?? 'Unknown Opponent'),
                  if (game.mmrDelta != null) Text("${game.mmrDelta} MMR"),
                ],
              ),
            ),
            Tooltip(
              message: game.result.tooltip,
              child: Icon(
                game.result.icon,
                color: game.result.color,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
