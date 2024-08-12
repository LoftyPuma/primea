import 'package:flutter/material.dart';
import 'package:primea/model/match/match_list.dart';

class InheritedMatchList extends InheritedNotifier<MatchList> {
  const InheritedMatchList({
    super.key,
    required super.child,
    required MatchList matchList,
  }) : super(notifier: matchList);

  static MatchList of(BuildContext context) {
    final matchList =
        context.dependOnInheritedWidgetOfExactType<InheritedMatchList>();
    assert(
        matchList?.notifier != null, 'No InheritedMatchList found in context');
    return matchList!.notifier!;
  }
}
