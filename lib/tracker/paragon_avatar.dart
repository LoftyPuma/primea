import 'package:flutter/material.dart';
import 'package:parallel_stats/tracker/paragon.dart';
import 'package:parallel_stats/util/string.dart';

class ParagonAvatar extends StatelessWidget {
  final Paragon paragon;
  final String? tooltip;

  const ParagonAvatar({
    super.key,
    required this.paragon,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: paragon.parallel.backgroundGradient,
        ),
        child: Tooltip(
          textAlign: TextAlign.center,
          preferBelow: true,
          verticalOffset: 48,
          richMessage: TextSpan(
            children: [
              if (tooltip != null) TextSpan(text: tooltip),
              if (tooltip == null)
                TextSpan(
                  children: [
                    if (paragon.title.isNotEmpty)
                      TextSpan(
                        text: paragon.title,
                        // style: Theme.of(context).textTheme.labelSmall,
                      ),
                    if (paragon.title.isNotEmpty &&
                        paragon.parallel.name != ParallelType.universal.name)
                      const TextSpan(text: '\n'),
                    if (paragon.parallel.name != ParallelType.universal.name)
                      TextSpan(
                        text: paragon.parallel.name.toTitleCase(),
                        // style: Theme.of(context).textTheme.labelSmall,
                      ),
                  ],
                )
            ],
          ),
          child: CircleAvatar(
            radius: 36,
            backgroundColor: Colors.transparent,
            child: paragon.image != Paragon.unknown.image
                ? Image.asset(paragon.image)
                : Padding(
                    padding: const EdgeInsets.all(8),
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.white, Colors.transparent],
                          stops: [0.6, 1.0],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.dstIn,
                      child: Image.asset(paragon.image),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
