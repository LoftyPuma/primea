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
  late StreamSubscription<List<Map<String, dynamic>>> _subscription;

  bool playerOne = true;
  MatchResults matchResults = MatchResults();
  List<MatchModel> matchList = List.empty(growable: true);

  Future<List<MatchModel>> fetchMatches(MatchModel oldestMatch) async {
    var matches = await supabase
        .from(MatchModel.gamesTableName)
        .select()
        .lt('game_time',
            (oldestMatch.matchTime ?? oldestMatch.createdAt!).toIso8601String())
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

  Widget placeholder = const Padding(
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

  void handleMatchStream(List<Map<String, dynamic>> data) {
    // print("data streamed: $data");
    // int lastInertIndex = 0;
    // reverse the data so the newest matches are at the end of the list
    for (var match in data.reversed) {
      final newMatch = MatchModel.fromJson(match);
      final matchIndex =
          matchList.indexWhere((match) => match.id == newMatch.id);
      if (matchIndex != -1) {
        setState(() {
          matchResults.updateMatch(matchList[matchIndex], newMatch);
          // TODO: Sort the list if the match time has changed
          matchList[matchIndex] = newMatch;
        });
      } else {
        setState(() {
          // TODO: insert the match in the correct order based on match time
          matchList.add(newMatch);
          matchResults.recordMatch(newMatch);
          _listKey.currentState?.insertItem(
            matchList.length - 1,
            duration: const Duration(milliseconds: 250),
          );
        });
      }
    }
  }

  @override
  initState() {
    fetchMatchResults().then((results) {
      setState(() {
        matchResults = results;
      });
    });

    _subscription = supabase
        .from(MatchModel.gamesTableName)
        .stream(primaryKey: ['id'])
        .order("game_time", ascending: false)
        .order("created_at", ascending: false)
        // .limit(4)
        .listen(handleMatchStream);

    super.initState();
  }

  @override
  void didUpdateWidget(covariant Account oldWidget) {
    _subscription.cancel();
    _subscription = supabase
        .from(MatchModel.gamesTableName)
        .stream(primaryKey: ['id'])
        .order("created_at", ascending: true)
        // .limit(4)
        .listen(handleMatchStream);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Session? session = InheritedSession.maybeOf(context)?.session;

    return SizedBox(
      width: 720,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FittedBox(
                  child: ProgressCard(
                    winRate: matchResults.winRate,
                    title: "Win Rate",
                  ),
                ),
                FittedBox(
                  child: ProgressCard(
                    winRate: matchResults.onThePlay.winRate,
                    title: "On the Play",
                  ),
                ),
                FittedBox(
                  child: ProgressCard(
                    winRate: matchResults.onTheDraw.winRate,
                    title: "On the Draw",
                  ),
                ),
              ],
            ),
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
                message: playerOne ? 'You play first' : 'Opponent plays first',
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
                          : Theme.of(context).colorScheme.onPrimaryContainer,
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
                        await supabase.from(MatchModel.gamesTableName).insert(
                          [
                            MatchModel(
                              paragon: widget.chosenParagon,
                              opponentParagon:
                                  Paragon.values.byName(parallel.name),
                              playerOne: playerOne,
                              result: result,
                              matchTime: DateTime.now(),
                            ).toJson(),
                          ],
                          defaultToNull: false,
                        );
                      },
                    ),
                  ),
                )
                .toList(),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: matchList.isEmpty
                ? placeholder
                : AnimatedList(
                    key: _listKey,
                    shrinkWrap: true,
                    reverse: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(
                      top: 8,
                      left: 8,
                      right: 8,
                      bottom: 8,
                    ),
                    initialItemCount: matchList.length,
                    itemBuilder: (context, index, animation) {
                      final match = matchList.elementAt(index);
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
                                  !session.isExpired) {
                                await supabase
                                    .from(MatchModel.gamesTableName)
                                    .update(updatedMatch.toJson())
                                    .eq("id", match.id!);
                              }
                            }
                          },
                          onDelete: (context) async {
                            var removed = matchList.removeAt(index);

                            final response = await supabase
                                .from(MatchModel.gamesTableName)
                                .delete()
                                .eq("id", removed.id!)
                                .select();
                            print("delete response: $response");

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
                  ),
          ),
          const SizedBox(
            height: 80,
          ),
        ],
      ),
    );
  }
}
