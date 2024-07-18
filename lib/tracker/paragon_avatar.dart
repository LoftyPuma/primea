import 'package:flutter/material.dart';
import 'package:parallel_stats/tracker/paragon.dart';
import 'package:parallel_stats/util/string.dart';

class ParagonAvatar extends StatelessWidget {
  final Paragon paragon;

  const ParagonAvatar({
    super.key,
    required this.paragon,
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
          richMessage: TextSpan(
            children: [
              TextSpan(text: "${paragon.title}\n"),
              TextSpan(text: paragon.parallel.name.toTitleCase()),
            ],
          ),
          child: CircleAvatar(
            radius: 36,
            backgroundColor: Colors.transparent,
            child: paragon != Paragon.unknown
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
