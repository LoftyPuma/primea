import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parallel_stats/model/match/match_model.dart';
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
          padding: const EdgeInsets.all(8),
          child: Tooltip(
            message: match.playerTurn.value ? 'On the Play' : 'On the Draw',
            child: Icon(
              match.playerTurn.value ? Icons.swipe_up : Icons.sim_card_download,
              color: match.playerTurn.value ? Colors.yellow[600] : Colors.cyan,
            ),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                match.opponentUsername ?? 'Unknown Opponent',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              if (match.matchTime != null)
                Text(
                  DateFormat.MMMMd().add_jm().format(match.matchTime!),
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
        Tooltip(
          message: match.result.tooltip,
          child: Icon(
            match.result.icon,
            color: match.result.color,
          ),
        ),
      ],
    );
  }
}
