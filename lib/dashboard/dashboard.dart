import 'package:flutter/material.dart';
import 'package:parallel_stats/model/match/match_results.dart';
import 'package:parallel_stats/model/match/player_turn.dart';
import 'package:parallel_stats/tracker/progress_card.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // TODO: implement a top level `AccountModel` that each tab can depend on specifc parts of
  late MatchResults matchResults;

  // Future<MatchResults> fetchMatchResults() async {
  //   var results = await supabase.rpc('get_player_results');
  //   return MatchResults._fromJson(results);
  // }

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      children: [
        FittedBox(
          child: ProgressCard(
            title: "Win Rate",
          ),
        ),
        FittedBox(
          child: ProgressCard(
            playerTurn: PlayerTurn.onThePlay,
            title: "On the Play",
          ),
        ),
        FittedBox(
          child: ProgressCard(
            playerTurn: PlayerTurn.onTheDraw,
            title: "On the Draw",
          ),
        ),
      ],
    );
  }
}
