import 'package:flutter/foundation.dart';
import 'package:primea/main.dart';
import 'package:primea/model/match/match_model.dart';
import 'package:primea/model/match/match_result.dart';
import 'package:primea/model/match/player_turn.dart';
import 'package:primea/tracker/paragon.dart';
import 'package:primea/util/analytics.dart';

class MatchResults extends ChangeNotifier {
  Map<PlayerTurn, Map<Paragon, Map<Paragon, MatchResultsCount>>> _matchupCounts;

  MatchResults() : _matchupCounts = {};

  void fromMatchList(List<MatchModel> matches) {
    _matchupCounts = {};
    for (final match in matches) {
      recordMatch(match);
    }
  }

  bool get isEmpty => _matchupCounts.isEmpty;

  bool initialized = false;

  Future<void> init() async {
    try {
      final matchResults = await _fetchMatchResults();
      _matchupCounts = _initializeMatchupCounts(matchResults);
      initialized = true;
      notifyListeners();
    } on Error catch (e) {
      Analytics.instance.trackEvent("initError", {
        "error": e.toString(),
        "class": "matchResults",
        "stackTrace": e.stackTrace.toString(),
      });
    }
  }

  Future<Set<MatchResult>> _fetchMatchResults() async {
    var response = await supabase.from(MatchModel.gamesTableName).select(
          "count(), paragon, opponent_paragon, result, player_one",
        );
    return MatchResults._fromJson(response);
  }

  static Set<MatchResult> _fromJson(List<dynamic> json) {
    final results = <MatchResult>{};
    for (final result in json) {
      results.add(MatchResult.fromJson(result));
    }
    return results;
  }

  Map<PlayerTurn, Map<Paragon, Map<Paragon, MatchResultsCount>>>
      _initializeMatchupCounts(
    Set<MatchResult> matchResults,
  ) {
    Map<PlayerTurn, Map<Paragon, Map<Paragon, MatchResultsCount>>>
        matchupCounts = {};

    for (final match in matchResults) {
      if (!matchupCounts.containsKey(match.playerTurn)) {
        // The playerTurn is not in the map
        matchupCounts[match.playerTurn] = {
          match.paragon: {
            match.opponentParagon: MatchResultsCount.fromMatchResult(match),
          },
        };
      } else if (!matchupCounts[match.playerTurn]!.containsKey(match.paragon)) {
        // The playerTurn is in the map, but the paragon is not
        matchupCounts[match.playerTurn]![match.paragon] = {
          match.opponentParagon: MatchResultsCount.fromMatchResult(match),
        };
      } else if (!matchupCounts[match.playerTurn]![match.paragon]!
          .containsKey(match.opponentParagon)) {
        // The playerTurn and paragon are in the map, but the opponentParagon is not
        matchupCounts[match.playerTurn]![match.paragon]![
            match.opponentParagon] = MatchResultsCount.fromMatchResult(match);
      } else {
        // The playerTurn, paragon, and opponentParagon are in the map, increment the count
        matchupCounts[match.playerTurn]![match.paragon]![match.opponentParagon]!
            .increment(match);
      }
    }
    return matchupCounts;
  }

  MatchResultsCount _sumOpponentParagonMap(
    Map<Paragon, MatchResultsCount> opponentParagons, {
    Paragon? selectedParagon,
  }) {
    if (selectedParagon == null) {
      // sum the matches for all opponent paragons
      MatchResultsCount total = MatchResultsCount();
      for (final opponentParagonEntry in opponentParagons.entries) {
        total.addCounts(opponentParagonEntry.value);
      }
      return total;
    } else if (selectedParagon.title.isEmpty) {
      // sum the matches for all opponent paragons in teh selected Parallel
      MatchResultsCount total = MatchResultsCount();
      for (final opponentParagonEntry in opponentParagons.entries.where(
        (entry) => entry.key.parallel == selectedParagon.parallel,
      )) {
        total.addCounts(opponentParagonEntry.value);
      }
      return total;
    } else {
      // sum the matches for the selected opponent paragon
      return opponentParagons[selectedParagon] ?? MatchResultsCount();
    }
  }

  MatchResultsCount _sumParagonMap(
    Map<Paragon, Map<Paragon, MatchResultsCount>> paragons, {
    Paragon? selectedParagon,
    Paragon? selectedOpponentParagon,
  }) {
    if (selectedParagon == null) {
      // sum the matches for all paragons the player has used
      MatchResultsCount total = MatchResultsCount();
      for (final paragonEntry in paragons.entries) {
        total.addCounts(
          _sumOpponentParagonMap(
            paragonEntry.value,
            selectedParagon: selectedOpponentParagon,
          ),
        );
      }
      return total;
    } else if (selectedParagon.title.isEmpty) {
      // sum the matches for all paragons in the selected Parallel
      MatchResultsCount total = MatchResultsCount();
      for (final paragonEntry in paragons.entries.where(
        (entry) => entry.key.parallel == selectedParagon.parallel,
      )) {
        total.addCounts(
          _sumOpponentParagonMap(
            paragonEntry.value,
            selectedParagon: selectedOpponentParagon,
          ),
        );
      }
      return total;
    } else {
      // sum the matches for the selected player paragon
      return _sumOpponentParagonMap(
        paragons[selectedParagon] ?? {},
        selectedParagon: selectedOpponentParagon,
      );
    }
  }

  MatchResultsCount count({
    Paragon? paragon,
    Paragon? opponentParagon,
    PlayerTurn? playerTurn,
  }) {
    if (playerTurn != null) {
      return _sumParagonMap(
        _matchupCounts[playerTurn] ?? {},
        selectedParagon: paragon,
        selectedOpponentParagon: opponentParagon,
      );
    }
    MatchResultsCount total = MatchResultsCount();
    for (final turnEntry in _matchupCounts.entries) {
      total.addCounts(
        _sumParagonMap(
          turnEntry.value,
          selectedParagon: paragon,
          selectedOpponentParagon: opponentParagon,
        ),
      );
    }
    return total;
  }

  void recordMatch(MatchModel match) {
    if (!_matchupCounts.containsKey(match.playerTurn)) {
      // The playerTurn is not in the map
      _matchupCounts[match.playerTurn] = {
        match.paragon: {
          match.opponentParagon: MatchResultsCount.fromMatchModel(match),
        },
      };
    } else if (!_matchupCounts[match.playerTurn]!.containsKey(match.paragon)) {
      // The playerTurn is in the map, but the paragon is not
      _matchupCounts[match.playerTurn]![match.paragon] = {
        match.opponentParagon: MatchResultsCount.fromMatchModel(match),
      };
    } else if (!_matchupCounts[match.playerTurn]![match.paragon]!
        .containsKey(match.opponentParagon)) {
      // The playerTurn and paragon are in the map, but the opponentParagon is not
      _matchupCounts[match.playerTurn]![match.paragon]![match.opponentParagon] =
          MatchResultsCount.fromMatchModel(match);
    } else {
      // The playerTurn, paragon, and opponentParagon are in the map, increment the count
      _matchupCounts[match.playerTurn]![match.paragon]![match.opponentParagon]!
          .incrementFromModel(match);
    }
    notifyListeners();
  }

  void removeMatch(MatchModel match) {
    _matchupCounts[match.playerTurn]?[match.paragon]?[match.opponentParagon]
        ?.decrementFromModel(match);
    notifyListeners();
  }

  void updateMatch(MatchModel oldMatch, MatchModel newMatch) {
    removeMatch(oldMatch);
    recordMatch(newMatch);
    notifyListeners();
  }

  void clear() {
    _matchupCounts = {};
    notifyListeners();
  }
}
