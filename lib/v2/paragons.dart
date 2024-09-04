import 'package:flutter/material.dart';
import 'package:primea/main.dart';
import 'package:primea/tracker/paragon.dart';

class Paragons extends StatefulWidget {
  const Paragons({super.key});

  @override
  State<StatefulWidget> createState() => _ParagonsState();
}

class _ParagonsState extends State<Paragons> {
  final opponentParagonPopularity = supabase
      .rpc<List<dynamic>>(
        'calculate_opponent_paragon_percentages',
      )
      .inFilter(
        'opponent_paragon',
        Paragon.values
            .where((paragon) =>
                paragon != Paragon.unknown && paragon.title.isNotEmpty)
            .map((paragon) => paragon.name)
            .toList(),
      )
      .limit(5);

  @override
  Widget build(BuildContext context) {
    return const Text('Paragons');
  }
}
