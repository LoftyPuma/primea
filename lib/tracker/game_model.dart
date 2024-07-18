import 'package:flutter/material.dart';
import 'package:parallel_stats/tracker/keys.dart';
import 'package:parallel_stats/tracker/paragon.dart';

enum GameResult {
  win(color: Colors.green, icon: Icons.check_circle, tooltip: 'Win'),
  loss(color: Colors.red, icon: Icons.cancel, tooltip: 'Loss'),
  draw(color: Colors.grey, icon: Icons.remove_circle, tooltip: 'Draw'),
  disconnect(color: Colors.orange, icon: Icons.error, tooltip: 'Disconnect');

  const GameResult({
    required this.icon,
    required this.color,
    required this.tooltip,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
}

class GameModel {
  static const gamesTableName = 'games';

  final String? id;
  final Paragon paragon;
  final bool playerOne;
  final GameResult result;
  final DateTime? dateTime;
  final String? opponentUsername;
  final Paragon opponentParagon;
  final int? mmrDelta;
  final double? primeEarned;
  final List<KeyModel> keysActivated;

  GameModel({
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

  GameModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        paragon = json['paragon'],
        playerOne = json['player_one'],
        result = json['result'],
        dateTime =
            json['game_time'] != null ? DateTime.parse(json['dateTime']) : null,
        opponentUsername = json['opponent_username'],
        opponentParagon = json['opponent_paragon'],
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
