import 'dart:math';

import 'package:flutter/material.dart';
import 'package:primea/model/deck/card_function.dart';
import 'package:primea/model/deck/card_type.dart';

class StackedLineGraph extends CustomPainter {
  final TextStyle textStyle;
  final Map<CardFunction, int> cards;
  // map cost to a map of the list of cards in each card type
  final Map<int, Map<CardType, int>> _stackedData = {};
  // the maximum number of cards in a single cost bracket
  late final int maxCostCount;

  static const maxCost = 10;
  static const drawnCardTypes = [
    CardType.unit,
    CardType.effect,
    CardType.upgrade,
    CardType.relic,
    CardType.splitUnitEffect,
  ];

  StackedLineGraph({
    super.repaint,
    required this.textStyle,
    required this.cards,
  }) {
    for (var card in cards.entries
        .where((card) => card.key.cardType != CardType.paragon)) {
      if (!_stackedData.containsKey(card.key.cost)) {
        _stackedData[card.key.cost] = {};
      }

      if (!_stackedData[card.key.cost]!.containsKey(card.key.cardType)) {
        _stackedData[card.key.cost]![card.key.cardType] = 0;
      }

      final current = _stackedData[card.key.cost]![card.key.cardType]!;
      _stackedData[card.key.cost]![card.key.cardType] = current + card.value;
    }

    maxCostCount = _stackedData.values
        .map((cost) => cost.values.fold(0, (acc, count) => acc + count))
        .fold(0, (acc, count) => max(acc, count));
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(0, size.height);
    const double textHeight = 8;
    final double columnWidth = size.width / (maxCost + 1);

    List<Offset> overallPathOffsets = [];
    for (var x = 0; x <= maxCost; x++) {
      overallPathOffsets.add(
        Offset(
          x * columnWidth + columnWidth / 2,
          _stackedData[x]
                  ?.values
                  .fold(0, (acc, count) => acc + count)
                  .toDouble() ??
              0,
        ),
      );
      TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: x.toString(),
          style: textStyle.copyWith(
            shadows: [
              const Shadow(
                blurRadius: 8,
              )
            ],
          ),
        ),
      )
        ..layout(minWidth: columnWidth, maxWidth: columnWidth)
        ..paint(
          canvas,
          Offset(x * columnWidth, -textHeight * 2),
        );
    }
    canvas.translate(0, -textHeight * 2);

    final double rowHeight = (size.height - textHeight * 2) / (maxCostCount);

    final costCounters = List<int>.filled(maxCost + 1, 0);

    for (var cardType in drawnCardTypes) {
      Paint paint = Paint()
        ..color = cardType.color
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      for (var x = 0.0; x <= maxCost; x++) {
        final double y = _stackedData[x]?[cardType]?.toDouble() ?? 0;

        final rect = Rect.fromLTWH(
          (x * columnWidth) + columnWidth * 0.05,
          -(y + costCounters[x.toInt()]) * rowHeight,
          columnWidth * 0.9,
          y * rowHeight,
        );

        if (y != 0) {
          canvas.drawRect(
              Rect.fromLTWH(
                (x * columnWidth) + columnWidth * 0.05,
                -(y + costCounters[x.toInt()]) * rowHeight,
                columnWidth * 0.9,
                y * rowHeight,
              ),
              paint..style = PaintingStyle.fill);

          TextPainter(
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            text: TextSpan(
              text: y.toInt().toString(),
              style: textStyle.copyWith(
                shadows: [
                  const Shadow(
                    blurRadius: 8,
                  )
                ],
              ),
            ),
          )
            ..layout(minWidth: columnWidth * 0.9, maxWidth: columnWidth * 0.9)
            ..paint(canvas,
                rect.center.translate(-(columnWidth * .9) / 2, -textHeight));
        }
        costCounters[x.toInt()] += y.toInt();
      }
    }

    Path path = Path();

    // Start the path at the first point
    path.moveTo(overallPathOffsets[0].dx, overallPathOffsets[0].dy);

    for (int i = 0; i < overallPathOffsets.length - 1; i++) {
      Offset p0 = overallPathOffsets[i];
      Offset p1 = overallPathOffsets[i + 1];
      Offset controlPoint1 = Offset(
        (p0.dx + p1.dx) / 2,
        p0.dy,
      );
      Offset controlPoint2 = Offset(
        (p0.dx + p1.dx) / 2,
        p1.dy,
      );

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy * -rowHeight,
        controlPoint2.dx,
        controlPoint2.dy * -rowHeight,
        p1.dx,
        p1.dy * -rowHeight,
      );
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white70
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(StackedLineGraph oldDelegate) {
    return oldDelegate.cards != cards;
  }
}
