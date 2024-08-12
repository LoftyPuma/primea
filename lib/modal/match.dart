import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:primea/modal/paragon_picker.dart';
import 'package:primea/model/deck/deck.dart';
import 'package:primea/model/match/match_model.dart';
import 'package:primea/model/match/match_result_option.dart';
import 'package:primea/model/match/player_rank.dart';
import 'package:primea/model/match/player_turn.dart';
import 'package:primea/tracker/paragon.dart';
import 'package:primea/tracker/paragon_avatar.dart';
import 'package:primea/util/string.dart';

class MatchModal extends StatefulWidget {
  final MatchModel match;
  final Iterable<Deck>? deckList;

  const MatchModal({
    super.key,
    required this.match,
    this.deckList,
  });

  @override
  State<StatefulWidget> createState() => MatchModalState();
}

class MatchModalState extends State<MatchModal> {
  late Paragon paragon;
  late Paragon opponentParagon;
  late PlayerTurn playerTurn;
  late Set<MatchResultOption> result;
  late DateTime matchTime;
  Deck? deck;
  Rank? rank;

  TextEditingController opponentUsernameController = TextEditingController();
  TextEditingController mmrDeltaController = TextEditingController();
  TextEditingController primeController = TextEditingController();
  TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    paragon = widget.match.paragon;
    opponentParagon = widget.match.opponentParagon;
    playerTurn = widget.match.playerTurn;
    result = {widget.match.result};
    matchTime = widget.match.matchTime;
    opponentUsernameController.text = widget.match.opponentUsername ?? '';
    mmrDeltaController.text = widget.match.mmrDelta?.toString() ?? '';
    primeController.text = widget.match.primeEarned?.toString() ?? '';
    notesController.text = widget.match.notes ?? '';
    rank = widget.match.opponentRank;
    try {
      // find the saved deck but ignore the StateError if it's not found
      deck = widget.deckList
          ?.singleWhere((deck) => deck.name == widget.match.deckName);
    } on StateError catch (_) {}
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Match Result',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => showModalBottomSheet(
                      showDragHandle: false,
                      enableDrag: false,
                      context: context,
                      builder: (context) {
                        return ParagonPicker(
                          scrollController: ScrollController(),
                          deckList: widget.deckList,
                          onParagonSelected: (paragon) {
                            setState(() {
                              this.paragon = paragon;
                            });
                            Navigator.pop(context);
                          },
                          onDeckSelected: (deck) {
                            setState(() {
                              this.deck = deck;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                    icon: ParagonAvatar(
                      paragon: paragon,
                      deck: deck,
                    ),
                  ),
                  const Text('VS'),
                  IconButton(
                    onPressed: () => showModalBottomSheet(
                      showDragHandle: false,
                      enableDrag: false,
                      context: context,
                      builder: (context) {
                        return ParagonPicker(
                          scrollController: ScrollController(),
                          onParagonSelected: (paragon) {
                            setState(() {
                              opponentParagon = paragon;
                            });
                            Navigator.pop(context);
                          },
                          onDeckSelected: (_) {},
                        );
                      },
                    ),
                    icon: ParagonAvatar(paragon: opponentParagon),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Going 1st'),
                  ),
                  Tooltip(
                    message: playerTurn.value
                        ? 'You play first'
                        : 'Opponent plays first',
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Switch(
                        value: !playerTurn.value,
                        thumbIcon: WidgetStateProperty.resolveWith((states) {
                          return Icon(
                            playerTurn == PlayerTurn.going1st
                                ? Icons.looks_one_rounded
                                : Icons.looks_two_rounded,
                            color: playerTurn == PlayerTurn.going1st
                                ? Colors.yellow[600]
                                : Colors.cyan,
                          );
                        }),
                        onChanged: (value) {
                          setState(() {
                            playerTurn = !value
                                ? PlayerTurn.going1st
                                : PlayerTurn.going2nd;
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
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Going 2nd'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                    style: ButtonStyle(
                      textStyle: WidgetStateProperty.all(
                        TextStyle(
                          fontFamily: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.fontFamily,
                          fontSize: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.fontSize,
                        ),
                      ),
                    ),
                    onPressed: () async {
                      final newDate = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2022),
                        lastDate: DateTime.now(),
                        initialDate: matchTime.toLocal(),
                      )
                        ?..toUtc();
                      if (newDate != null) {
                        setState(() {
                          matchTime = DateTime(
                            newDate.year,
                            newDate.month,
                            newDate.day,
                            matchTime.hour,
                            matchTime.minute,
                            matchTime.second,
                            matchTime.millisecond,
                            matchTime.microsecond,
                          );
                        });
                      }
                    },
                    label: Text(DateFormat.MMMMd().format(matchTime.toLocal())),
                  ),
                  TextButton.icon(
                    style: ButtonStyle(
                      textStyle: WidgetStateProperty.all(
                        TextStyle(
                          fontFamily: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.fontFamily,
                          fontSize: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.fontSize,
                        ),
                      ),
                    ),
                    label: Text(
                      DateFormat.jm().format(matchTime.toLocal()),
                    ),
                    onPressed: () async {
                      final newTime = await showTimePicker(
                        context: context,
                        initialTime:
                            TimeOfDay.fromDateTime(matchTime.toLocal()),
                      );
                      if (newTime != null) {
                        var localTime = matchTime.toLocal();

                        setState(() {
                          matchTime = DateTime(
                            localTime.year,
                            localTime.month,
                            localTime.day,
                            newTime.hour,
                            newTime.minute,
                            localTime.second,
                            localTime.millisecond,
                            localTime.microsecond,
                          );
                        });
                      }
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SegmentedButton(
                  emptySelectionAllowed: false,
                  multiSelectionEnabled: false,
                  selected: result,
                  segments: MatchResultOption.values
                      .map(
                        (gameResult) => ButtonSegment(
                          value: gameResult,
                          label: Text(gameResult.tooltip),
                        ),
                      )
                      .toList(),
                  onSelectionChanged: (selection) => setState(() {
                    result = selection;
                  }),
                ),
              ),
              SizedBox(
                width: 500,
                child: Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: 250,
                        child: TextField(
                          controller: opponentUsernameController,
                          decoration: const InputDecoration(
                            labelText: 'Opponent Username',
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: DropdownButton<Rank>(
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
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: 50,
                        child: TextField(
                          controller: mmrDeltaController,
                          textAlign: TextAlign.center,
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: true,
                            decimal: false,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^(-|)\d*'),
                            ),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'MMR',
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Badge(
                        label: Icon(
                          Icons.note_add_rounded,
                          size: 16,
                          color: Theme.of(context).colorScheme.onError,
                        ),
                        isLabelVisible: notesController.text.isNotEmpty,
                        child: TextButton.icon(
                          icon: const Icon(Icons.notes),
                          label: const Text("Notes"),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("Match Notes"),
                                  content: TextFormField(
                                    maxLines: 4,
                                    controller: notesController,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter any notes here',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Close"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: 100,
                        child: TextField(
                          controller: primeController,
                          textAlign: TextAlign.center,
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: false,
                            decimal: true,
                          ),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*'),
                            ),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'PRIME',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 64),
                    ElevatedButton(
                      onPressed: () {
                        var currentPlayer = paragon.title.isEmpty
                            ? paragon.name
                            : paragon.title;
                        var opponent = opponentParagon.title.isEmpty
                            ? opponentParagon.name
                            : opponentParagon.title;
                        ScaffoldMessenger.of(context).hideCurrentSnackBar(
                          reason: SnackBarClosedReason.hide,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            showCloseIcon: true,
                            content: Text(
                              "Saving ${currentPlayer.toTitleCase()} ${result.first.name} vs ${opponent.toTitleCase()}",
                            ),
                          ),
                        );
                        Navigator.of(context).pop(
                          MatchModel(
                            id: widget.match.id,
                            paragon: paragon,
                            opponentParagon: opponentParagon,
                            playerTurn: playerTurn,
                            result: result.first,
                            matchTime: matchTime,
                            opponentRank: rank,
                            opponentUsername:
                                opponentUsernameController.text.isEmpty
                                    ? null
                                    : opponentUsernameController.text,
                            mmrDelta: mmrDeltaController.text.isEmpty
                                ? null
                                : int.tryParse(mmrDeltaController.text),
                            primeEarned: primeController.text.isEmpty
                                ? null
                                : double.tryParse(primeController.text),
                            deckName: deck?.name,
                          ),
                        );
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
