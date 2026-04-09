import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class StorageService {
  static late SharedPreferences _prefs;
  static late FlutterSecureStorage _secureStorage;
  
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _secureStorage = const FlutterSecureStorage();
  }
  
  // Secure storage methods (for sensitive data)
  static Future<void> setSecureString(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }
  
  static Future<String?> getSecureString(String key) async {
    return await _secureStorage.read(key: key);
  }
  
  static Future<void> removeSecure(String key) async {
    await _secureStorage.delete(key: key);
  }
  
  static Future<void> clearSecure() async {
    await _secureStorage.deleteAll();
  }
  
  // Regular storage methods (for non-sensitive data)
  static Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }
  
  static Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }
  
  static Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }
  
  static Future<bool?> getBool(String key) async {
    return _prefs.getBool(key);
  }
  
  static Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }
  
  static Future<int?> getInt(String key) async {
    return _prefs.getInt(key);
  }
  
  static Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }
  
  static Future<double?> getDouble(String key) async {
    return _prefs.getDouble(key);
  }
  
  static Future<void> setStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }
  
  static Future<List<String>?> getStringList(String key) async {
    return _prefs.getStringList(key);
  }
  
  static Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
  
  static Future<void> clear() async {
    await _prefs.clear();
  }
  
  // JSON methods
  static Future<void> setJson(String key, Map<String, dynamic> value) async {
    await _prefs.setString(key, json.encode(value));
  }
  
  static Future<Map<String, dynamic>?> getJson(String key) async {
    final String? jsonString = _prefs.getString(key);
    if (jsonString != null) {
      return json.decode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }
  
  static Future<void> setSecureJson(String key, Map<String, dynamic> value) async {
    await _secureStorage.write(key: key, value: json.encode(value));
  }
  
  static Future<Map<String, dynamic>?> getSecureJson(String key) async {
    final String? jsonString = await _secureStorage.read(key: key);
    if (jsonString != null) {
      return json.decode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }
  
  // Authentication related methods
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await setSecureString(AppConfig.accessTokenKey, accessToken);
    await setSecureString(AppConfig.refreshTokenKey, refreshToken);
  }
  
  static Future<String?> getAccessToken() async {
    return await getSecureString(AppConfig.accessTokenKey);
  }
  
  static Future<String?> getRefreshToken() async {
    return await getSecureString(AppConfig.refreshTokenKey);
  }
  
  static Future<void> clearTokens() async {
    await removeSecure(AppConfig.accessTokenKey);
    await removeSecure(AppConfig.refreshTokenKey);
  }
  
  // User profile methods
  static Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    await setSecureJson(AppConfig.userProfileKey, profile);
  }
  
  static Future<Map<String, dynamic>?> getUserProfile() async {
    return await getSecureJson(AppConfig.userProfileKey);
  }
  
  static Future<void> clearUserProfile() async {
    await removeSecure(AppConfig.userProfileKey);
  }
  
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    return await getUserProfile();
  }
  
  static Future<String?> getCurrentRole() async {
    final profile = await getUserProfile();
    return profile?['role'] as String?;
  }
  
  // User preferences methods
  static Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    await setJson(AppConfig.userPreferencesKey, preferences);
  }
  
  static Future<Map<String, dynamic>?> getUserPreferences() async {
    return await getJson(AppConfig.userPreferencesKey);
  }
  
  // Device token methods
  static Future<void> saveDeviceToken(String token) async {
    await setString(AppConfig.deviceTokenKey, token);
  }
  
  static Future<String?> getDeviceToken() async {
    return await getString(AppConfig.deviceTokenKey);
  }
  
  // Onboarding status
  static Future<void> setOnboardingCompleted(bool completed) async {
    await setBool('onboarding_completed', completed);
  }
  
  static Future<bool> isOnboardingCompleted() async {
    return _prefs.getBool('onboarding_completed') ?? false;
  }
  
  // App settings
  static Future<void> setDarkMode(bool isDarkMode) async {
    await setBool('dark_mode', isDarkMode);
  }
  
  static Future<bool> isDarkMode() async {
    return _prefs.getBool('dark_mode') ?? false;
  }
  
  static Future<void> setLanguage(String languageCode) async {
    await setString('language', languageCode);
  }
  
  static Future<String> getLanguage() async {
    return _prefs.getString('language') ?? 'fr';
  }
  
  static Future<void> setNotificationsEnabled(bool enabled) async {
    await setBool('notifications_enabled', enabled);
  }
  
  static Future<bool> areNotificationsEnabled() async {
    return _prefs.getBool('notifications_enabled') ?? true;
  }
  
  // Cache methods
  static Future<void> setCachedData(String key, Map<String, dynamic> data, {Duration? expiration}) async {
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiration': expiration?.inMilliseconds,
    };
    await setJson('cache_$key', cacheData);
  }
  
  static Future<Map<String, dynamic>?> getCachedData(String key) async {
    final cacheData = await getJson('cache_$key');
    if (cacheData != null) {
      final timestamp = cacheData['timestamp'] as int;
      final expiration = cacheData['expiration'] as int?;
      
      if (expiration != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now > expiration) {
          await remove('cache_$key');
          return null;
        }
      }
      
      return cacheData['data'] as Map<String, dynamic>;
    }
    return null;
  }
  
  static Future<void> clearCache() async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('cache_')) {
        await remove(key);
      }
    }
  }
  
  // Search history
  static Future<void> addToSearchHistory(String query) async {
    final history = await getSearchHistory();
    history.remove(query); // Remove if already exists
    history.insert(0, query); // Add to beginning
    
    // Keep only last 10 items
    if (history.length > 10) {
      history.removeRange(10, history.length);
    }
    
    await setStringList('search_history', history);
  }
  
  static Future<List<String>> getSearchHistory() async {
    return _prefs.getStringList('search_history') ?? [];
  }
  
  static Future<void> clearSearchHistory() async {
    await remove('search_history');
  }
  
  // Location permissions
  static Future<void> setLocationPermissionGranted(bool granted) async {
    await setBool('location_permission_granted', granted);
  }
  
  static Future<bool> isLocationPermissionGranted() async {
    return _prefs.getBool('location_permission_granted') ?? false;
  }
  
  // Biometric authentication
  static Future<void> setBiometricEnabled(bool enabled) async {
    await setSecureBool('biometric_enabled', enabled);
  }
  
  static Future<bool> isBiometricEnabled() async {
    return await getSecureBool('biometric_enabled') ?? false;
  }
  
  static Future<void> setSecureBool(String key, bool value) async {
    await _secureStorage.write(key: key, value: value.toString());
  }
  
  static Future<bool> getSecureBool(String key) async {
    final String? value = await _secureStorage.read(key: key);
    return value == 'true';
  }
}
