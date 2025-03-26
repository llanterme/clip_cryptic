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
      developer.log('Fetching unseen rounds from: ${AppConfig.apiUrl}/rounds/unseen?userId=$_userId');
      
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
      
      // Ensure the response data is a List
      if (response.data is! List) {
        developer.log('API response is not a List: ${response.data.runtimeType}');
        throw Exception('Invalid response format: expected a List');
      }
      
      final rounds = (response.data as List)
          .map((round) {
            developer.log('Processing round: $round');
            try {
              // Preprocess the gif_url if it contains square brackets
              if (round is Map<String, dynamic> && 
                  round['gif_url'] is String && 
                  (round['gif_url'] as String).startsWith('[') && 
                  (round['gif_url'] as String).endsWith(']')) {
                
                final gifUrl = round['gif_url'] as String;
                final cleanedUrl = gifUrl.substring(1, gifUrl.length - 1);
                developer.log('Cleaned up gif_url: $cleanedUrl');
                
                // Create a copy of the round data with the cleaned URL
                round = Map<String, dynamic>.from(round);
                round['gif_url'] = cleanedUrl;
              }
              
              return GameRound.fromJson(round);
            } catch (e) {
              developer.log('Error parsing round: $e');
              rethrow;
            }
          })
          .toList();
          
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
