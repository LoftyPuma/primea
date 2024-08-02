import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parallel_stats/model/match/match_model.dart';
import 'package:parallel_stats/model/match/match_result_option.dart';
import 'package:parallel_stats/snack/basic.dart';
import 'package:parallel_stats/tracker/paragon_stack.dart';
import 'package:parallel_stats/util/string.dart';

class Match extends StatelessWidget {
  final MatchModel match;
  final Function(BuildContext context)? onEdit;
  final Function(BuildContext context)? onDelete;

  const Match({
    super.key,
    required this.match,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: onEdit == null
              ? null
              : () {
                  onEdit!(context);
                },
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          color: Colors.red,
          onPressed: onDelete == null
              ? null
              : () {
                  var currentPlayer = match.paragon.title.isEmpty
                      ? match.paragon.name
                      : match.paragon.title;
                  var opponent = match.opponentParagon.title.isEmpty
                      ? match.opponentParagon.name
                      : match.opponentParagon.title;
                  ScaffoldMessenger.of(context).hideCurrentSnackBar(
                    reason: SnackBarClosedReason.dismiss,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    BasicSnack(
                      content: Text(
                          "Deleting ${currentPlayer.toTitleCase()} ${match.result.name} vs ${opponent.toTitleCase()}"),
                    ),
                  );
                  onDelete!(context);
                },
        ),
        ParagonStack(game: match),
        Padding(
          padding: const EdgeInsets.all(4),
          child: Tooltip(
            message: match.playerTurn.value ? 'Going 1st' : 'Going 2nd',
            child: Icon(
              match.playerTurn.value
                  ? Icons.looks_one_rounded
                  : Icons.looks_two_rounded,
              color: match.playerTurn.value ? Colors.yellow[600] : Colors.cyan,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: Tooltip(
            message: match.result.tooltip,
            child: [MatchResultOption.draw, MatchResultOption.disconnect]
                    .contains(match.result)
                ? Icon(
                    match.result.icon,
                    color: match.result.color,
                  )
                : match.result == MatchResultOption.win
                    ? CircleAvatar(
                        backgroundColor: Colors.green,
                        radius: 12,
                        child: Baseline(
                          baseline: 18,
                          baselineType: TextBaseline.alphabetic,
                          child: Text(
                            "W",
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                              shadows: [
                                const Shadow(
                                  color: Colors.black,
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : CircleAvatar(
                        backgroundColor: Colors.red,
                        radius: 12,
                        child: Baseline(
                          baseline: 18,
                          baselineType: TextBaseline.alphabetic,
                          child: Text(
                            "L",
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                              shadows: [
                                const Shadow(
                                  color: Colors.black,
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
          ),
        ),
        const Expanded(
          child: Tooltip(
            message: "COMING SOON",
            child: Text(
              "DECK NAME",
              textAlign: TextAlign.center,
              overflow: TextOverflow.fade,
              style: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                match.opponentUsername ?? 'Unknown Opponent',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Text(
                DateFormat.MMMMd().add_jm().format(match.matchTime.toLocal()),
                style: Theme.of(context).textTheme.labelMedium,
              ),
              RichText(
                text: TextSpan(
                  children: [
                    if (match.mmrDelta != null)
                      TextSpan(
                        text: "${match.mmrDelta} MMR",
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    if (match.mmrDelta != null && match.primeEarned != null)
                      TextSpan(
                        text: " • ",
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    if (match.primeEarned != null)
                      TextSpan(
                        text:
                            "${match.primeEarned?.toStringAsPrecision(3)} PRIME",
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
