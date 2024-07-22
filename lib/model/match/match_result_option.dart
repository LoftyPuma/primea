import 'package:flutter/material.dart';

enum MatchResultOption {
  win(
    color: Colors.green,
    icon: Icons.check_circle,
    tooltip: 'Win',
    value: 1,
  ),
  loss(
    color: Colors.red,
    icon: Icons.cancel,
    tooltip: 'Loss',
    value: -1,
  ),
  draw(
    color: Colors.grey,
    icon: Icons.remove_circle,
    tooltip: 'Draw',
    value: 0,
  ),
  disconnect(
    color: Colors.orange,
    icon: Icons.error,
    tooltip: 'Disconnect',
    value: 0,
  );

  const MatchResultOption({
    required this.value,
    required this.icon,
    required this.color,
    required this.tooltip,
  });

  final int value;
  final IconData icon;
  final Color color;
  final String tooltip;
}
