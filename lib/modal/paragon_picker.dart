import 'package:flutter/material.dart';
import 'package:parallel_stats/tracker/paragon.dart';
import 'package:parallel_stats/tracker/paragon_avatar.dart';

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
      width: 500,
      child: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        children: Paragon.values
            .skip(1)
            .where((paragon) => paragon.title != "")
            .map(
              (paragon) => GestureDetector(
                onTap: () => onParagonSelected(paragon),
                child: ParagonAvatar(
                  paragon: paragon,
                  tooltip: tooltip,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
