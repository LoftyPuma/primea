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
    (index) {
      var result = GameResult.values[Random().nextInt(gameResultCount)];
      var mmrDelta = Random().nextInt(25);
      if (result == GameResult.disconnect || result == GameResult.draw) {
        mmrDelta = 0;
      } else if (result == GameResult.loss) {
        mmrDelta = -mmrDelta;
      }
      return GameModel(
        paragon: Paragon.values[Random().nextInt(paragonsCount)],
        playerOne: Random().nextBool(),
        result: result,
        opponentUsername: 'Sample Opponent #$index',
        opponentParagon: Paragon.values[Random().nextInt(paragonsCount)],
        mmrDelta: mmrDelta,
        // dateTime: DateTime.now(),
        // primeEarned: 0.128,
        // keysActivated: [],
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    var overallWinRate =
        games.where((game) => game.result == GameResult.win).length /
            games.length;
    var onThePlayGames = games.where((game) => game.playerOne);
    var onTheDrawGames = games.where((game) => !game.playerOne);
    var onThePlayWinRate =
        onThePlayGames.where((game) => game.result == GameResult.win).length /
            onThePlayGames.length;
    var onTheDrawWinRate =
        onTheDrawGames.where((game) => game.result == GameResult.win).length /
            onTheDrawGames.length;
    return SingleChildScrollView(
      child: Center(
        child: SizedBox(
          width: 720,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SizedBox.square(
                      dimension: 200,
                      child: Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(children: [
                            TextSpan(
                              text:
                                  '${(overallWinRate * 100).toStringAsFixed(0)}%\n',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                            TextSpan(
                              text: 'Overall Win Rate',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ),
                  if (onThePlayGames.isNotEmpty)
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SizedBox.square(
                        dimension: 200,
                        child: Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(children: [
                              TextSpan(
                                text:
                                    '${(onThePlayWinRate * 100).toStringAsFixed(0)}%\n',
                                style:
                                    Theme.of(context).textTheme.displayMedium,
                              ),
                              TextSpan(
                                text: 'On the Play Win Rate',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ]),
                          ),
                        ),
                      ),
                    ),
                  if (onTheDrawGames.isNotEmpty)
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SizedBox.square(
                        dimension: 200,
                        child: Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(children: [
                              TextSpan(
                                text:
                                    '${(onTheDrawWinRate * 100).toStringAsFixed(0)}%\n',
                                style:
                                    Theme.of(context).textTheme.displayMedium,
                              ),
                              TextSpan(
                                text: 'On the Draw Win Rate',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ]),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(
                  top: 8,
                  left: 8,
                  right: 8,
                  bottom: 8,
                ),
                itemCount: games.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return OutlinedButton.icon(
                        onPressed: () {},
                        label: const Text('Add Match'),
                        icon: const Icon(Icons.add),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(72),
                        ));
                  } else {
                    final game = games[index - 1];
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ParagonStack(game: game),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Tooltip(
                            message:
                                game.playerOne ? 'On the Play' : 'On the Draw',
                            child: Icon(
                              game.playerOne
                                  ? Icons.swipe_up
                                  : Icons.sim_card_download,
                              color: game.playerOne
                                  ? Colors.yellow[600]
                                  : Colors.cyan,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(game.opponentUsername ?? 'Unknown Opponent'),
                              if (game.mmrDelta != null)
                                Text("${game.mmrDelta} MMR"),
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
                  }
                },
              ),
              if (games.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ParagonStack(
                        game: GameModel(
                          paragon: Paragon.unknown,
                          playerOne: true,
                          result: GameResult.draw,
                        ),
                      ),
                      const Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Add a match to get started!'),
                          ],
                        ),
                      ),
                      const Tooltip(
                        message: "TBD",
                        child: Icon(
                          Icons.question_mark_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
