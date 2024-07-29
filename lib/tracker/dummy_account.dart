import 'dart:math';

import 'package:flutter/material.dart';
import 'package:parallel_stats/modal/match.dart';
import 'package:parallel_stats/model/match/inherited_match_results.dart';
import 'package:parallel_stats/model/match/match_result_option.dart';
import 'package:parallel_stats/model/match/match_results.dart';
import 'package:parallel_stats/model/match/player_turn.dart';
import 'package:parallel_stats/tracker/match.dart';
import 'package:parallel_stats/model/match/match_model.dart';
import 'package:parallel_stats/tracker/paragon.dart';
import 'package:parallel_stats/tracker/progress_card.dart';
import 'package:parallel_stats/tracker/quick_add.dart';
import 'package:parallel_stats/util/string.dart';

class DummyAccount extends StatefulWidget {
  final Paragon chosenParagon;

  const DummyAccount({
    super.key,
    required this.chosenParagon,
  });

  @override
  State<DummyAccount> createState() => _DummyAccountState();
}

int paragonsCount = Paragon.values.length;
int gameResultCount = MatchResultOption.values.length;

class _DummyAccountState extends State<DummyAccount> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  PlayerTurn playerTurn = PlayerTurn.onThePlay;
  MatchResults matchResults = MatchResults();
  List<MatchModel> matchList = List.generate(
    8,
    (index) {
      var result = MatchResultOption.values[Random().nextInt(gameResultCount)];
      var mmrDelta = Random().nextInt(25);
      if (result == MatchResultOption.disconnect ||
          result == MatchResultOption.draw) {
        mmrDelta = 0;
      } else if (result == MatchResultOption.loss) {
        mmrDelta = -mmrDelta;
      }
      return MatchModel(
        paragon: Paragon.values[Random().nextInt(paragonsCount)],
        playerTurn:
            Random().nextBool() ? PlayerTurn.onThePlay : PlayerTurn.onTheDraw,
        result: result,
        opponentUsername: 'Sample Opponent #$index',
        opponentParagon: Paragon.values[Random().nextInt(paragonsCount)],
        mmrDelta: mmrDelta,
        primeEarned:
            result == MatchResultOption.win ? Random().nextDouble() : 0,
        matchTime: DateTime.now().subtract(
          Duration(
            days: Random().nextInt(30),
            hours: Random().nextInt(24),
            minutes: Random().nextInt(60),
          ),
        ),
      );
    },
  )..sort((a, b) => b.matchTime.compareTo(a.matchTime));

  @override
  initState() {
    for (var i = 0; i < matchList.length; i++) {
      var match = matchList[i];
      matchResults.recordMatch(match);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InheritedMatchResults(
      matchResults: matchResults,
      child: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 720,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'Sample data shown below.\nSign in to save your matches.',
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                ListenableBuilder(
                  listenable: matchResults,
                  builder: (context, child) {
                    return child!;
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ProgressCard(
                        title: "Win Rate",
                        height: 150,
                        spacing: 8,
                      ),
                      ProgressCard(
                        playerTurn: PlayerTurn.onThePlay,
                        title: "On the Play",
                        height: 150,
                        spacing: 8,
                      ),
                      ProgressCard(
                        playerTurn: PlayerTurn.onTheDraw,
                        title: "On the Draw",
                        height: 150,
                        spacing: 8,
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
                      message: !playerTurn.value
                          ? 'You play first'
                          : 'Opponent plays first',
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Switch(
                          value: !playerTurn.value,
                          onChanged: (value) => setState(() {
                            playerTurn = value
                                ? PlayerTurn.onTheDraw
                                : PlayerTurn.onThePlay;
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
                                playerTurn: playerTurn,
                                result: result,
                                matchTime: DateTime.now(),
                              );
                              var currentPlayer =
                                  widget.chosenParagon.title.isEmpty
                                      ? widget.chosenParagon.name
                                      : widget.chosenParagon.title;
                              var opponentParagon =
                                  Paragon.values.byName(parallel.name);
                              var opponent = opponentParagon.title.isEmpty
                                  ? opponentParagon.name
                                  : opponentParagon.title;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  showCloseIcon: true,
                                  content: Text(
                                    "Saving match: ${currentPlayer.toTitleCase()} vs ${opponent.toTitleCase()}",
                                  ),
                                ),
                              );

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
                AnimatedList(
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
                            setState(() {
                              matchList[index] = updatedMatch;
                              matchResults.updateMatch(match, updatedMatch);
                            });
                          }
                        },
                        onDelete: (context) {
                          setState(() {
                            matchList.removeAt(index);
                            matchResults.removeMatch(match);
                          });
                          _listKey.currentState!.removeItem(
                            index,
                            (context, animation) {
                              return SizeTransition(
                                sizeFactor: animation,
                                child: Match(
                                  match: match,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
