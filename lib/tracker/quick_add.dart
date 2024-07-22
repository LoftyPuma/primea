import 'package:flutter/material.dart';
import 'package:parallel_stats/model/match/match_result_option.dart';
import 'package:parallel_stats/snack/basic.dart';
import 'package:parallel_stats/tracker/paragon.dart';
import 'package:parallel_stats/util/string.dart';

class QuickAddButton extends StatelessWidget {
  final ParallelType parallel;

  final void Function(ParallelType parallel, MatchResultOption result)
      onSelection;

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
        SegmentedButton<MatchResultOption>(
          showSelectedIcon: false,
          style: SegmentedButton.styleFrom(
            surfaceTintColor: parallel.backgroundGradient.colors[0],
            // backgroundColor: parallel.backgroundGradient.colors[0],
            foregroundColor: parallel.backgroundGradient.colors[0],
            // shadowColor: parallel.backgroundGradient.colors[0],
          ),
          segments: const [
            ButtonSegment(
              value: MatchResultOption.win,
              label: Text('Win'),
            ),
            ButtonSegment(
              value: MatchResultOption.draw,
              label: Text('Draw'),
            ),
            ButtonSegment(
              value: MatchResultOption.loss,
              label: Text('Loss'),
            ),
          ],
          selected: const {},
          emptySelectionAllowed: true,
          multiSelectionEnabled: false,
          onSelectionChanged: (selection) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar(
              reason: SnackBarClosedReason.hide,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              BasicSnack(
                content: Text(
                  "Saving ${selection.first.name} vs ${parallel.name}",
                ),
              ),
            );
            onSelection(parallel, selection.first);
          },
        ),
      ],
    );
  }
}
