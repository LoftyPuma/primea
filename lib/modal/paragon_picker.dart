import 'package:flutter/material.dart';
import 'package:parallel_stats/tracker/paragon.dart';
import 'package:parallel_stats/tracker/parallel_avatar.dart';

class ParagonPicker extends StatelessWidget {
  final Function(Paragon) onParagonSelected;
  final String? tooltip;

  const ParagonPicker({
    super.key,
    required this.onParagonSelected,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 720,
      child: Padding(
        padding: const EdgeInsets.only(left: 44, right: 44, top: 120),
        child: Wrap(
          runAlignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 8,
          alignment: WrapAlignment.spaceAround,
          children: ParallelType.values
              .where((parallel) => parallel != ParallelType.universal)
              .map(
                (parallel) => Padding(
                  padding: const EdgeInsets.all(8),
                  child: SizedBox.square(
                    dimension: 80,
                    child: ParallelAvatar(
                      parallel: parallel,
                      isSelected: false,
                      onSelection: (paragon) {
                        onParagonSelected(paragon);
                      },
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
