import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:parallel_stats/main.dart';
import 'package:parallel_stats/modal/match.dart';
import 'package:parallel_stats/tracker/match.dart';
import 'package:parallel_stats/tracker/match_model.dart';
import 'package:parallel_stats/tracker/paragon.dart';
import 'package:parallel_stats/tracker/paragon_stack.dart';
import 'package:parallel_stats/tracker/progress_card.dart';
import 'package:parallel_stats/tracker/quick_add.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Account extends StatefulWidget {
  final Paragon chosenParagon;

  const Account({
    super.key,
    required this.chosenParagon,
  });

  @override
  State<Account> createState() => _AccountState();
}

int paragonsCount = Paragon.values.length;
int gameResultCount = MatchResult.values.length;

class MatchAggregation {
  Map<ParallelType, Map<MatchResult, int>> matches = {};
}

class _AccountState extends State<Account> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  late int matchesPlayed;
  late int matchesWon;
  late int matchesLost;

  bool playerOne = true;
  // MatchAggregation matchAggregation = MatchAggregation();
  late MatchResults matchResults;
  late Future<List<MatchModel>> matchList;

  generateSampleMatches() {
    return List.generate(
      4,
      (index) {
        var result = MatchResult.values[Random().nextInt(gameResultCount)];
        var mmrDelta = Random().nextInt(25);
        if (result == MatchResult.disconnect || result == MatchResult.draw) {
          mmrDelta = 0;
        } else if (result == MatchResult.loss) {
          mmrDelta = -mmrDelta;
        }
        return MatchModel(
          paragon: Paragon.values[Random().nextInt(paragonsCount)],
          playerOne: Random().nextBool(),
          result: result,
          opponentUsername: 'Sample Opponent #$index',
          opponentParagon: Paragon.values[Random().nextInt(paragonsCount)],
          mmrDelta: mmrDelta,
        );
      },
    );
  }

  Future<List<MatchModel>> fetchMatches() async {
    var matches = await supabase
        .from(MatchModel.gamesTableName)
        .select()
        .order(
          "created_at",
          ascending: false,
        )
        .range(0, 10);
    return matches.map((game) => MatchModel.fromJson(game)).toList();
  }

  Future<MatchResults> fetchMatchResults() async {
    var results = await supabase.rpc('get_player_results');
    print(results);
    return MatchResults.fromJson(results);
  }

  @override
  initState() {
    if (supabase.auth.currentUser != null) {
      fetchMatchResults().then((results) {
        setState(() {
          matchResults = results;
        });
      });
      setState(() {
        matchList = fetchMatches();
      });
    } else {
      var matches = generateSampleMatches();
      for (var i = 0; i < matches; i++) {}
      matchList = Future.value(matches);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Session? session = InheritedSession.maybeOf(context)?.session;
    return SingleChildScrollView(
      child: Center(
        child: SizedBox(
          width: 720,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (session == null || session.isExpired)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'Sample data shown below.\nSign in to save your matches.',
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ProgressCard(
                    winRate: matchResults.winRate,
                    title: "Win Rate",
                  ),
                  ProgressCard(
                    winRate: matchResults.onThePlay.winRate,
                    title: "On the Play",
                  ),
                  ProgressCard(
                    winRate: matchResults.onTheDraw.winRate,
                    title: "On the Draw",
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('On the Play'),
                  ),
                  Tooltip(
                    message:
                        !playerOne ? 'You play first' : 'Opponent plays first',
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Switch(
                        value: !playerOne,
                        onChanged: (value) => setState(() {
                          playerOne = !value;
                        }),
                        trackColor: WidgetStateColor.resolveWith(
                          (states) => states.contains(WidgetState.selected)
                              ? Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                              : Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                        ),
                        thumbColor: WidgetStateColor.resolveWith(
                          (states) => states.contains(WidgetState.selected)
                              ? Theme.of(context).colorScheme.outline
                              : Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('On the Draw'),
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
                            var newMatch = MatchModel(
                              paragon: widget.chosenParagon,
                              opponentParagon:
                                  Paragon.values.byName(parallel.name),
                              playerOne: playerOne,
                              result: result,
                            );
                            if (session != null) {
                              var response = await supabase
                                  .from(MatchModel.gamesTableName)
                                  .insert(
                                [
                                  newMatch.toJson(),
                                ],
                                defaultToNull: false,
                              ).select();
                              newMatch = MatchModel.fromJson(response[0]);
                            }
                            setState(() {
                              // _listKey.currentState!.insertItem(0);
                              // matchList.insert(0, newMatch);
                            });
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
              FutureBuilder(
                future: matchList,
                builder: (context, snapshot) {
                  List<MatchModel> matchList;
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      return const CircularProgressIndicator();
                    case ConnectionState.done:
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        matchList = snapshot.data!;
                        break;
                      } else if (session == null || session.isExpired) {
                        matchList = generateSampleMatches();
                      } else {
                        matchList = [];
                        return const Padding(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ParagonStack(
                                game: MatchModel(
                                  paragon: Paragon.unknown,
                                  playerOne: true,
                                  result: MatchResult.draw,
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
                        );
                      }
                    default:
                      matchList = generateSampleMatches();
                  }
                  return AnimatedList(
                    key: _listKey,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(
                      top: 8,
                      left: 8,
                      right: 8,
                      bottom: 8,
                    ),
                    initialItemCount: matchList.length,
                    itemBuilder: (context, index, animation) {
                      final match = matchList[index];
                      return SlideTransition(
                        position: animation.drive(
                          Tween(
                            begin: Offset.zero,
                            end: Offset(MediaQuery.of(context).size.width, 0),
                          ),
                        ),
                        child: Match(
                          match: match,
                          onEdit: (BuildContext context) async {
                            var updatedMatch = await showDialog<MatchModel>(
                              context: context,
                              builder: (context) {
                                return MatchModal(
                                  match: match,
                                );
                              },
                            );
                            if (updatedMatch != null) {
                              if (updatedMatch.id != null &&
                                  session != null &&
                                  session.isExpired) {
                                await supabase
                                    .from(MatchModel.gamesTableName)
                                    .update(updatedMatch.toJson())
                                    .eq("id", match.id!);
                              }
                              setState(() {
                                matchList[index] = updatedMatch;
                              });
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
