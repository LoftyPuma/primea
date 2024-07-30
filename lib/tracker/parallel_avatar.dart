import 'package:flutter/material.dart';
import 'package:parallel_stats/overlay/radial_overlay.dart';
import 'package:parallel_stats/tracker/paragon.dart';
import 'package:parallel_stats/tracker/paragon_avatar.dart';

class ParallelAvatar extends StatefulWidget {
  final ParallelType parallel;
  final bool isSelected;
  final Alignment alignment;
  final void Function(Paragon paragon) onSelection;

  const ParallelAvatar({
    super.key,
    required this.parallel,
    required this.isSelected,
    required this.onSelection,
    this.alignment = Alignment.topCenter,
  });

  @override
  State<ParallelAvatar> createState() => _ParallelAvatarState();
}

class _ParallelAvatarState extends State<ParallelAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late Paragon selectedParagon;
  late Iterable<Paragon> _paragonOptions;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      reverseDuration: const Duration(milliseconds: 250),
    );

    selectedParagon = widget.parallel.paragon;
    _paragonOptions = Paragon.values.where(
      (paragon) => paragon.parallel == widget.parallel,
    );

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        RadialOverlay(
          controller: _controller,
          parallel: widget.parallel,
          isSelected: widget.isSelected,
          alignment: widget.alignment,
          overlayChildren: [
            ParagonAvatar(
              key: ValueKey(_paragonOptions.elementAt(1)),
              paragon: _paragonOptions.elementAt(1),
            ),
            ParagonAvatar(
              key: ValueKey(_paragonOptions.elementAt(2)),
              paragon: _paragonOptions.elementAt(2),
            ),
            ParagonAvatar(
              key: ValueKey(_paragonOptions.elementAt(3)),
              paragon: _paragonOptions.elementAt(3),
            ),
          ],
          onTap: (paragon) {
            setState(() {
              selectedParagon = paragon;
            });
            widget.onSelection(paragon);
          },
          child: ParagonAvatar(
            key: ValueKey(_paragonOptions.elementAt(0)),
            paragon: _paragonOptions.elementAt(0),
          ),
        ),
      ],
    );
  }
}
