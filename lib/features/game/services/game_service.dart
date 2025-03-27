import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:clip_cryptic/core/config/app_config.dart';
import 'package:clip_cryptic/features/game/models/game_round.dart';
import 'package:clip_cryptic/features/user/repositories/user_repository.dart';

part 'game_service.g.dart';

class GameService {
  final Dio _dio;

  GameService(this._dio);

  /// Gets the current user ID from the repository
  /// Returns the user ID or null if not found (without creating new users)
  Future<String?> _getUserId(Ref ref) async {
    try {
      final userRepoProvider = ref.read(userRepositoryProvider);
      final user = userRepoProvider.valueOrNull;
      
      if (user == null) {
        developer.log('No user found in repository, NOT creating a new user');
        return null;
      }
      
      developer.log('Found existing user ID: ${user.id}');
      return user.id;
    } catch (e) {
      developer.log('Error getting user ID: $e');
      return null;
    }
  }

  Future<List<GameRound>> getUnseenRounds(Ref ref) async {
    try {
      // First try to get the user ID
      final userId = await _getUserId(ref);
      
      // If no user exists yet, we should NOT create one here
      // This allows the app initialization process to handle user creation
      if (userId == null) {
        developer.log('No user ID available, cannot fetch unseen rounds');
        throw Exception('User not initialized');
      }
      
      developer.log(
          'Fetching unseen rounds from: ${AppConfig.apiUrl}/rounds/unseen?userId=$userId');

      final response = await _dio.get(
        '${AppConfig.apiUrl}/rounds/unseen',
        queryParameters: {'userId': userId},
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

            return GameRound.fromJson(modifiedRound);
          } else {
            developer.log('Round is not a Map: ${round.runtimeType}');
            throw Exception('Invalid round data format');
          }
        } catch (e) {
          developer.log('Error processing round: $e');
          rethrow;
        }
      }).toList();

      developer.log('Processed ${rounds.length} rounds successfully');
      return rounds;
    } catch (e) {
      developer.log('Error fetching game rounds: $e');
      rethrow;
    }
  }
  
  /// Marks a list of GIFs as seen by the user
  /// Returns true if the operation was successful
  Future<bool> markGifsAsSeen(List<int> gifIds, Ref ref) async {
    try {
      // Get user ID without creating a new user
      final userId = await _getUserId(ref);
      
      // If no user exists, we cannot mark GIFs as seen
      if (userId == null) {
        developer.log('No user ID available, cannot mark GIFs as seen');
        return false;
      }
      
      developer.log('Marking GIFs as seen for user $userId: $gifIds');
      
      // Create the payload format as required by the API
      final List<Map<String, dynamic>> markSeen = 
          gifIds.map((id) => {'gifId': id}).toList();
      
      final payload = {
        'userId': userId,
        'markSeen': markSeen,
      };
      
      developer.log('Sending payload to mark GIFs as seen: $payload');
      
      final response = await _dio.post(
        '${AppConfig.apiUrl}/rounds/mark-seen',
        data: payload,
      );
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        developer.log('Successfully marked GIFs as seen');
        return true;
      } else {
        developer.log('Failed to mark GIFs as seen: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      developer.log('Error marking GIFs as seen: $e');
      // Don't throw the error, just return false to indicate failure
      return false;
    }
  }
}

@riverpod
GameService gameService(GameServiceRef ref) {
  return GameService(Dio());
}
