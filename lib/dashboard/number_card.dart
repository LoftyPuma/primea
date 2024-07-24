import 'package:flutter/material.dart';
import 'package:parallel_stats/dashboard/card.dart';

class NumberCard extends StatelessWidget {
  final String title;
  final String value;
  final double height;
  final double width;
  final bool switchable;

  const NumberCard({
    super.key,
    required this.height,
    required this.width,
    required this.title,
    required this.value,
    this.switchable = false,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      height: height,
      width: width,
      switchable: switchable,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: '$value\n',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            TextSpan(
              text: title,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
      ),
    );
  }
}
