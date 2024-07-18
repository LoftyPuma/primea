import 'package:flutter/material.dart';
import 'package:parallel_stats/tracker/paragon.dart';
import 'package:parallel_stats/tracker/paragon_avatar.dart';

class ParagonPicker extends StatelessWidget {
  final Function(Paragon) onParagonSelected;

  const ParagonPicker({
    super.key,
    required this.onParagonSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: GridView.count(
        padding: const EdgeInsets.all(16),
        // physics: const NeverScrollableScrollPhysics(),
        // scrollDirection: Axis.horizontal,
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        children: Paragon.values
            .skip(1)
            .map(
              (paragon) => GestureDetector(
                onTap: () => onParagonSelected(paragon),
                child: ParagonAvatar(paragon: paragon),
              ),
            )
            .toList(),
      ),
    );
  }
}
