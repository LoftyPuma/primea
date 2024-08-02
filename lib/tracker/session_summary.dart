import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parallel_stats/model/match/inherited_match_list.dart';
import 'package:parallel_stats/model/match/inherited_match_results.dart';
import 'package:parallel_stats/model/match/match_results.dart';
import 'package:parallel_stats/tracker/paragon_avatar.dart';
import 'package:parallel_stats/tracker/progress_card.dart';

class SessionSummary extends StatefulWidget {
  final int sessionIndex;
  final bool isExpanded;

  const SessionSummary({
    super.key,
    required this.sessionIndex,
    required this.isExpanded,
  });

  @override
  State<SessionSummary> createState() => _SessionSummaryState();
}

class _SessionSummaryState extends State<SessionSummary> {
  final MatchResults _matchResults = MatchResults();

  @override
  Widget build(BuildContext context) {
    final matchList = InheritedMatchList.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 2),
      child: ListenableBuilder(
        listenable: matchList,
        builder: (context, child) {
          final session = matchList.nextSession(widget.sessionIndex)?.toList();
          if (session == null || session.isEmpty) {
            return const SizedBox.shrink();
          }
          _matchResults.fromMatchList(session);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 1000),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: session
                    .map(
                      (match) =>
                          match.opponentParagon.parallel.color.withAlpha(100),
                    )
                    .toList()
                  ..insert(
                    0,
                    Colors.transparent,
                  )
                  ..add(Colors.transparent),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(4),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(4),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 4,
                            bottom: 4,
                            right: 8,
                            left: 8,
                          ),
                          child: Text(
                            DateFormat.MMMd().format(session.first.matchTime),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        Text(
                          "${_matchResults.count().win}-${_matchResults.count().loss}",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          "${session.fold(0, (acc, match) => acc += match.mmrDelta ?? 0).toString()} MMR",
                        ),
                        const SizedBox(height: 47),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return const LinearGradient(
                                stops: [0.9, 1],
                                colors: [Colors.white, Colors.transparent],
                              ).createShader(bounds);
                            },
                            child: SizedBox(
                              height: 76,
                              width: 500,
                              child: Stack(
                                alignment: AlignmentDirectional.centerStart,
                                children: session.reversed.indexed.map(
                                  (element) {
                                    final (index, match) = element;
                                    return AnimatedPositioned(
                                      duration:
                                          const Duration(milliseconds: 250),
                                      left: (session.length - index - 1) * 36.0,
                                      child: SizedBox.square(
                                        dimension: 72,
                                        child: ParagonAvatar(
                                          paragon: match.opponentParagon,
                                        ),
                                      ),
                                    );
                                  },
                                ).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            "${session.length} Match${session.length > 1 ? "es" : ""}",
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                    InheritedMatchResults(
                      matchResults: _matchResults,
                      child: const ProgressCard(
                        title: "Win Rate",
                        height: 150,
                        spacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
