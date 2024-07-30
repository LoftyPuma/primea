import 'package:flutter/material.dart';
import 'package:parallel_stats/model/match/inherited_match_results.dart';
import 'package:parallel_stats/model/match/match_results.dart';
import 'package:parallel_stats/model/match/player_turn.dart';
import 'package:parallel_stats/tracker/paragon.dart';

class ProgressCard extends StatefulWidget {
  final String title;
  final Paragon? paragon;
  final Paragon? opponentParagon;
  final PlayerTurn? playerTurn;
  final double aspectRatio;
  final double height;
  final double spacing;
  final int sizeMultiplier;

  const ProgressCard({
    super.key,
    required this.title,
    required this.height,
    required this.spacing,
    this.paragon,
    this.opponentParagon,
    this.playerTurn,
    this.aspectRatio = 1.0,
    this.sizeMultiplier = 1,
  });

  @override
  State<StatefulWidget> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<ProgressCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _valueAnimation;
  late final Animation<Color?> _colorAnimation;

  MatchResults? _matchResults;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
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

  void _handleAnimate() {
    if (mounted) {
      _controller.animateTo(
        _matchResults
                ?.count(
                  paragon: widget.paragon,
                  opponentParagon: widget.opponentParagon,
                  playerTurn: widget.playerTurn,
                )
                .winRate ??
            0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.bounceOut,
      );
    }
  }

  @override
  void dispose() {
    _matchResults?.removeListener(_handleAnimate);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ProgressCard oldWidget) {
    if (oldWidget.paragon != widget.paragon ||
        oldWidget.opponentParagon != widget.opponentParagon ||
        oldWidget.playerTurn != widget.playerTurn) {
      _handleAnimate();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    _matchResults ??= InheritedMatchResults.of(context);

    if (_controller.value == 0) {
      _controller.animateTo(
        _matchResults
                ?.count(
                  paragon: widget.paragon,
                  opponentParagon: widget.opponentParagon,
                  playerTurn: widget.playerTurn,
                )
                .winRate ??
            0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.bounceOut,
      );
    }

    _matchResults?.removeListener(_handleAnimate);
    _matchResults?.addListener(_handleAnimate);

    final bufferSpace = widget.sizeMultiplier == 1
        ? 0
        : (widget.sizeMultiplier + 1) * widget.spacing;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        width: (widget.height * widget.sizeMultiplier.toDouble()) + bufferSpace,
        child: AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, child) {
              return child!;
            },
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
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text:
                            '${(_valueAnimation.value * 100).toStringAsFixed(0)}%\n',
                        style: widget.sizeMultiplier == 1
                            ? Theme.of(context).textTheme.displaySmall
                            : Theme.of(context).textTheme.displayLarge,
                      ),
                      TextSpan(
                        text: widget.title,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
