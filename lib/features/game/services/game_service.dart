import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:clip_cryptic/core/config/app_config.dart';
import 'package:clip_cryptic/features/game/models/game_round.dart';

part 'game_service.g.dart';

class GameService {
  final Dio _dio;
  // Hardcoded user ID as per requirements
  static const String _userId = 'ba2bc1a9-475c-4cfb-aab4-2f875a11b80a';

  GameService(this._dio);

  Future<List<GameRound>> getUnseenRounds(String userId) async {
    try {
      developer.log(
          'Fetching unseen rounds from: ${AppConfig.apiUrl}/rounds/unseen?userId=$_userId');

      // Using the hardcoded user ID instead of the passed parameter
      final response = await _dio.get(
        '${AppConfig.apiUrl}/rounds/unseen',
        queryParameters: {'userId': _userId},
      );

      if (response.statusCode != 200) {
        developer.log('API error: ${response.statusCode}');
        throw Exception('Failed to fetch game rounds: ${response.statusCode}');
      }

      developer.log('API response received: ${response.data}');
      developer.log('API response type: ${response.data.runtimeType}');

      // Ensure the response data is a List
      if (response.data is! List) {
        developer
            .log('API response is not a List: ${response.data.runtimeType}');
        throw Exception('Invalid response format: expected a List');
      }

      // Log each item in the list to see its structure
      final responseList = response.data as List;
      for (int i = 0; i < responseList.length; i++) {
        developer.log('Round $i data: ${responseList[i]}');
        if (responseList[i] is Map<String, dynamic>) {
          final round = responseList[i] as Map<String, dynamic>;
          developer.log('Round $i gifId: ${round['gifId']}');
          developer.log('Round $i options: ${round['options']}');
          developer.log('Round $i correctAnswer: ${round['correctAnswer']}');
          developer.log('Round $i gif_url: ${round['gif_url']}');
        }
      }

      final rounds = (response.data as List).map((round) {
        developer.log('Processing round: $round');
        try {
          if (round is Map<String, dynamic>) {
            // Create a copy of the round data to modify
            final modifiedRound = Map<String, dynamic>.from(round);

            // Handle gif_url format issues
            if (modifiedRound['gif_url'] is String &&
                (modifiedRound['gif_url'] as String).startsWith('[') &&
                (modifiedRound['gif_url'] as String).endsWith(']')) {
              final gifUrl = modifiedRound['gif_url'] as String;
              final cleanedUrl = gifUrl.substring(1, gifUrl.length - 1);
              developer.log('Cleaned up gif_url: $cleanedUrl');
              modifiedRound['gif_url'] = cleanedUrl;
            }

            // Handle options format issues
            if (modifiedRound['options'] != null) {
              var options = modifiedRound['options'];

              // If options is a string that looks like an array, convert it to a proper List
              if (options is String &&
                  options.startsWith('[') &&
                  options.endsWith(']')) {
                try {
                  // Remove brackets and split by comma
                  final optionsString =
                      options.substring(1, options.length - 1);
                  final optionsList = optionsString
                      .split(',')
                      .map((o) => o.trim())
                      .where((o) => o.isNotEmpty)
                      .toList();

                  developer
                      .log('Converted options string to list: $optionsList');
                  modifiedRound['options'] = optionsList;
                } catch (e) {
                  developer.log('Error converting options string to list: $e');
                }
              }

              // Ensure options is a List<String>
              if (options is List) {
                final stringOptions =
                    options.map((o) => o.toString().trim()).toList();
                modifiedRound['options'] = stringOptions;
                developer
                    .log('Normalized options to List<String>: $stringOptions');
              }
            }

            // Handle correctAnswer format issues
            if (modifiedRound['correctAnswer'] is String) {
              modifiedRound['correctAnswer'] =
                  modifiedRound['correctAnswer'].toString().trim();
            }

            return GameRound.fromJson(modifiedRound);
          }
          return GameRound.fromJson(round);
        } catch (e) {
          developer.log('Error parsing round: $e');
          rethrow;
        }
      }).toList();

      developer.log('Parsed ${rounds.length} rounds successfully');
      return rounds;
    } catch (e) {
      developer.log('Error fetching game rounds: $e');
      throw Exception('Failed to fetch game rounds: $e');
    }
  }
}

@riverpod
GameService gameService(GameServiceRef ref) {
  return GameService(Dio());
}
