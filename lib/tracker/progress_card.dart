import 'package:flutter/material.dart';
import 'package:parallel_stats/model/match/inherited_match_results.dart';
import 'package:parallel_stats/model/match/player_turn.dart';
import 'package:parallel_stats/tracker/paragon.dart';

class ProgressCard extends StatefulWidget {
  final String title;
  final Paragon? paragon;
  final Paragon? opponentParagon;
  final PlayerTurn? playerTurn;

  const ProgressCard({
    super.key,
    required this.title,
    this.paragon,
    this.opponentParagon,
    this.playerTurn,
  });

  @override
  State<StatefulWidget> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<ProgressCard> {
  double previousWinRate = 0.0;
  @override
  Widget build(BuildContext context) {
    final matchResults = InheritedMatchResults.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox.square(
        dimension: 150,
        child: ListenableBuilder(
          listenable: matchResults,
          builder: (context, child) {
            return TweenAnimationBuilder(
              tween: Tween(
                begin: previousWinRate,
                end: matchResults
                    .count(
                      paragon: widget.paragon,
                      opponentParagon: widget.opponentParagon,
                      playerTurn: widget.playerTurn,
                    )
                    .winRate,
              ),
              duration: const Duration(milliseconds: 500),
              builder: (context, double winRate, child) {
                previousWinRate = winRate;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: CircularProgressIndicator(
                          value: winRate.isFinite ? winRate : 0,
                          strokeWidth: 16,
                          strokeCap: StrokeCap.round,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            winRate > 0.5 ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(children: [
                        TextSpan(
                          text: '${(winRate * 100).toStringAsFixed(0)}%\n',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        TextSpan(
                          text: widget.title,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ]),
                    )
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
