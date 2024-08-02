import 'package:flutter/material.dart';
import 'package:parallel_stats/dashboard/number_card.dart';
import 'package:parallel_stats/model/match/inherited_match_list.dart';
import 'package:parallel_stats/model/match/inherited_match_results.dart';
import 'package:parallel_stats/model/match/player_turn.dart';
import 'package:parallel_stats/tracker/paragon.dart';
import 'package:parallel_stats/tracker/paragon_avatar.dart';
import 'package:parallel_stats/tracker/progress_card.dart';
import 'package:parallel_stats/util/string.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with AutomaticKeepAliveClientMixin {
  Paragon? selectedParagon;
  Paragon? opponentParagon;
  PlayerTurn? playerTurn;

  bool showGoing1st = true;
  bool showMatchesWon = true;

  late Future<int> mmrDelta;
  late Future<int> winStreak;
  late Future<double> primeEstimate;

  @override
  bool get wantKeepAlive => true;

  static const double spacing = 8;
  static const double squareSize = 150;

  double _calculateDimension(int tileCount) {
    final bufferSpace =
        tileCount == 1 ? 0 : (tileCount) * _DashboardState.spacing;
    return (_DashboardState.squareSize * tileCount.toDouble()) + bufferSpace;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final matchList = InheritedMatchList.of(context);
    final matchResults = InheritedMatchResults.of(context);

    return ListView(
      children: [
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints.loose(
              Size(
                _calculateDimension(5) + spacing * 4,
                double.infinity,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 44,
                right: 44,
                top: 16,
                bottom: 16,
              ),
              child: SizedBox(
                width: double.infinity,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    MenuAnchor(
                      alignmentOffset: const Offset(0, 4),
                      menuChildren: [
                        MenuItemButton(
                          child: SegmentedButton(
                            emptySelectionAllowed: true,
                            segments: [
                              ButtonSegment(
                                value: PlayerTurn.going1st,
                                icon: Icon(
                                  Icons.swipe_up,
                                  color: Colors.yellow[600],
                                ),
                                label: const Text("Going 1st"),
                              ),
                              const ButtonSegment(
                                value: PlayerTurn.going2nd,
                                icon: Icon(
                                  Icons.sim_card_download,
                                  color: Colors.cyan,
                                ),
                                label: Text("Going 2nd"),
                              ),
                            ],
                            selected: {playerTurn},
                            onSelectionChanged: (selection) {
                              if (selection.isNotEmpty) {
                                setState(() {
                                  playerTurn = selection.first;
                                });
                              }
                            },
                          ),
                        ),
                        SubmenuButton(
                          menuChildren: ParallelType.values
                              .where((parallel) =>
                                  parallel != ParallelType.universal)
                              .map(
                                (element) => MenuItemButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedParagon = element.paragon;
                                    });
                                  },
                                  leadingIcon: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: SizedBox.square(
                                      dimension: 44,
                                      child: ParagonAvatar(
                                        paragon: element.paragon,
                                      ),
                                    ),
                                  ),
                                  child: SubmenuButton(
                                    menuChildren: Paragon.values
                                        .where((paragonElement) =>
                                            paragonElement.parallel ==
                                                element &&
                                            paragonElement.name != element.name)
                                        .map(
                                          (paragonElement) => MenuItemButton(
                                            onPressed: () {
                                              setState(() {
                                                selectedParagon =
                                                    paragonElement;
                                              });
                                            },
                                            leadingIcon: Padding(
                                              padding: const EdgeInsets.all(4),
                                              child: SizedBox.square(
                                                dimension: 44,
                                                child: ParagonAvatar(
                                                  paragon: paragonElement,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              paragonElement.title,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    child: Text(
                                      element.name.toTitleCase(),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          child: const Text("Your Paragon"),
                        ),
                        SubmenuButton(
                          menuChildren: ParallelType.values
                              .where((parallel) =>
                                  parallel != ParallelType.universal)
                              .map(
                                (element) => MenuItemButton(
                                  onPressed: () {
                                    setState(() {
                                      opponentParagon = element.paragon;
                                    });
                                  },
                                  leadingIcon: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: SizedBox.square(
                                      dimension: 44,
                                      child: ParagonAvatar(
                                        paragon: element.paragon,
                                      ),
                                    ),
                                  ),
                                  child: SubmenuButton(
                                    menuChildren: Paragon.values
                                        .where((paragonElement) =>
                                            paragonElement.parallel ==
                                                element &&
                                            paragonElement.name != element.name)
                                        .map(
                                          (paragonElement) => MenuItemButton(
                                            onPressed: () {
                                              setState(() {
                                                opponentParagon =
                                                    paragonElement;
                                              });
                                            },
                                            leadingIcon: Padding(
                                              padding: const EdgeInsets.all(4),
                                              child: SizedBox.square(
                                                dimension: 44,
                                                child: ParagonAvatar(
                                                  paragon: paragonElement,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              paragonElement.title,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    child: Text(
                                      element.name.toTitleCase(),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          child: const Text("Opponent Paragon"),
                        ),
                      ],
                      builder: (context, controller, child) => TextButton.icon(
                        label: const Text("Filter"),
                        icon: const Icon(Icons.filter_list),
                        onPressed: () {
                          controller.isOpen
                              ? controller.close()
                              : controller.open();
                        },
                      ),
                    ),
                    if (playerTurn != null)
                      Chip(
                        avatar: Icon(
                          playerTurn!.value
                              ? Icons.swipe_up
                              : Icons.sim_card_download,
                          color: playerTurn!.value
                              ? Colors.yellow[600]
                              : Colors.cyan,
                        ),
                        label: Text(playerTurn == PlayerTurn.going1st
                            ? 'Going 1st'
                            : 'Going 2nd'),
                        onDeleted: () {
                          setState(() {
                            playerTurn = null;
                          });
                        },
                      ),
                    if (selectedParagon != null)
                      Chip(
                        avatar: CircleAvatar(
                          backgroundColor: selectedParagon?.parallel.color,
                        ),
                        label: Text(
                            "You: ${selectedParagon!.title.isEmpty ? selectedParagon!.name.toTitleCase() : selectedParagon!.title}"),
                        onDeleted: () {
                          setState(() {
                            selectedParagon = null;
                          });
                        },
                      ),
                    if (opponentParagon != null)
                      Chip(
                        avatar: CircleAvatar(
                          backgroundColor: opponentParagon?.parallel.color,
                        ),
                        label: Text(
                            "Opponent: ${opponentParagon!.title.isEmpty ? opponentParagon!.name.toTitleCase() : opponentParagon!.title}"),
                        onDeleted: () {
                          setState(() {
                            opponentParagon = null;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: 96,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints.loose(
                Size(
                  _calculateDimension(5) + spacing * 4,
                  double.infinity,
                ),
              ),
              child: Wrap(
                spacing: spacing,
                runSpacing: spacing,
                alignment: WrapAlignment.center,
                children: [
                  NumberCard(
                    title: 'Win streak',
                    height: squareSize,
                    width: _calculateDimension(2),
                    value: matchList.winStreak.toString(),
                  ),
                  NumberCard(
                    title: 'Matches Played',
                    height: squareSize,
                    width: _calculateDimension(2),
                    value: matchResults
                        .count(
                          paragon: selectedParagon,
                          opponentParagon: opponentParagon,
                          playerTurn: playerTurn,
                        )
                        .total
                        .toDouble()
                        .toStringAsFixed(0),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      setState(() {
                        showGoing1st = !showGoing1st;
                      });
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: showGoing1st
                          ? NumberCard(
                              key: const ValueKey('going1st'),
                              title: 'Going 1st',
                              height: squareSize,
                              width: squareSize,
                              switchable: true,
                              value: matchResults
                                  .count(
                                    paragon: selectedParagon,
                                    opponentParagon: opponentParagon,
                                    playerTurn: PlayerTurn.going1st,
                                  )
                                  .total
                                  .toDouble()
                                  .toStringAsFixed(0),
                            )
                          : NumberCard(
                              key: const ValueKey('going2nd'),
                              title: 'Going 2nd',
                              height: squareSize,
                              width: squareSize,
                              switchable: true,
                              value: matchResults
                                  .count(
                                    paragon: selectedParagon,
                                    opponentParagon: opponentParagon,
                                    playerTurn: PlayerTurn.going2nd,
                                  )
                                  .total
                                  .toDouble()
                                  .toStringAsFixed(0),
                            ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      setState(() {
                        showMatchesWon = !showMatchesWon;
                      });
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: showMatchesWon
                          ? NumberCard(
                              key: const ValueKey('matchesWon'),
                              title: 'Matches Won',
                              height: squareSize,
                              width: _calculateDimension(2),
                              switchable: true,
                              value: matchResults
                                  .count(
                                    paragon: selectedParagon,
                                    opponentParagon: opponentParagon,
                                    playerTurn: playerTurn,
                                  )
                                  .win
                                  .toDouble()
                                  .toStringAsFixed(0),
                            )
                          : NumberCard(
                              key: const ValueKey('matchesLost'),
                              title: 'Matches Lost',
                              height: squareSize,
                              width: _calculateDimension(2),
                              switchable: true,
                              value: matchResults
                                  .count(
                                    paragon: selectedParagon,
                                    opponentParagon: opponentParagon,
                                    playerTurn: playerTurn,
                                  )
                                  .loss
                                  .toDouble()
                                  .toStringAsFixed(0),
                            ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    ),
                    height: _DashboardState.squareSize * 2 +
                        _DashboardState.spacing * 3,
                    child: Wrap(
                      direction: Axis.vertical,
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        FittedBox(
                          child: ProgressCard(
                            title: "Win Rate",
                            sizeMultiplier: 2,
                            height: _DashboardState.squareSize,
                            spacing: _DashboardState.spacing,
                            paragon: selectedParagon,
                            opponentParagon: opponentParagon,
                            playerTurn: playerTurn,
                          ),
                        ),
                        FittedBox(
                          child: ProgressCard(
                            playerTurn: PlayerTurn.going1st,
                            title: "Going 1st",
                            height: _DashboardState.squareSize,
                            spacing: _DashboardState.spacing,
                            paragon: selectedParagon,
                            opponentParagon: opponentParagon,
                          ),
                        ),
                        FittedBox(
                          child: ProgressCard(
                            playerTurn: PlayerTurn.going2nd,
                            title: "Going 2nd",
                            height: _DashboardState.squareSize,
                            spacing: _DashboardState.spacing,
                            paragon: selectedParagon,
                            opponentParagon: opponentParagon,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
