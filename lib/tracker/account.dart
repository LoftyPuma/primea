import 'package:flutter/material.dart';
import 'package:parallel_stats/modal/match.dart';
import 'package:parallel_stats/model/match/inherited_match_list.dart';
import 'package:parallel_stats/model/match/inherited_match_results.dart';
import 'package:parallel_stats/model/match/match_result_option.dart';
import 'package:parallel_stats/model/match/player_turn.dart';
import 'package:parallel_stats/tracker/match.dart';
import 'package:parallel_stats/model/match/match_model.dart';
import 'package:parallel_stats/tracker/new_match.dart';
import 'package:parallel_stats/tracker/paragon.dart';
import 'package:parallel_stats/tracker/paragon_stack.dart';
import 'package:parallel_stats/tracker/session_summary.dart';

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
  bool loadMoreEnabled = true;

  List<bool> expandedPanels = List.empty(growable: true);

  Widget placeholder = Padding(
    padding: const EdgeInsets.all(8),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ParagonStack(
          match: MatchModel(
            paragon: Paragon.unknown,
            playerTurn: PlayerTurn.going1st,
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

    final numberOfSessions = matchList.sessionCount;
    if (expandedPanels.length < numberOfSessions) {
      setState(() {
        expandedPanels.insertAll(
          0,
          List.filled(numberOfSessions - expandedPanels.length, false),
        );
      });
    } else if (expandedPanels.length > numberOfSessions) {
      setState(() {
        expandedPanels.removeRange(numberOfSessions, expandedPanels.length);
      });
    }

    return SizedBox(
      width: 720,
      child: Column(
        children: [
          NewMatch(chosenParagon: widget.chosenParagon),
          ListenableBuilder(
            listenable: matchList,
            builder: (context, child) {
              return child!;
            },
            child: Padding(
              padding: const EdgeInsets.only(
                top: 8,
              ),
              child: ExpansionPanelList(
                dividerColor: Colors.transparent,
                materialGapSize: 16,
                expansionCallback: (panelIndex, isExpanded) {
                  setState(() {
                    expandedPanels[panelIndex] = isExpanded;
                  });
                },
                children: List.generate(numberOfSessions, (index) => index)
                    .map((index) {
                  final session = matchList.nextSession(index);
                  return ExpansionPanel(
                    isExpanded: expandedPanels[index],
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return SessionSummary(
                        sessionIndex: index,
                        isExpanded: isExpanded,
                      );
                    },
                    body: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: session?.length ?? 0,
                      itemBuilder: (context, index) {
                        final match = session!.elementAt(index);
                        return Match(
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
                            final removed = await matchList.remove(match);
                            matchResults.removeMatch(removed);
                          },
                        );
                      },
                    ),
                  );
                }).toList(),
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
