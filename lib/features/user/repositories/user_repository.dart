import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clip_cryptic/features/user/models/user.dart';
import 'package:clip_cryptic/features/user/services/user_service.dart';

part 'user_repository.g.dart';

const _userKey = 'user_data';

@riverpod
class UserRepository extends _$UserRepository {
  @override
  FutureOr<User?> build() async {
    return _loadUser();
  }

  Future<User?> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    
    try {
      return User.fromJson(json.decode(userJson));
    } catch (e) {
      await prefs.remove(_userKey);
      return null;
    }
  }

  Future<User> createAndSaveUser() async {
    final userService = ref.read(userServiceProvider);
    final user = await userService.createNewUser();
    await _saveUser(user);
    state = AsyncValue.data(user);
    return user;
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }
}
