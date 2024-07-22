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

class _ProgressCardState extends State<ProgressCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _valueAnimation;
  late final Animation<Color?> _colorAnimation;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _valueAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _colorAnimation = TweenSequence<Color?>(
      [
        TweenSequenceItem<Color?>(
          tween: ColorTween(begin: Colors.red, end: Colors.amber),
          weight: .8,
        ),
        TweenSequenceItem<Color?>(
          tween: ColorTween(begin: Colors.amber, end: Colors.green),
          weight: 1.2,
        ),
      ],
    ).animate(_controller);

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matchResults = InheritedMatchResults.of(context);
    matchResults.addListener(() {
      _controller.animateTo(
        matchResults
            .count(
              paragon: widget.paragon,
              opponentParagon: widget.opponentParagon,
              playerTurn: widget.playerTurn,
            )
            .winRate,
        duration: const Duration(milliseconds: 500),
        curve: Curves.bounceOut,
      );
    });

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox.square(
        dimension: 150,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  value: _valueAnimation.value,
                  strokeWidth: 16,
                  strokeCap: StrokeCap.round,
                  color: _colorAnimation.value,
                ),
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(children: [
                TextSpan(
                  text:
                      '${(_valueAnimation.value * 100).toStringAsFixed(0)}%\n',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                TextSpan(
                  text: widget.title,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ]),
            )
          ],
        ),
      ),
    );
  }
}
