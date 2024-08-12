import 'package:flutter/material.dart';

enum Rank {
  unranked(title: 'Unranked', color: Colors.black),
  bronze(title: 'Bronze', color: Color(0xFFCD7f32)),
  silver(title: 'Silver', color: Color(0xFFAAA9AD)),
  gold(title: 'Gold', color: Color(0xFFD4AF37)),
  platinum(title: 'Platinum', color: Color(0xFFE5E4E2)),
  diamond(title: 'Diamond', color: Color(0xFFB9F2FF)),
  master(title: 'Master', color: Color(0xFFDEF141));

  final Color color;
  final String title;

  const Rank({
    required this.color,
    required this.title,
  });

  bool operator >(Rank other) => index > other.index;
}
