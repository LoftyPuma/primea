import 'dart:math';

import 'package:flutter/material.dart';
import 'package:parallel_stats/modal/match.dart';
import 'package:parallel_stats/tracker/match.dart';
import 'package:parallel_stats/tracker/match_model.dart';
import 'package:parallel_stats/tracker/paragon.dart';
import 'package:parallel_stats/tracker/progress_card.dart';
import 'package:parallel_stats/tracker/quick_add.dart';

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
int gameResultCount = MatchResult.values.length;

class _DummyAccountState extends State<DummyAccount> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  bool playerOne = true;
  MatchResults matchResults = MatchResults();
  late List<MatchModel> matchList = List.generate(
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

  @override
  initState() {
    for (var i = 0; i < matchList.length; i++) {
      var match = matchList[i];
      switch (match.result) {
        case MatchResult.win:
          match.playerOne
              ? matchResults.onThePlay.win++
              : matchResults.onTheDraw.win++;
        case MatchResult.loss:
          match.playerOne
              ? matchResults.onThePlay.loss++
              : matchResults.onTheDraw.loss++;
        case MatchResult.draw:
          match.playerOne
              ? matchResults.onThePlay.draw++
              : matchResults.onTheDraw.draw++;
        case MatchResult.disconnect:
          matchResults.onThePlay.disconnect++;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
    );
  }
}
