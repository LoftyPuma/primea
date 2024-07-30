import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parallel_stats/modal/match.dart';
import 'package:parallel_stats/model/match/inherited_match_list.dart';
import 'package:parallel_stats/model/match/inherited_match_results.dart';
import 'package:parallel_stats/model/match/match_result_option.dart';
import 'package:parallel_stats/model/match/player_rank.dart';
import 'package:parallel_stats/model/match/player_turn.dart';
import 'package:parallel_stats/snack/basic.dart';
import 'package:parallel_stats/tracker/match.dart';
import 'package:parallel_stats/model/match/match_model.dart';
import 'package:parallel_stats/tracker/paragon.dart';
import 'package:parallel_stats/tracker/paragon_stack.dart';
import 'package:parallel_stats/tracker/parallel_avatar.dart';
import 'package:parallel_stats/util/string.dart';

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
  Paragon chosenParagon = Paragon.unknown;
  bool loadMoreEnabled = true;
  Rank? rank;

  // Details panel
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _mmrController = TextEditingController();
  final TextEditingController _primeController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _mmrController.dispose();
    _primeController.dispose();
    super.dispose();
  }

  Widget placeholder = Padding(
    padding: const EdgeInsets.all(8),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ParagonStack(
          game: MatchModel(
            paragon: Paragon.unknown,
            playerTurn: PlayerTurn.onThePlay,
            result: MatchResultOption.draw,
            matchTime: DateTime.now().toUtc(),
          ),
        ),
        const Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add a match to get started!'),
            ],
          ),
        ),
        const Tooltip(
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
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'On the Play',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    Tooltip(
                      message: playerTurn == PlayerTurn.onThePlay
                          ? 'You play first'
                          : 'Opponent plays first',
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Switch(
                          value: !playerTurn.value,
                          thumbIcon: WidgetStateProperty.resolveWith((states) {
                            return Icon(
                              playerTurn == PlayerTurn.onThePlay
                                  ? Icons.swipe_up
                                  : Icons.sim_card_download,
                              color: playerTurn == PlayerTurn.onThePlay
                                  ? Colors.yellow[600]
                                  : Colors.cyan,
                            );
                          }),
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
                                ? Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerLowest
                                : Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'On the Draw',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
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
                      DropdownButton<Rank>(
                        // isExpanded: true,
                        value: rank,
                        hint: const Text('Opponent Rank'),
                        onChanged: (value) {
                          setState(() {
                            rank = value;
                          });
                        },
                        items: Rank.values.reversed
                            .map(
                              (rank) => DropdownMenuItem<Rank>(
                                value: rank,
                                child: Text(rank.name.toTitleCase()),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                Text(
                  "Opponent's Paragon",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 44, right: 44),
                  child: Wrap(
                    spacing: 8,
                    alignment: WrapAlignment.spaceAround,
                    children: ParallelType.values
                        .where((parallel) => parallel != ParallelType.universal)
                        .map(
                          (parallel) => Padding(
                            padding: const EdgeInsets.all(8),
                            child: SizedBox.square(
                              dimension: 80,
                              child: ParallelAvatar(
                                parallel: parallel,
                                isSelected: chosenParagon.parallel == parallel,
                                onSelection: (paragon) {
                                  setState(() {
                                    if (chosenParagon == paragon) {
                                      chosenParagon = Paragon.unknown;
                                    } else {
                                      chosenParagon = paragon;
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: SegmentedButton<MatchResultOption>(
                          showSelectedIcon: false,
                          segments: [
                            ButtonSegment(
                              value: MatchResultOption.win,
                              label: Text(MatchResultOption.win.tooltip),
                              enabled: chosenParagon != Paragon.unknown,
                              icon: Icon(
                                MatchResultOption.win.icon,
                                color: MatchResultOption.win.color.withOpacity(
                                  chosenParagon == Paragon.unknown ? 0.5 : 1,
                                ),
                              ),
                            ),
                            ButtonSegment(
                              value: MatchResultOption.draw,
                              label: Text(MatchResultOption.draw.tooltip),
                              enabled: chosenParagon != Paragon.unknown,
                              icon: Icon(
                                MatchResultOption.draw.icon,
                                color: MatchResultOption.draw.color.withOpacity(
                                  chosenParagon == Paragon.unknown ? 0.5 : 1,
                                ),
                              ),
                            ),
                            ButtonSegment(
                              value: MatchResultOption.loss,
                              label: Text(MatchResultOption.loss.tooltip),
                              enabled: chosenParagon != Paragon.unknown,
                              icon: Icon(
                                MatchResultOption.loss.icon,
                                color: MatchResultOption.loss.color.withOpacity(
                                  chosenParagon == Paragon.unknown ? 0.5 : 1,
                                ),
                              ),
                            ),
                          ],
                          selected: const {},
                          emptySelectionAllowed: true,
                          multiSelectionEnabled: false,
                          onSelectionChanged: (selection) async {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar(
                              reason: SnackBarClosedReason.hide,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              BasicSnack(
                                content: Text(
                                  "Saving ${selection.first.name} vs ${chosenParagon.title.isEmpty ? chosenParagon.name.toTitleCase() : chosenParagon.title}",
                                ),
                              ),
                            );
                            await matchList.add(
                              MatchModel(
                                paragon: widget.chosenParagon,
                                opponentUsername: _usernameController.text,
                                opponentParagon: chosenParagon,
                                playerTurn: playerTurn,
                                matchTime: DateTime.now().toUtc(),
                                result: selection.first,
                                mmrDelta:
                                    int.tryParse(_mmrController.text) ?? 0,
                                primeEarned:
                                    double.tryParse(_primeController.text) ?? 0,
                              ),
                            );
                            setState(() {
                              playerTurn = PlayerTurn.onThePlay;
                              chosenParagon = Paragon.unknown;
                              rank = null;
                              _usernameController.clear();
                              _mmrController.clear();
                              _primeController.clear();
                            });
                          },
                        ),
                      ),
                    ),
                  ],
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
                      reverse: false,
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
          Tooltip(
            message: !loadMoreEnabled ? "No older matches" : "",
            child: OutlinedButton.icon(
              label: const Text("Load More"),
              icon: const Icon(Icons.add),
              onPressed: loadMoreEnabled
                  ? () async {
                      if (await matchList.loadMore() < matchList.limit) {
                        setState(() {
                          loadMoreEnabled = false;
                        });
                      }
                    }
                  : null,
            ),
          ),
          const SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }
}
