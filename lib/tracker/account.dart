import 'package:flutter/material.dart';
import 'package:primea/modal/match.dart';
import 'package:primea/model/deck/deck.dart';
import 'package:primea/model/match/inherited_match_list.dart';
import 'package:primea/model/match/inherited_match_results.dart';
import 'package:primea/model/match/match_result_option.dart';
import 'package:primea/model/match/player_turn.dart';
import 'package:primea/tracker/match.dart';
import 'package:primea/model/match/match_model.dart';
import 'package:primea/tracker/new_match.dart';
import 'package:primea/tracker/paragon.dart';
import 'package:primea/tracker/paragon_stack.dart';
import 'package:primea/tracker/session_summary.dart';
import 'package:primea/util/analytics.dart';

class Account extends StatefulWidget {
  final GlobalKey<AnimatedListState> listKey;
  final Paragon chosenParagon;
  final Iterable<Deck>? decks;
  final Deck? chosenDeck;

  const Account({
    super.key,
    required this.listKey,
    required this.chosenParagon,
    this.chosenDeck,
    this.decks,
  });

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  bool loadMoreEnabled = true;

  List<bool> expandedPanels = List.empty(growable: true);
  List<GlobalKey> repaintKeys = List.empty(growable: true);

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
    Analytics.instance.trackEvent("load", {"page": "account"});
    final matchResults = InheritedMatchResults.of(context);
    final matchList = InheritedMatchList.of(context);

    final numberOfSessions = matchList.sessionCount;
    if (expandedPanels.length < numberOfSessions) {
      setState(() {
        expandedPanels.insertAll(
          0,
          List.filled(numberOfSessions - expandedPanels.length, false),
        );
        repaintKeys.insertAll(
          0,
          List.generate(
            numberOfSessions - repaintKeys.length,
            (index) => GlobalKey(),
          ),
        );
      });
    } else if (expandedPanels.length > numberOfSessions) {
      setState(() {
        expandedPanels.removeRange(numberOfSessions, expandedPanels.length);
        repaintKeys.removeRange(numberOfSessions, repaintKeys.length);
      });
    }

    return SizedBox(
      width: 720,
      child: Column(
        children: [
          NewMatch(
            chosenParagon: widget.chosenParagon,
            chosenDeck: widget.chosenDeck,
          ),
          ListenableBuilder(
            listenable: matchList,
            builder: (context, child) {
              return Padding(
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
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            RepaintBoundary(
                              key: repaintKeys[index],
                              child: SessionSummary(
                                sessionIndex: index,
                                isExpanded: isExpanded,
                              ),
                            ),
                            // TODO: Add share button
                            // Positioned(
                            //   top: 8,
                            //   right: 8,
                            //   child: IconButton(
                            //     icon: const Icon(Icons.ios_share),
                            //     onPressed: () async {
                            //       RenderRepaintBoundary? boundary =
                            //           repaintKeys[index]
                            //                   .currentContext
                            //                   ?.findRenderObject()
                            //               as RenderRepaintBoundary;
                            //       final image = await boundary.toImage();
                            //       final ByteData? byteData = await image
                            //           .toByteData(format: ImageByteFormat.png);
                            //       final Uint8List pngBytes =
                            //           byteData!.buffer.asUint8List();
                            //       print("${pngBytes.length / 1000} kb");
                            //       if (context.mounted) {
                            //         showDialog(
                            //           context: context,
                            //           builder: (context) {
                            //             return Image.memory(pngBytes);
                            //           },
                            //         );
                            //       }
                            //     },
                            //   ),
                            // ),
                          ],
                        );
                      },
                      body: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: session?.length ?? 0,
                        itemBuilder: (context, index) {
                          final match = session!.elementAt(index);
                          Deck? deck;
                          try {
                            deck = widget.decks?.singleWhere(
                                (deck) => deck.name == match.deckName);
                          } on StateError catch (_) {}
                          return Match(
                            key: ValueKey(
                                match.id! + match.matchTime.toString()),
                            match: match,
                            deck: deck,
                            onEdit: (context) async {
                              final updatedMatch = await showDialog<MatchModel>(
                                context: context,
                                builder: (context) {
                                  return MatchModal(
                                    match: match,
                                    deckList: widget.decks,
                                  );
                                },
                              );
                              final start = DateTime.now();
                              if (updatedMatch != null &&
                                  updatedMatch.id != null) {
                                await matchList.update(updatedMatch);
                              }
                              Analytics.instance.trackEvent("updateMatch", {
                                "duration": DateTime.now()
                                    .difference(start)
                                    .inMilliseconds,
                              });
                            },
                            onDelete: (context) async {
                              final start = DateTime.now();
                              final removed = await matchList.remove(match);
                              matchResults.removeMatch(removed);
                              Analytics.instance.trackEvent("deleteMatch", {
                                "duration": DateTime.now()
                                    .difference(start)
                                    .inMilliseconds,
                              });
                            },
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          if (!matchList.initialized || !matchResults.initialized)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),
          if (matchList.initialized && matchResults.initialized)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Tooltip(
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
            ),
          const SizedBox(
            height: 80,
          ),
        ],
      ),
    );
  }
}
