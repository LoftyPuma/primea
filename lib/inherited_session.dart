import 'package:flutter/material.dart';
import 'package:parallel_stats/main.dart';
import 'package:parallel_stats/model/match/inherited_match_list.dart';
import 'package:parallel_stats/model/match/inherited_match_results.dart';
import 'package:parallel_stats/model/match/match_list.dart';
import 'package:parallel_stats/model/match/match_results.dart';
import 'package:parallel_stats/tracker/paragon.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InheritedSession extends InheritedModel<String> {
  final Session? session;

  const InheritedSession({
    super.key,
    required super.child,
    required this.session,
  });

  static InheritedSession? maybeOf(BuildContext context, [String? aspect]) {
    return InheritedModel.inheritFrom<InheritedSession>(
      context,
      aspect: aspect,
    );
  }

  static InheritedSession of(BuildContext context, [String? aspect]) {
    final session = maybeOf(context, aspect);
    assert(session != null, 'No InheritedSession found in context');
    return session!;
  }

  @override
  bool updateShouldNotify(InheritedSession oldWidget) {
    return oldWidget.session != session;
  }

  @override
  bool updateShouldNotifyDependent(
    InheritedSession oldWidget,
    Set<String> dependencies,
  ) {
    return oldWidget.session != session;
  }
}

class InheritedSessionWidget extends StatefulWidget {
  final Widget child;

  const InheritedSessionWidget({
    super.key,
    required this.child,
  });

  @override
  State<InheritedSessionWidget> createState() => _InheritedSessionState();
}

class _InheritedSessionState extends State<InheritedSessionWidget> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  Paragon chosenParagon = Paragon.unknown;
  Session? session = supabase.auth.currentSession;
  MatchResults matchResults = MatchResults();
  late MatchList matchList;

  handleAuthStateChange(AuthState data) async {
    setState(() {
      session = data.session;
    });
    if (session != null && !session!.isExpired) {
      if (matchResults.isEmpty) {
        await matchResults.init();
      }
      if (matchList.isEmpty) {
        await matchList.init();
      }
    }
    supabase.auth.onAuthStateChange.listen(handleAuthStateChange);
  }

  @override
  void initState() {
    matchList = MatchList(_listKey, matchResults);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InheritedSession(
      session: session,
      child: InheritedMatchList(
        matchList: matchList,
        child: InheritedMatchResults(
          matchResults: matchResults,
          child: widget.child,
        ),
      ),
    );
  }
}
