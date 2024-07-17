import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:parallel_stats/parallel/card_model.dart';
import 'package:parallel_stats/parallel/class.dart';

class CardDisplay extends StatelessWidget {
  static final placeholderImage = SvgPicture.network(
    "https://storage.googleapis.com/prod-assets-parallel-life/images/card_fallback.svg",
    fit: BoxFit.cover,
  );

  const CardDisplay({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var card = InheritedCard.of(context).card;
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Image.network(
          card.cardClass
              .singleWhere(
                (element) => [
                  CardClassEnum.mp,
                  CardClassEnum.ac,
                  CardClassEnum.cb,
                  CardClassEnum.as,
                  CardClassEnum.rd,
                  CardClassEnum.prmv,
                ].contains(element.cardClass),
              )
              .imageUrl
              .toString(),
          key: ValueKey(card.name),
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) {
              return child;
            }
            return AnimatedCrossFade(
              firstChild: AspectRatio(
                aspectRatio: 4 / 5,
                child: placeholderImage,
              ),
              secondChild: AspectRatio(
                aspectRatio: 4 / 5,
                child: child,
              ),
              crossFadeState: frame == null
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(seconds: 5),
              firstCurve: Curves.easeOut,
              secondCurve: Curves.easeOut,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return Stack(
              children: [
                placeholderImage,
                Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              ],
            );
          },
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
        Column(
          children: [
            ListTile(
              title: SelectableText(
                card.name,
              ),
              subtitle: SelectableText(
                card.description,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
