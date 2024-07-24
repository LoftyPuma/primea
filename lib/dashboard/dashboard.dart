import 'package:flutter/material.dart';
import 'package:parallel_stats/dashboard/card.dart';
import 'package:parallel_stats/dashboard/number_card.dart';
import 'package:parallel_stats/main.dart';
import 'package:parallel_stats/model/match/inherited_match_results.dart';
import 'package:parallel_stats/model/match/match_model.dart';
import 'package:parallel_stats/model/match/player_turn.dart';
import 'package:parallel_stats/tracker/paragon.dart';
import 'package:parallel_stats/tracker/progress_card.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with AutomaticKeepAliveClientMixin {
  Paragon? paragon;
  Paragon? opponentParagon;
  PlayerTurn? playerTurn;

  bool showOnThePlay = true;
  bool showMatchesWon = true;

  late Future<int> mmrDelta;
  late Future<int> winStreak;
  late Future<double> primeEstimate;

  @override
  bool get wantKeepAlive => true;

  static const double spacing = 8;
  static const double squareSize = 150;

  Future<int> _fetchMMRChange([
    Duration timeSpan = const Duration(days: 1),
  ]) async {
    final response = await supabase
        .from(MatchModel.gamesTableName)
        .select("mmr_delta.sum()")
        .gt('game_time', DateTime.now().toUtc().subtract(timeSpan));
    return response[0]["sum"];
  }

  Future<int> _fetchWinStreak() async {
    final int winStreak = await supabase.rpc("get_win_streak");
    return winStreak;
  }

  Future<double> _fetchPrimeEstimate() async {
    final now = DateTime.now().toUtc();
    final response = await supabase
        .from(MatchModel.gamesTableName)
        .select("id, prime_estimate.sum()")
        .gte("game_time::date", DateTime(now.year, now.month, now.day))
        .lte("game_time::date", DateTime(now.year, now.month, now.day + 1))
        .gt("prime_estimate", 0)
        .limit(5);
    return response[0]["sum"];
  }

  @override
  void initState() {
    mmrDelta = _fetchMMRChange();
    winStreak = _fetchWinStreak();
    primeEstimate = _fetchPrimeEstimate();
    super.initState();
  }

  double _calculateDimension(int tileCount) {
    final bufferSpace =
        tileCount == 1 ? 0 : (tileCount) * _DashboardState.spacing;
    return (_DashboardState.squareSize * tileCount.toDouble()) + bufferSpace;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final matchResults = InheritedMatchResults.of(context);

    return ListView(
      children: [
        const Wrap(
          alignment: WrapAlignment.center,
          children: [],
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
                  FutureBuilder(
                    future: winStreak,
                    builder: (context, snapshot) {
                      Widget child;
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        child = const BaseCard(
                          height: squareSize,
                          width: squareSize,
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        child = NumberCard(
                          title: 'Win streak',
                          height: squareSize,
                          width: squareSize,
                          value: (snapshot.data?.toDouble() ?? 0.0)
                              .toStringAsFixed(0),
                        );
                      }

                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: child,
                      );
                    },
                  ),
                  NumberCard(
                    title: 'Matches Played',
                    height: squareSize,
                    width: _calculateDimension(2),
                    value: matchResults
                        .count(
                          paragon: paragon,
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
                        showOnThePlay = !showOnThePlay;
                      });
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: showOnThePlay
                          ? NumberCard(
                              key: const ValueKey('onThePlay'),
                              title: 'On the Play',
                              height: squareSize,
                              width: squareSize,
                              switchable: true,
                              value: matchResults
                                  .count(
                                    paragon: paragon,
                                    opponentParagon: opponentParagon,
                                    playerTurn: PlayerTurn.onThePlay,
                                  )
                                  .total
                                  .toDouble()
                                  .toStringAsFixed(0),
                            )
                          : NumberCard(
                              key: const ValueKey('onTheDraw'),
                              title: 'On the Draw',
                              height: squareSize,
                              width: squareSize,
                              switchable: true,
                              value: matchResults
                                  .count(
                                    paragon: paragon,
                                    opponentParagon: opponentParagon,
                                    playerTurn: PlayerTurn.onTheDraw,
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
                                    paragon: paragon,
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
                                    paragon: paragon,
                                    opponentParagon: opponentParagon,
                                    playerTurn: playerTurn,
                                  )
                                  .loss
                                  .toDouble()
                                  .toStringAsFixed(0),
                            ),
                    ),
                  ),
                  FutureBuilder(
                    future: primeEstimate,
                    builder: (context, snapshot) {
                      Widget child;
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        child = const BaseCard(
                          height: squareSize,
                          width: squareSize,
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        child = NumberCard(
                          title: '1 day Prime',
                          height: squareSize,
                          width: squareSize,
                          value: (snapshot.data ?? 0.0).toStringAsFixed(3),
                        );
                      }

                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: child,
                      );
                    },
                  ),
                  FutureBuilder(
                    future: mmrDelta,
                    builder: (context, snapshot) {
                      Widget child;
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        child = const BaseCard(
                          height: squareSize,
                          width: squareSize,
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        child = NumberCard(
                          title: '1 day MMR',
                          height: squareSize,
                          width: squareSize,
                          value: (snapshot.data?.toDouble() ?? 0.0)
                              .toStringAsFixed(0),
                        );
                      }

                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: child,
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    ),
                    height: _DashboardState.squareSize * 2 +
                        _DashboardState.spacing * 3,
                    child: const Wrap(
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
                          ),
                        ),
                        FittedBox(
                          child: ProgressCard(
                            playerTurn: PlayerTurn.onThePlay,
                            title: "On the Play",
                            height: _DashboardState.squareSize,
                            spacing: _DashboardState.spacing,
                          ),
                        ),
                        FittedBox(
                          child: ProgressCard(
                            playerTurn: PlayerTurn.onTheDraw,
                            title: "On the Draw",
                            height: _DashboardState.squareSize,
                            spacing: _DashboardState.spacing,
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
