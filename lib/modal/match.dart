import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:parallel_stats/modal/paragon_picker.dart';
import 'package:parallel_stats/model/match/match_model.dart';
import 'package:parallel_stats/model/match/match_result_option.dart';
import 'package:parallel_stats/model/match/player_turn.dart';
import 'package:parallel_stats/tracker/paragon.dart';
import 'package:parallel_stats/tracker/paragon_avatar.dart';
import 'package:parallel_stats/util/string.dart';

class MatchModal extends StatefulWidget {
  final MatchModel match;

  const MatchModal({
    super.key,
    required this.match,
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
  TextEditingController opponentUsernameController = TextEditingController();
  TextEditingController mmrDeltaController = TextEditingController();
  TextEditingController primeController = TextEditingController();

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
                          onParagonSelected: (paragon) {
                            setState(() {
                              this.paragon = paragon;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                    icon: ParagonAvatar(paragon: paragon),
                  ),
                  const Text('VS'),
                  IconButton(
                    onPressed: () => showModalBottomSheet(
                      showDragHandle: false,
                      enableDrag: false,
                      context: context,
                      builder: (context) {
                        return ParagonPicker(
                          onParagonSelected: (paragon) {
                            setState(() {
                              opponentParagon = paragon;
                            });
                            Navigator.pop(context);
                          },
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
                      final newDate = (await showDatePicker(
                        context: context,
                        firstDate: DateTime(2022),
                        lastDate: DateTime.now(),
                        initialDate: matchTime.toLocal(),
                      ))
                          ?.toUtc();
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
                    onPressed: () async {
                      final newTime = await showTimePicker(
                        context: context,
                        initialTime:
                            TimeOfDay.fromDateTime(matchTime.toLocal()),
                      );
                      if (newTime != null) {
                        setState(() {
                          matchTime = DateTime(
                            matchTime.year,
                            matchTime.month,
                            matchTime.day,
                            newTime.hour,
                            newTime.minute,
                            matchTime.second,
                            matchTime.millisecond,
                            matchTime.microsecond,
                          );
                        });
                      }
                    },
                    label: Text(
                      DateFormat.jm().format(matchTime.toLocal()),
                    ),
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
