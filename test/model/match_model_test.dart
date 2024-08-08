import 'package:flutter_test/flutter_test.dart';
import 'package:parallel_stats/model/match/match_model.dart';
import 'package:parallel_stats/model/match/match_result_option.dart';
import 'package:parallel_stats/model/match/player_rank.dart';
import 'package:parallel_stats/model/match/player_turn.dart';
import 'package:parallel_stats/tracker/paragon.dart';

void main() {
  group("Test MatchModel creation", () {
    test("MatchModel.fromJson", () {
      // Arrange
      final Map<String, dynamic> json = {
        'id': '1',
        'created_at': '2021-10-10T10:10:10.000Z',
        'game_time': '2021-10-10T10:10:10.000Z',
        'opponent_username': 'opponent',
        'mmr_delta': 10,
        'prime_estimate': 0.053,
        'paragon': 'jahn',
        'opponent_paragon': 'aetio',
        'opponent_rank': 'gold',
        'player_one': true,
        'result': 'win',
      };

      // Act
      final matchModel = MatchModel.fromJson(json);

      // Assert
      expect(matchModel.id, '1');
      expect(matchModel.createdAt, DateTime.utc(2021, 10, 10, 10, 10, 10));
      expect(matchModel.matchTime, DateTime.utc(2021, 10, 10, 10, 10, 10));
      expect(matchModel.opponentUsername, 'opponent');
      expect(matchModel.mmrDelta, 10);
      expect(matchModel.primeEarned, 0.053);
      expect(matchModel.paragon, Paragon.jahn);
      expect(matchModel.opponentParagon, Paragon.aetio);
      expect(matchModel.opponentRank, Rank.gold);
      expect(matchModel.playerTurn, PlayerTurn.going1st);
      expect(matchModel.result, MatchResultOption.win);

      // Assert
      expect(matchModel.toJson(), json..remove('created_at'));
    });
  });

  group("Test MatchModel equality", () {
    test("MatchModel equality", () {
      final matchTime = DateTime.now();
      // Arrange
      final matchModel1 = MatchModel(
        paragon: Paragon.jahn,
        playerTurn: PlayerTurn.going1st,
        result: MatchResultOption.win,
        matchTime: matchTime,
      );
      final matchModel2 = MatchModel(
        paragon: Paragon.jahn,
        playerTurn: PlayerTurn.going1st,
        result: MatchResultOption.win,
        matchTime: matchTime,
      );

      // Assert
      expect(matchModel1 == matchModel2, true);
    });

    test("MatchModel inequality", () {
      // Arrange
      final matchModel1 = MatchModel(
        paragon: Paragon.jahn,
        playerTurn: PlayerTurn.going1st,
        result: MatchResultOption.win,
        matchTime: DateTime.now(),
      );
      final matchModel2 = MatchModel(
        paragon: Paragon.jahn,
        playerTurn: PlayerTurn.going1st,
        result: MatchResultOption.loss,
        matchTime: DateTime.now(),
      );

      // Act
      final isEqual = matchModel1 == matchModel2;

      // Assert
      expect(isEqual, false);
    });
  });

  group("Test invalid values fail to create a match", () {
    test("MatchModel.fromJson with invalid paragon", () {
      // Arrange
      final Map<String, dynamic> json = {
        'paragon': 'invalid',
        'player_one': true,
        'result': 'win',
        'game_time': '2021-10-10T10:10:10.000Z',
      };

      // Act
      matchModel() => MatchModel.fromJson(json);

      // Assert
      expect(matchModel, throwsA(isA<ArgumentError>()));
    });

    test("MatchModel.fromJson with invalid opponent paragon", () {
      // Arrange
      final Map<String, dynamic> json = {
        'paragon': 'jahn',
        'opponent_paragon': 'invalid',
        'player_one': true,
        'result': 'win',
        'game_time': '2021-10-10T10:10:10.000Z',
      };

      // Act
      matchModel() => MatchModel.fromJson(json);

      // Assert
      expect(matchModel, throwsA(isA<ArgumentError>()));
    });

    test("MatchModel.fromJson with invalid opponent rank", () {
      // Arrange
      final Map<String, dynamic> json = {
        'paragon': 'jahn',
        'opponent_paragon': 'aetio',
        'opponent_rank': 'invalid',
        'player_one': true,
        'result': 'win',
        'game_time': '2021-10-10T10:10:10.000Z',
      };

      // Act
      matchModel() => MatchModel.fromJson(json);

      // Assert
      expect(matchModel, throwsA(isA<ArgumentError>()));
    });

    test("MatchModel.fromJson with invalid player turn", () {
      // Arrange
      final Map<String, dynamic> json = {
        'paragon': 'jahn',
        'opponent_paragon': 'aetio',
        'opponent_rank': 'gold',
        'player_one': 'invalid',
        'result': 'win',
        'game_time': '2021-10-10T10:10:10.000Z',
      };

      // Act
      matchModel() => MatchModel.fromJson(json);

      // Assert
      expect(matchModel, throwsA(isA<TypeError>()));
    });

    test("MatchModel.fromJson with invalid result", () {
      // Arrange
      final Map<String, dynamic> json = {
        'paragon': 'jahn',
        'opponent_paragon': 'aetio',
        'opponent_rank': 'gold',
        'player_one': true,
        'result': 'invalid',
        'game_time': '2021-10-10T10:10:10.000Z',
      };

      // Act
      matchModel() => MatchModel.fromJson(json);

      // Assert
      expect(matchModel, throwsA(isA<ArgumentError>()));
    });
  });
}
