import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:parallel_stats/main.dart';
import 'package:parallel_stats/model/match/match_model.dart';
import 'package:parallel_stats/model/match/match_results.dart';
import 'package:parallel_stats/tracker/match.dart';

class MatchList extends ChangeNotifier {
  final MatchResults matchResults;
  final GlobalKey<AnimatedListState> _listKey;
  final List<MatchModel> _matchList;

  static const int _limit = 10;

  int _totalMatches = 0;

  MatchList(GlobalKey<AnimatedListState> listKey, this.matchResults)
      : _listKey = listKey,
        _matchList = List.empty(growable: true);

  int get limit => _limit;

  bool get isEmpty => _matchList.isEmpty;

  int get length => _matchList.length;

  int get total => _totalMatches;

  operator [](int index) => _matchList[index];

  Future<void> init() async {
    final matches = await _fetchMatches();
    _matchList.addAll(matches);
    _listKey.currentState?.insertAllItems(0, matches.length,
        duration: const Duration(milliseconds: 250));

    notifyListeners();
  }

  Future<List<MatchModel>> _fetchMatches({
    DateTime? oldestMatchTimestamp,
    int limit = _limit,
  }) async {
    oldestMatchTimestamp ??= DateTime.now().toUtc();
    var matches = await supabase
        .from(MatchModel.gamesTableName)
        .select()
        .lt('game_time',
            oldestMatchTimestamp.subtract(const Duration(milliseconds: 10)))
        .order(
          "game_time",
        )
        .limit(limit)
        .count();
    _totalMatches = matches.count;
    return matches.data.map((game) => MatchModel.fromJson(game)).toList();
  }

  Future<int> loadMore() async {
    final oldestMatchTimestamp = _matchList.isNotEmpty
        ? _matchList.last.matchTime
        : DateTime.now().toUtc();
    final newMatches = await _fetchMatches(
      oldestMatchTimestamp: oldestMatchTimestamp,
    );
    if (kDebugMode) {
      print(
        "Loaded ${newMatches.length} more matches from $oldestMatchTimestamp",
      );
    }
    final oldLength = _matchList.length;
    _matchList.addAll(newMatches);
    _listKey.currentState?.insertAllItems(
      oldLength,
      newMatches.length,
      duration: const Duration(milliseconds: 250),
    );
    notifyListeners();
    return newMatches.length;
  }

  Future<void> add(MatchModel newMatch) async {
    final newMatchResponse = await supabase
        .from(MatchModel.gamesTableName)
        .insert(
          [
            newMatch.toJson(),
          ],
          defaultToNull: false,
        )
        .select()
        .limit(1)
        .single();
    final newMatchModel = MatchModel.fromJson(newMatchResponse);
    _matchList.insert(0, newMatchModel);
    matchResults.recordMatch(newMatchModel);
    _totalMatches++;
    _listKey.currentState?.insertItem(
      0,
      duration: const Duration(milliseconds: 250),
    );
    notifyListeners();
  }

  Future<void> addAll(List<MatchModel> newMatches) async {
    final List<dynamic> insertedMatches = await supabase
        .from(MatchModel.gamesTableName)
        .insert(
          newMatches.map((match) => match.toJson()).toList(),
          defaultToNull: false,
        )
        .select();

    final currentLength = _matchList.length;
    _matchList.addAll(insertedMatches.map(
      (match) => MatchModel.fromJson(match),
    ));
    _listKey.currentState?.insertAllItems(
      currentLength,
      insertedMatches.length,
      duration: const Duration(milliseconds: 250),
    );
    _totalMatches += insertedMatches.length;
    notifyListeners();
  }

  Future<void> update(MatchModel match) async {
    final index = _matchList.indexWhere((element) => element.id == match.id);
    if (index != -1 && match.id != null) {
      await supabase
          .from(MatchModel.gamesTableName)
          .update(match.toJson())
          .eq("id", match.id!);

      matchResults.updateMatch(_matchList[index], match);

      // if the match time has changed, we need to remove and reinsert the match
      if (_matchList[index].matchTime != match.matchTime) {
        final removed = _matchList.removeAt(index);
        _listKey.currentState?.removeItem(
          index,
          (context, animation) => SizeTransition(
            sizeFactor: animation,
            child: Match(
              match: removed,
              onEdit: null,
              onDelete: null,
            ),
          ),
          duration: const Duration(milliseconds: 250),
        );

        final closestIndex = _matchList.indexWhere(
          (element) => element.matchTime.isBefore(match.matchTime),
        );
        _matchList.insert(closestIndex, removed);
        _listKey.currentState?.insertItem(
          closestIndex,
          duration: const Duration(milliseconds: 250),
        );
      } else {
        _matchList[index] = match;
      }

      notifyListeners();
    }
  }

  Future<MatchModel> removeAt(int index) async {
    final removed = _matchList.removeAt(index);
    await supabase
        .from(MatchModel.gamesTableName)
        .delete()
        .eq("id", removed.id!)
        .select();
    _totalMatches--;
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: Match(
          match: removed,
          onEdit: null,
          onDelete: null,
        ),
      ),
      duration: const Duration(milliseconds: 250),
    );
    notifyListeners();
    return removed;
  }
}
