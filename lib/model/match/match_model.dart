import 'package:primea/model/deck/deck.dart';
import 'package:primea/model/match/match_result_option.dart';
import 'package:primea/model/match/player_rank.dart';
import 'package:primea/model/match/player_turn.dart';
import 'package:primea/tracker/keys.dart';
import 'package:primea/tracker/paragon.dart';

class MatchModel {
  static const gamesTableName = 'games';

  final Paragon paragon;
  final Paragon opponentParagon;
  final PlayerTurn playerTurn;
  final MatchResultOption result;
  final DateTime matchTime;
  final String? id;
  final DateTime? createdAt;
  final String? opponentUsername;
  final Rank? opponentRank;
  final int? mmrDelta;
  final double? primeEarned;
  final String? deckId;
  final Deck? deck;
  final int? season;
  final String? notes;
  final List<KeyModel> keysActivated;

  const MatchModel({
    required this.paragon,
    required this.playerTurn,
    required this.result,
    required this.matchTime,
    this.id,
    this.createdAt,
    this.opponentUsername,
    this.opponentParagon = Paragon.unknown,
    this.opponentRank,
    this.mmrDelta,
    this.primeEarned,
    this.deckId,
    this.deck,
    this.season,
    this.notes,
    this.keysActivated = const [],
  });

  MatchModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        createdAt = json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : null,
        matchTime = DateTime.parse(json['game_time']),
        opponentUsername = json['opponent_username'],
        season = json['season'],
        mmrDelta = json['mmr_delta'],
        primeEarned =
            json['prime_estimate'] != null ? json['prime_estimate'] + 0.0 : 0,
        keysActivated = List<KeyModel>.empty(),
        paragon = Paragon.values.byName(json['paragon']),
        opponentParagon = Paragon.values.byName(json['opponent_paragon']),
        opponentRank = json['opponent_rank'] != null
            ? Rank.values.byName(json['opponent_rank'])
            : null,
        playerTurn =
            json['player_one'] ? PlayerTurn.going1st : PlayerTurn.going2nd,
        result = MatchResultOption.values.byName(json['result']),
        deckId = json['deck_id'],
        deck = json['deck'] is Deck ? json['deck'] : null,
        notes = json['notes'];

  Map<String, dynamic> toJson() {
    final json = {
      'paragon': paragon.name,
      'player_one': playerTurn.value,
      'result': result.name,
      'game_time': matchTime.toUtc().toIso8601String(),
      'opponent_username': opponentUsername,
      'opponent_paragon': opponentParagon.name,
      'opponent_rank': opponentRank?.name,
      'mmr_delta': mmrDelta,
      'prime_estimate': primeEarned,
      'deck_id': deckId,
      'notes': notes,
      // 'keysActivated': keysActivated,
    };
    if (id != null) {
      json['id'] = id;
    }
    return json;
  }

  @override
  bool operator ==(Object other) {
    return other is MatchModel &&
        paragon == other.paragon &&
        opponentParagon == other.opponentParagon &&
        playerTurn == other.playerTurn &&
        result == other.result &&
        matchTime == other.matchTime &&
        id == other.id &&
        createdAt == other.createdAt &&
        opponentUsername == other.opponentUsername &&
        opponentRank == other.opponentRank &&
        mmrDelta == other.mmrDelta &&
        primeEarned == other.primeEarned &&
        deckId == other.deckId &&
        keysActivated == other.keysActivated;
  }

  @override
  int get hashCode => Object.hash(
        paragon,
        opponentParagon,
        playerTurn,
        result,
        matchTime,
        id,
        createdAt,
        opponentUsername,
        opponentRank,
        mmrDelta,
        primeEarned,
        deckId,
        keysActivated,
      );
}
