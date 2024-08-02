import 'package:parallel_stats/model/match/match_model.dart';
import 'package:parallel_stats/model/match/match_result_option.dart';
import 'package:parallel_stats/model/match/player_turn.dart';
import 'package:parallel_stats/tracker/paragon.dart';

class MatchResult {
  final Paragon paragon;
  final Paragon opponentParagon;
  final PlayerTurn playerTurn;
  final MatchResultOption result;
  final int count;

  MatchResult({
    required this.paragon,
    required this.opponentParagon,
    required this.playerTurn,
    required this.result,
    required this.count,
  });

  MatchResult.fromJson(Map<String, dynamic> json)
      : paragon = Paragon.values.byName(json['paragon']),
        opponentParagon = Paragon.values.byName(json['opponent_paragon']),
        playerTurn =
            json['player_one'] ? PlayerTurn.going1st : PlayerTurn.going2nd,
        result = MatchResultOption.values.byName(json['result']),
        count = json['count'];
}

class MatchResultsCount {
  int win = 0;
  int loss = 0;
  int draw = 0;
  int disconnect = 0;

  int get total => win + loss + draw;

  double get winRate {
    final wr = win / total;
    return wr.isFinite ? wr : 0;
  }

  MatchResultsCount({
    this.win = 0,
    this.loss = 0,
    this.draw = 0,
    this.disconnect = 0,
  });

  MatchResultsCount.fromMatchResult(MatchResult match)
      : win = match.result == MatchResultOption.win ? match.count : 0,
        loss = match.result == MatchResultOption.loss ? match.count : 0,
        draw = match.result == MatchResultOption.draw ? match.count : 0,
        disconnect =
            match.result == MatchResultOption.disconnect ? match.count : 0;

  MatchResultsCount.fromMatchModel(MatchModel match)
      : win = match.result == MatchResultOption.win ? 1 : 0,
        loss = match.result == MatchResultOption.loss ? 1 : 0,
        draw = match.result == MatchResultOption.draw ? 1 : 0,
        disconnect = match.result == MatchResultOption.disconnect ? 1 : 0;

  void addCounts(MatchResultsCount counts) {
    win += counts.win;
    loss += counts.loss;
    draw += counts.draw;
    disconnect += counts.disconnect;
  }

  void increment(MatchResult match) {
    switch (match.result) {
      case MatchResultOption.win:
        win += match.count;
        break;
      case MatchResultOption.loss:
        loss += match.count;
        break;
      case MatchResultOption.draw:
        draw += match.count;
        break;
      case MatchResultOption.disconnect:
        disconnect += match.count;
        break;
    }
  }

  void incrementFromModel(MatchModel match) {
    switch (match.result) {
      case MatchResultOption.win:
        win += 1;
        break;
      case MatchResultOption.loss:
        loss += 1;
        break;
      case MatchResultOption.draw:
        draw += 1;
        break;
      case MatchResultOption.disconnect:
        disconnect += 1;
        break;
    }
  }

  void decrementFromModel(MatchModel match) {
    switch (match.result) {
      case MatchResultOption.win:
        win -= 1;
        win = win < 0 ? 0 : win;
        break;
      case MatchResultOption.loss:
        loss -= 1;
        loss = loss < 0 ? 0 : loss;
        break;
      case MatchResultOption.draw:
        draw -= 1;
        draw = draw < 0 ? 0 : draw;
        break;
      case MatchResultOption.disconnect:
        disconnect -= 1;
        disconnect = disconnect < 0 ? 0 : disconnect;
        break;
    }
  }
}
