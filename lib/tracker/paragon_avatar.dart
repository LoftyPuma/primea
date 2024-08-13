import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:primea/model/deck/deck.dart';
import 'package:primea/model/deck/mini_deck.dart';
import 'package:primea/tracker/paragon.dart';
import 'package:vector_graphics/vector_graphics.dart';

class ParagonAvatar extends StatelessWidget {
  final Paragon paragon;
  final Deck? deck;
  final String? tooltip;
  final Color backgroundColor;

  const ParagonAvatar({
    super.key,
    required this.paragon,
    this.deck,
    this.tooltip,
    this.backgroundColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    if (deck != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: MiniDeck(deck: deck!),
      );
    }
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          stops: const [0.1, 1.0],
          colors: [
            paragon.parallel.color,
            Theme.of(context).scaffoldBackgroundColor,
          ],
        ),
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
                    ),
                  if (paragon.title.isNotEmpty &&
                      paragon.parallel.name != ParallelType.universal.name)
                    const TextSpan(text: '\n'),
                  if (paragon.parallel.name != ParallelType.universal.name)
                    TextSpan(
                      text: paragon.parallel.title,
                    ),
                ],
              )
          ],
        ),
        child: CircleAvatar(
          radius: 36,
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.topLeft,
            fit: StackFit.expand,
            children: [
              if (paragon.image != null && paragon != Paragon.unknown)
                Positioned(
                  top: 0,
                  left: 0,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SvgPicture(
                      width: 48,
                      height: 48,
                      AssetBytesLoader(
                        "assets/parallel_logos/vec/${paragon.parallel.name}.svg.vec",
                      ),
                      colorFilter: ColorFilter.mode(
                        paragon.parallel.color,
                        BlendMode.srcATop,
                      ),
                    ),
                  ),
                ),
              if (paragon.image == null)
                SvgPicture(
                  width: 64,
                  height: 64,
                  AssetBytesLoader(
                    "assets/parallel_logos/vec/${paragon.parallel.name}.svg.vec",
                  ),
                  colorFilter: ColorFilter.mode(
                    paragon.parallel.color,
                    BlendMode.srcATop,
                  ),
                ),
              if (paragon.image != null)
                Image(
                  image: ResizeImage(AssetImage(paragon.image!), width: 64),
                  width: 64,
                  height: 64,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
