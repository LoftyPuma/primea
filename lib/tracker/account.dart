import 'dart:async';

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

class _AccountState extends State<Account> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  bool playerOne = true;
  MatchResults matchResults = MatchResults();
  List<MatchModel> matchList = List.empty(growable: true);
  late Future<List<MatchModel>> matchListFuture;

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
    return MatchResults.fromJson(results);
  }

  @override
  initState() {
    fetchMatchResults().then((results) {
      setState(() {
        matchResults = results;
      });
    });

    setState(() {
      matchListFuture = fetchMatches();
    });

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
                            var response = await supabase
                                .from(MatchModel.gamesTableName)
                                .insert(
                              [
                                MatchModel(
                                  paragon: widget.chosenParagon,
                                  opponentParagon:
                                      Paragon.values.byName(parallel.name),
                                  playerOne: playerOne,
                                  result: result,
                                ).toJson(),
                              ],
                              defaultToNull: false,
                            ).select();
                            var newMatch = MatchModel.fromJson(response[0]);
                            setState(() {
                              matchList.insert(0, newMatch);
                              matchResults.recordMatch(newMatch);
                            });
                            _listKey.currentState!.insertItem(
                              0,
                              duration: const Duration(milliseconds: 250),
                            );
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
              FutureBuilder(
                future: matchListFuture,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      return const CircularProgressIndicator();
                    case ConnectionState.done:
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        for (var match in snapshot.data!.reversed) {
                          if (!matchList.contains(match)) {
                            matchList.insert(0, match);
                            matchResults.recordMatch(match);
                          }
                        }
                        break;
                      }
                      continue noData;
                    noData:
                    default:
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
                      return SizeTransition(
                        sizeFactor: animation,
                        child: Match(
                          match: match,
                          onEdit: (context) async {
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
                          onDelete: (context) async {
                            var removed = matchList.removeAt(index);

                            var response = await supabase
                                .from(MatchModel.gamesTableName)
                                .delete()
                                .eq("id", removed.id!)
                                .select();
                            print(response);
                            setState(() {
                              matchResults.removeMatch(removed);
                            });
                            _listKey.currentState!.removeItem(
                              index,
                              (context, animation) {
                                return SizeTransition(
                                  sizeFactor: animation,
                                  child: Match(
                                    match: removed,
                                    onEdit: (context) {},
                                    onDelete: (context) {},
                                  ),
                                );
                              },
                              duration: const Duration(milliseconds: 250),
                            );
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
