import 'package:flutter/material.dart';
import 'package:primea/model/match/match_results.dart';

class InheritedMatchResults extends InheritedNotifier<MatchResults> {
  const InheritedMatchResults({
    super.key,
    required super.child,
    required MatchResults matchResults,
  }) : super(notifier: matchResults);

  static MatchResults of(BuildContext context) {
    final matchResults =
        context.dependOnInheritedWidgetOfExactType<InheritedMatchResults>();
    assert(matchResults?.notifier != null,
        'No InheritedMatchResults found in context');
    return matchResults!.notifier!;
  }
}
