import 'package:flutter/material.dart';
import 'package:primea/model/deck/deck.dart';
import 'package:primea/tracker/paragon.dart';

class MiniDeck extends StatelessWidget {
  final Deck deck;

  const MiniDeck({
    super.key,
    required this.deck,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: deck.name,
      child: Container(
        width: 80,
        height: 80,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: deck.isUniversal
                ? ParallelType.universal.color
                : deck.paragon.parallel.color.withAlpha(200),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: deck.isUniversal
                  ? ParallelType.universal.color.withAlpha(200)
                  : deck.paragon.parallel.color.withAlpha(200),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            alignment: Alignment.topCenter,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.2),
              BlendMode.darken,
            ),
            image: ResizeImage(
              AssetImage(
                Paragon.fromCardID(deck.paragon.id).art!,
              ),
              width: MediaQuery.of(context).size.width.toInt(),
            ),
            fit: BoxFit.cover,
            filterQuality: FilterQuality.none,
          ),
        ),
      ),
    );
  }
}
