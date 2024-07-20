import 'package:flutter/material.dart';
import 'package:parallel_stats/tracker/keys.dart';
import 'package:parallel_stats/tracker/paragon.dart';

enum MatchResult {
  win(color: Colors.green, icon: Icons.check_circle, tooltip: 'Win'),
  loss(color: Colors.red, icon: Icons.cancel, tooltip: 'Loss'),
  draw(color: Colors.grey, icon: Icons.remove_circle, tooltip: 'Draw'),
  disconnect(color: Colors.orange, icon: Icons.error, tooltip: 'Disconnect');

  const MatchResult({
    required this.icon,
    required this.color,
    required this.tooltip,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
}

class TurnMatchResults {
  double win;
  double loss;
  double draw;
  double disconnect;

  TurnMatchResults()
      : win = 0,
        loss = 0,
        draw = 0,
        disconnect = 0;

  fromJson(Map<String, dynamic> json) {
    switch (json['result']) {
      case 'win':
        win += json['count'];
        break;
      case 'loss':
        loss += json['count'];
        break;
      case 'draw':
        draw += json['count'];
        break;
      case 'disconnect':
        disconnect += json['count'];
        break;
    }
  }

  double get winRate => win / total;

  double get total => win + loss + draw;
}

class MatchResults {
  TurnMatchResults onThePlay;
  TurnMatchResults onTheDraw;

  MatchResults()
      : onTheDraw = TurnMatchResults(),
        onThePlay = TurnMatchResults();

  MatchResults.fromJson(List<dynamic> json)
      : onTheDraw = TurnMatchResults(),
        onThePlay = TurnMatchResults() {
    for (final result in json) {
      switch (result['player_one']) {
        case true:
          onThePlay.fromJson(result);
          break;
        case false:
          onTheDraw.fromJson(result);
          break;
      }
    }
  }

  double get winRate => (onThePlay.win + onTheDraw.win) / total;

  double get total => onThePlay.total + onTheDraw.total;

  recordMatch(MatchModel match) {
    switch (match.result) {
      case MatchResult.win:
        match.playerOne ? onThePlay.win++ : onTheDraw.win++;
      case MatchResult.loss:
        match.playerOne ? onThePlay.loss++ : onTheDraw.loss++;
      case MatchResult.draw:
        match.playerOne ? onThePlay.draw++ : onTheDraw.draw++;
      case MatchResult.disconnect:
        onThePlay.disconnect++;
    }
  }

  void removeMatch(MatchModel match) {
    switch (match.result) {
      case MatchResult.win:
        match.playerOne ? onThePlay.win-- : onTheDraw.win--;
      case MatchResult.loss:
        match.playerOne ? onThePlay.loss-- : onTheDraw.loss--;
      case MatchResult.draw:
        match.playerOne ? onThePlay.draw-- : onTheDraw.draw--;
      case MatchResult.disconnect:
        onThePlay.disconnect--;
    }
  }

  void updateMatch(MatchModel oldMatch, MatchModel newMatch) {
    removeMatch(oldMatch);
    recordMatch(newMatch);
  }
}

class MatchModel {
  static const gamesTableName = 'games';

  final String? id;
  final Paragon paragon;
  final bool playerOne;
  final MatchResult result;
  final DateTime? dateTime;
  final String? opponentUsername;
  final Paragon opponentParagon;
  final int? mmrDelta;
  final double? primeEarned;
  final List<KeyModel> keysActivated;

  const MatchModel({
    required this.paragon,
    required this.playerOne,
    required this.result,
    this.id,
    this.dateTime,
    this.opponentUsername,
    this.opponentParagon = Paragon.unknown,
    this.mmrDelta,
    this.primeEarned,
    this.keysActivated = const [],
  });

  MatchModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        paragon = Paragon.values.byName(json['paragon']),
        playerOne = json['player_one'] ?? true,
        result = MatchResult.values.byName(json['result']),
        dateTime =
            json['game_time'] != null ? DateTime.parse(json['dateTime']) : null,
        opponentUsername = json['opponent_username'],
        opponentParagon = Paragon.values.byName(json['opponent_paragon']),
        mmrDelta = json['mmr_delta'],
        primeEarned = json['prime_earned'],
        keysActivated = List<KeyModel>.empty();
  // keysActivated = List<KeyModel>.from(json['keysActivated']);

  Map<String, dynamic> toJson() => {
        // 'id': id,
        'paragon': paragon.name,
        'player_one': playerOne,
        'result': result.name,
        'game_time': dateTime?.toIso8601String(),
        'opponent_username': opponentUsername,
        'opponent_paragon': opponentParagon.name,
        'mmr_delta': mmrDelta,
        // 'primeEarned': primeEarned,
        // 'keysActivated': keysActivated,
      };
}
