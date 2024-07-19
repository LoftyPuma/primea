import 'package:flutter/material.dart';
import 'package:parallel_stats/tracker/game_model.dart';
import 'package:parallel_stats/tracker/paragon.dart';
import 'package:parallel_stats/util/string.dart';

class QuickAddButton extends StatelessWidget {
  final ParallelType parallel;

  final void Function(ParallelType parallel, GameResult result) onSelection;

  const QuickAddButton({
    super.key,
    required this.parallel,
    required this.onSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          parallel.name.toTitleCase(),
          style: TextStyle(
            color: parallel.backgroundGradient.colors[0],
          ),
        ),
        SegmentedButton<GameResult>(
          showSelectedIcon: false,
          style: SegmentedButton.styleFrom(
            surfaceTintColor: parallel.backgroundGradient.colors[0],
            // backgroundColor: parallel.backgroundGradient.colors[0],
            foregroundColor: parallel.backgroundGradient.colors[0],
            // shadowColor: parallel.backgroundGradient.colors[0],
          ),
          segments: const [
            ButtonSegment(
              value: GameResult.win,
              label: Text('Won'),
            ),
            ButtonSegment(
              value: GameResult.loss,
              label: Text('Lost'),
            ),
          ],
          selected: const {},
          emptySelectionAllowed: true,
          multiSelectionEnabled: false,
          onSelectionChanged: (selection) =>
              onSelection(parallel, selection.first),
        ),
      ],
    );
  }
}