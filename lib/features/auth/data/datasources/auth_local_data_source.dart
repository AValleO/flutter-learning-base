import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_4/core/errors/exceptions.dart';
import 'package:flutter_application_4/features/auth/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel> getCachedUser();
  Future<void> clearCache();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String cachedUserKey = 'CACHED_USER';

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final userJson = json.encode(user.toJson());
      await sharedPreferences.setString(cachedUserKey, userJson);
    } catch (e) {
      throw CacheException('Failed to cache user');
    }
  }

  @override
  Future<UserModel> getCachedUser() async {
    try {
      final jsonString = sharedPreferences.getString(cachedUserKey);
      if (jsonString != null) {
        final jsonMap = json.decode(jsonString);
        return UserModel.fromJson(jsonMap);
      } else {
        throw CacheException('No cached user found');
      }
    } catch (e) {
      throw CacheException('Failed to get cached user');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove(cachedUserKey);
    } catch (e) {
      throw CacheException('Failed to clear cache');
    }
  }
}
