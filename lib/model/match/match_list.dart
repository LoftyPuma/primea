import 'package:flutter/material.dart';
import 'package:parallel_stats/main.dart';
import 'package:parallel_stats/model/match/match_model.dart';
import 'package:parallel_stats/tracker/match.dart';

class MatchList extends ChangeNotifier {
  final GlobalKey<AnimatedListState> _listKey;
  final List<MatchModel> _matchList;

  static const int _limit = 10;

  MatchList(GlobalKey<AnimatedListState> listKey)
      : _listKey = listKey,
        _matchList = List.empty(growable: true);

  bool get isEmpty => _matchList.isEmpty;

  int get length => _matchList.length;

  Future<void> init() async {
    final matches = await _fetchMatches();
    _matchList.addAll(matches);
    for (var _ in matches) {
      _listKey.currentState?.insertItem(
        _matchList.length - 1,
        duration: const Duration(milliseconds: 250),
      );
    }
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
        .lt('game_time', oldestMatchTimestamp.toIso8601String())
        .order(
          "game_time",
          ascending: true,
        )
        .range(0, limit);
    return matches.map((game) => MatchModel.fromJson(game)).toList();
  }

  operator [](int index) => _matchList[index];

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
    final newMatchIndex = _matchList.lastIndexWhere(
      (match) => match.matchTime!.isBefore(
        DateTime.parse(newMatchResponse['game_time']!),
      ),
    );
    _matchList.insert(newMatchIndex + 1, MatchModel.fromJson(newMatchResponse));
    // _matchList.add(newMatch);
    _listKey.currentState?.insertItem(
      newMatchIndex + 1,
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

    for (var newMatchResponse in insertedMatches) {
      final newMatchIndex = _matchList.lastIndexWhere(
        (match) => match.matchTime!.isBefore(
          DateTime.parse(newMatchResponse['game_time']!),
        ),
      );
      _matchList.insert(
          newMatchIndex + 1, MatchModel.fromJson(newMatchResponse));
      // _matchList.add(newMatch);
      _listKey.currentState?.insertItem(
        newMatchIndex + 1,
        duration: const Duration(milliseconds: 250),
      );
    }
    // _matchList.addAll(newMatches);
    // _listKey.currentState?.insertItem(
    //   _matchList.length - 1,
    //   duration: const Duration(milliseconds: 250),
    // );
    notifyListeners();
  }

  Future<void> update(MatchModel match) async {
    final index = _matchList.indexWhere((element) => element.id == match.id);
    if (index != -1 && match.id != null) {
      await supabase
          .from(MatchModel.gamesTableName)
          .update(match.toJson())
          .eq("id", match.id!);
      _matchList[index] = match;
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
    if (_matchList.length < _limit) {
      List<dynamic> olderMatches = await _fetchMatches(
        oldestMatchTimestamp: _matchList.first.matchTime,
        limit: _limit - _matchList.length - 1,
      );
      for (var match in olderMatches) {
        _matchList.insert(0, match);
        _listKey.currentState?.insertItem(
          0,
          duration: const Duration(milliseconds: 250),
        );
      }
    }
    notifyListeners();
    return removed;
  }
}
