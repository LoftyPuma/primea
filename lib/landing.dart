import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:primea/main.dart';
import 'package:primea/tracker/paragon.dart';
import 'package:primea/util/analytics.dart';

class Landing extends StatefulWidget {
  const Landing({super.key});

  @override
  State<StatefulWidget> createState() => _LandingState();
}

class ParagonCounts {
  Paragon paragon;
  int wins;
  int matches;

  ParagonCounts({
    required this.paragon,
    this.wins = 0,
    this.matches = 0,
  });
}

class _LandingState extends State<Landing> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final Future<List<dynamic>> paragonPopularity = supabase
      .rpc<List<dynamic>>(
        'calculate_paragon_percentages',
      )
      .inFilter(
        'paragon',
        Paragon.values
            .where((paragon) =>
                paragon != Paragon.unknown && paragon.title.isNotEmpty)
            .map((paragon) => paragon.name)
            .toList(),
      )
      .limit(5);

  final Future<List<dynamic>> opponentParagonPopularity = supabase
      .rpc<List<dynamic>>(
        'calculate_opponent_paragon_percentages',
      )
      .inFilter(
        'opponent_paragon',
        Paragon.values
            .where((paragon) =>
                paragon != Paragon.unknown && paragon.title.isNotEmpty)
            .map((paragon) => paragon.name)
            .toList(),
      )
      .limit(5);

  final Future<Iterable<ParagonCounts>> paragonWinRates = () async {
    final paragonCountFutures = await Future.wait(
      [
        supabase.rpc<List<Map<String, dynamic>>>('calculate_paragon_win_count'),
        supabase
            .rpc<List<Map<String, dynamic>>>('calculate_paragon_match_count'),
      ],
    );

    final wins = paragonCountFutures[0];
    final matches = paragonCountFutures[1];
    final Map<Paragon, ParagonCounts> winRates = {};

    for (var win in wins) {
      final paragon = Paragon.values.byName(win['paragon'] as String);
      winRates
          .putIfAbsent(paragon, () => ParagonCounts(paragon: paragon))
          .wins += win['count'] as int;
    }

    for (var match in matches) {
      final paragon = Paragon.values.byName(match['paragon'] as String);
      winRates
          .putIfAbsent(paragon, () => ParagonCounts(paragon: paragon))
          .matches += match['count'] as int;
    }

    return winRates.entries
        .sorted((a, b) => (b.value.wins / b.value.matches)
            .compareTo(a.value.wins / a.value.matches))
        .map((entry) => entry.value);
  }();

  @override
  Widget build(BuildContext context) {
    Analytics.instance.trackEvent("load", {'page': 'landing'});
    super.build(context);
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFDEF141).withAlpha(200),
                  const Color(0xFFDEF141).withAlpha(10),
                ],
              ),
            ),
            child: Center(
              child: FittedBox(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Primea',
                        style:
                            Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryFixed,
                          fontVariations: [const FontVariation.weight(600)],
                        ),
                      ),
                      Text(
                        'Track, Analyze, Dominate',
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryFixed,
                          fontVariations: [const FontVariation.weight(500)],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Wrap(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                constraints: const BoxConstraints(
                  maxWidth: 500,
                ),
                margin: const EdgeInsets.all(8),
                child: FutureBuilder(
                  future: paragonPopularity,
                  builder: (context, snapshot) {
                    return ListView.builder(
                      itemCount: 6,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return const ListTile(
                            title: Text(
                              'Most Used Paragons',
                            ),
                          );
                        }
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          final element = snapshot.data![index - 1];
                          final paragon = Paragon.values
                              .byName(element['paragon'] as String);
                          final percentage = element['percentage'] as double;
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHigh,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  paragon.parallel.color,
                                  Theme.of(context)
                                      .colorScheme
                                      .surfaceContainer
                                      .withAlpha(200),
                                ],
                                stops: [0.0, percentage * 2],
                              ),
                            ),
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              leading: Image.asset(
                                paragon.image!,
                                width: 50,
                                height: 50,
                              ),
                              title: Text(
                                paragon.title,
                                style: const TextStyle(
                                  shadows: [
                                    Shadow(
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                              ),
                              subtitle: Text(
                                '${(percentage * 100).toStringAsFixed(2)}%',
                                style: const TextStyle(
                                  shadows: [
                                    Shadow(
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          throw snapshot.error!;
                        } else {
                          return ListTile(
                            title: const Text('Loading...'),
                            subtitle: LinearProgressIndicator(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                constraints: const BoxConstraints(
                  maxWidth: 500,
                ),
                margin: const EdgeInsets.all(8),
                child: FutureBuilder(
                  future: opponentParagonPopularity,
                  builder: (context, snapshot) {
                    return ListView.builder(
                      itemCount: 6,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return const ListTile(
                            title: Text(
                              'Most Faced Paragons',
                            ),
                          );
                        }
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          final element = snapshot.data![index - 1];
                          final paragon = Paragon.values
                              .byName(element['opponent_paragon'] as String);
                          final percentage = element['percentage'] as double;
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHigh,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  paragon.parallel.color,
                                  Theme.of(context)
                                      .colorScheme
                                      .surfaceContainer
                                      .withAlpha(200),
                                ],
                                stops: [0.0, percentage * 2],
                              ),
                            ),
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              leading: Image.asset(
                                paragon.image!,
                                width: 50,
                                height: 50,
                              ),
                              title: Text(
                                paragon.title,
                                style: const TextStyle(
                                  shadows: [
                                    Shadow(
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                              ),
                              subtitle: Text(
                                '${(percentage * 100).toStringAsFixed(2)}%',
                                style: const TextStyle(
                                  shadows: [
                                    Shadow(
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          throw snapshot.error!;
                        } else {
                          return ListTile(
                            title: const Text('Loading...'),
                            subtitle: LinearProgressIndicator(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            constraints: const BoxConstraints(
              maxWidth: 500,
            ),
            margin: const EdgeInsets.all(8),
            child: FutureBuilder(
              future: paragonWinRates,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const ListTile(
                          title: Text(
                            'Paragon Win Rates',
                          ),
                        );
                      }
                      if (index > snapshot.data!.length) {
                        return null;
                      }
                      final counts = snapshot.data!.elementAt(index - 1);
                      final paragon = counts.paragon;
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              paragon.parallel.color,
                              Theme.of(context).colorScheme.surfaceContainer,
                            ],
                            stops: [
                              0.0,
                              (counts.wins / counts.matches),
                            ],
                          ),
                        ),
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          leading: Image.asset(
                            paragon.image!,
                            width: 50,
                            height: 50,
                          ),
                          title: Text(
                            paragon.title,
                            style: const TextStyle(
                              shadows: [
                                Shadow(
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                          ),
                          subtitle: Text(
                            'Matches: ${counts.matches}',
                            style: const TextStyle(
                              shadows: [
                                Shadow(
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                          ),
                          trailing: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      "${((counts.wins / counts.matches) * 100).toStringAsFixed(1)}%\n",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                    shadows: [
                                      const Shadow(
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                ),
                                TextSpan(
                                  text: "Win Rate",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                    shadows: [
                                      const Shadow(
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  throw snapshot.error!;
                } else {
                  return ListTile(
                    title: const Text('Loading...'),
                    subtitle: LinearProgressIndicator(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                  );
                }
              },
            ),
          ),
          if (supabase.auth.currentSession != null)
            const SizedBox(
              height: 90,
            ),
        ],
      ),
    );
  }
}
