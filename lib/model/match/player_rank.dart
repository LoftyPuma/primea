import 'package:flutter/material.dart';

enum Rank {
  unranked(color: Colors.black),
  bronze(color: Color(0xFFCD7f32)),
  silver(color: Color(0xFFAAA9AD)),
  gold(color: Color(0xFFD4AF37)),
  platinum(color: Color(0xFFE5E4E2)),
  diamond(color: Color(0xFFB9F2FF)),
  master(color: Color(0xFFDEF141));

  final Color color;

  const Rank({required this.color});

  bool operator >(Rank other) => index > other.index;
}
