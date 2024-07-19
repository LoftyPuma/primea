import 'package:flutter/material.dart';
import 'package:parallel_stats/main.dart';
import 'package:parallel_stats/tracker/game_model.dart';
import 'package:parallel_stats/tracker/paragon.dart';
import 'package:parallel_stats/tracker/paragon_stack.dart';
import 'package:parallel_stats/tracker/progress_card.dart';
import 'package:parallel_stats/tracker/quick_add.dart';

class Account extends StatefulWidget {
  final List<MatchModel> defaultMatches;
  final Paragon chosenParagon;
  const Account({
    super.key,
    this.defaultMatches = const [],
    required this.chosenParagon,
  });

  @override
  State<Account> createState() => _AccountState();
}

int paragonsCount = Paragon.values.length;
int gameResultCount = GameResult.values.length;

class _AccountState extends State<Account> {
  final List<MatchModel> gameList = [];
  // final List<GameModel> games = List.generate(
  //   2,
  //   (index) {
  //     var result = GameResult.values[Random().nextInt(gameResultCount)];
  //     var mmrDelta = Random().nextInt(25);
  //     if (result == GameResult.disconnect || result == GameResult.draw) {
  //       mmrDelta = 0;
  //     } else if (result == GameResult.loss) {
  //       mmrDelta = -mmrDelta;
  //     }
  //     return GameModel(
  //       paragon: Paragon.values[Random().nextInt(paragonsCount)],
  //       playerOne: Random().nextBool(),
  //       result: result,
  //       opponentUsername: 'Sample Opponent #$index',
  //       opponentParagon: Paragon.values[Random().nextInt(paragonsCount)],
  //       mmrDelta: mmrDelta,
  //       // dateTime: DateTime.now(),
  //       // primeEarned: 0.128,
  //       // keysActivated: [],
  //     );
  //   },
  // );

  bool playerOne = true;

  @override
  initState() {
    if (widget.defaultMatches.isNotEmpty) {
      gameList.addAll(widget.defaultMatches);
    } else {
      supabase
          .from(MatchModel.gamesTableName)
          .select()
          .order(
            "created_at",
            ascending: false,
          )
          .then((games) {
        setState(() {
          gameList.addAll(games.map((game) => MatchModel.fromJson(game)));
        });
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var overallWinRate =
        gameList.where((game) => game.result == GameResult.win).length /
            gameList.length;
    var onThePlayGames = gameList.where((game) => game.playerOne);
    var onTheDrawGames = gameList.where((game) => !game.playerOne);
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
                  ProgressCard(
                    winRate: overallWinRate,
                    title: "Overall Win Rate",
                  ),
                  if (onThePlayGames.isNotEmpty)
                    ProgressCard(
                      winRate: onThePlayWinRate,
                      title: "On the Play Win Rate",
                    ),
                  if (onTheDrawGames.isNotEmpty)
                    ProgressCard(
                      winRate: onTheDrawWinRate,
                      title: "On the Draw Win Rate",
                    ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('On the Draw'),
                  ),
                  Tooltip(
                    message:
                        playerOne ? 'You play first' : 'Opponent plays first',
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Switch(
                        value: playerOne,
                        onChanged: (value) => setState(() {
                          playerOne = value;
                        }),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('On the Play'),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                alignment: WrapAlignment.spaceAround,
                children: ParallelType.values
                    .where((parallel) => parallel != ParallelType.universal)
                    .map(
                      (parallel) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: QuickAddButton(
                          parallel: parallel,
                          onSelection: (parallel, result) async {
                            var response = await supabase
                                .from(MatchModel.gamesTableName)
                                .insert(
                                  MatchModel(
                                    paragon: widget.chosenParagon,
                                    opponentParagon:
                                        Paragon.values.byName(parallel.name),
                                    playerOne: playerOne,
                                    result: result,
                                  ).toJson(),
                                  defaultToNull: false,
                                )
                                .select();
                            print(response);
                          },
                        ),
                      ),
                    )
                    .toList(),
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
                itemCount: gameList.length,
                itemBuilder: (context, index) {
                  final game = gameList[index];
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
                },
              ),
              if (gameList.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ParagonStack(
                        game: MatchModel(
                          paragon: Paragon.unknown,
                          playerOne: true,
                          result: GameResult.draw,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Add a match to get started!'),
                          ],
                        ),
                      ),
                      Tooltip(
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
