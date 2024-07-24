import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parallel_stats/modal/match.dart';
import 'package:parallel_stats/model/match/inherited_match_list.dart';
import 'package:parallel_stats/model/match/inherited_match_results.dart';
import 'package:parallel_stats/model/match/match_result_option.dart';
import 'package:parallel_stats/model/match/player_turn.dart';
import 'package:parallel_stats/tracker/match.dart';
import 'package:parallel_stats/model/match/match_model.dart';
import 'package:parallel_stats/tracker/paragon.dart';
import 'package:parallel_stats/tracker/paragon_stack.dart';
import 'package:parallel_stats/tracker/progress_card.dart';
import 'package:parallel_stats/tracker/quick_add.dart';

class Account extends StatefulWidget {
  final Paragon chosenParagon;
  final GlobalKey<AnimatedListState> listKey;

  const Account({
    super.key,
    required this.chosenParagon,
    required this.listKey,
  });

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  PlayerTurn playerTurn = PlayerTurn.onThePlay;

  // Details panel
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _mmrController = TextEditingController();
  final TextEditingController _primeController = TextEditingController();

  Widget placeholder = const Padding(
    padding: EdgeInsets.all(8),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ParagonStack(
          game: MatchModel(
            paragon: Paragon.unknown,
            playerTurn: PlayerTurn.onThePlay,
            result: MatchResultOption.draw,
          ),
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add a match to get started!'),
            ],
          ),
        ),
        Tooltip(
          message: "TBD",
          child: Icon(
            Icons.question_mark_outlined,
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final matchResults = InheritedMatchResults.of(context);
    final matchList = InheritedMatchList.of(context);

    return SizedBox(
      width: 720,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  child: FittedBox(
                    child: ProgressCard(
                      title: "Win Rate",
                      height: 150,
                      spacing: 8,
                    ),
                  ),
                ),
                Flexible(
                  child: FittedBox(
                    child: ProgressCard(
                      playerTurn: PlayerTurn.onThePlay,
                      title: "On the Play",
                      height: 150,
                      spacing: 8,
                    ),
                  ),
                ),
                Flexible(
                  child: FittedBox(
                    child: ProgressCard(
                      playerTurn: PlayerTurn.onTheDraw,
                      title: "On the Draw",
                      height: 150,
                      spacing: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('On the Play'),
                    ),
                    Tooltip(
                      message: playerTurn == PlayerTurn.onThePlay
                          ? 'You play first'
                          : 'Opponent plays first',
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Switch(
                          value: !playerTurn.value,
                          onChanged: (value) {
                            setState(() {
                              playerTurn = !value
                                  ? PlayerTurn.onThePlay
                                  : PlayerTurn.onTheDraw;
                            });
                          },
                          trackColor: WidgetStateColor.resolveWith(
                            (states) => states.contains(WidgetState.selected)
                                ? Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                : Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                          ),
                          thumbColor: WidgetStateColor.resolveWith(
                            (states) => states.contains(WidgetState.selected)
                                ? Theme.of(context).colorScheme.outline
                                : Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('On the Draw'),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 250,
                        child: TextField(
                          autocorrect: false,
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Opponent Username',
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^(-|)\d*'),
                            ),
                          ],
                          autocorrect: false,
                          controller: _mmrController,
                          decoration: const InputDecoration(
                            labelText: '+/- MMR',
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: false,
                            decimal: true,
                          ),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*'),
                            ),
                          ],
                          autocorrect: false,
                          controller: _primeController,
                          decoration: const InputDecoration(
                            labelText: 'PRIME',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 8,
                  alignment: WrapAlignment.spaceAround,
                  children: ParallelType.values
                      .where((parallel) => parallel != ParallelType.universal)
                      .map(
                        (parallel) => Padding(
                          padding: const EdgeInsets.all(8),
                          child: QuickAddButton(
                            parallel: parallel,
                            onSelection: (parallel, result) async {
                              final newMatch = MatchModel(
                                paragon: widget.chosenParagon,
                                opponentParagon:
                                    Paragon.values.byName(parallel.name),
                                playerTurn: playerTurn,
                                result: result,
                                matchTime: DateTime.now(),
                                opponentUsername:
                                    _usernameController.text.isEmpty
                                        ? null
                                        : _usernameController.text,
                                mmrDelta: _mmrController.text.isEmpty
                                    ? null
                                    : int.parse(_mmrController.text),
                                primeEarned: _primeController.text.isEmpty
                                    ? null
                                    : double.parse(_primeController.text),
                              );
                              await matchList.add(newMatch);
                              matchResults.recordMatch(newMatch);
                              _usernameController.clear();
                              _mmrController.clear();
                              _primeController.clear();
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          ListenableBuilder(
            listenable: matchList,
            builder: (context, child) {
              return child!;
            },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: matchList.isEmpty
                  ? placeholder
                  : AnimatedList(
                      key: widget.listKey,
                      shrinkWrap: true,
                      reverse: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(
                        top: 8,
                        left: 8,
                        right: 8,
                        bottom: 8,
                      ),
                      initialItemCount: matchList.length,
                      itemBuilder: (context, index, animation) {
                        final match = matchList[index];
                        return SizeTransition(
                          sizeFactor: animation,
                          child: Match(
                            match: match,
                            onEdit: (context) async {
                              final updatedMatch = await showDialog<MatchModel>(
                                context: context,
                                builder: (context) {
                                  return MatchModal(
                                    match: match,
                                  );
                                },
                              );
                              if (updatedMatch != null &&
                                  updatedMatch.id != null) {
                                matchList.update(updatedMatch);
                                matchResults.updateMatch(match, updatedMatch);
                              }
                            },
                            onDelete: (context) async {
                              final removed = await matchList.removeAt(index);
                              matchResults.removeMatch(removed);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(
            height: 80,
          ),
        ],
      ),
    );
  }
}
