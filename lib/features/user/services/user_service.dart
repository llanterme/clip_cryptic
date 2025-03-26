import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:clip_cryptic/core/config/app_config.dart';
import 'package:clip_cryptic/features/user/models/user.dart';

part 'user_service.g.dart';

class UserService {
  final Dio _dio;

  UserService(this._dio);

  Future<User> createNewUser() async {
    try {
      final response = await _dio.post(
        '${AppConfig.apiUrl}/users',
      );

      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create new user: $e');
    }
  }
}

@riverpod
UserService userService(Ref ref) {
  return UserService(Dio());
}
