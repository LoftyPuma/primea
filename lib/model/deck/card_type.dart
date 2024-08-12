import 'package:flutter/material.dart';

enum CardType {
  paragon(color: Colors.teal, title: 'Paragon'),
  unit(color: Colors.blue, title: 'Unit'),
  effect(color: Colors.amber, title: 'Effect'),
  upgrade(color: Colors.green, title: 'Upgrade'),
  relic(color: Colors.purple, title: 'Relic'),
  splitUnitEffect(color: Colors.red, title: 'Split');

  final Color color;
  final String title;

  const CardType({
    required this.color,
    required this.title,
  });

  static fromName(String name) {
    switch (name) {
      case 'paragon':
        return CardType.paragon;
      case 'unit':
        return CardType.unit;
      case 'effect':
        return CardType.effect;
      case 'upgrade':
        return CardType.upgrade;
      case 'relic':
        return CardType.relic;
      case 'split: unit-effect':
        return CardType.splitUnitEffect;
      default:
        throw Exception('Unknown card type: $name');
    }
  }
}
