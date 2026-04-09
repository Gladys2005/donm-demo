import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:crypto/crypto.dart';
import '../services/storage_service.dart';
import '../config/app_config.dart';

class AuthService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static int _loginAttempts = 0;
  static DateTime? _lockoutEndTime;
  
  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final accessToken = await StorageService.getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }
  
  // Check if biometric authentication is available
  static Future<bool> isBiometricAvailable() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }
  
  // Check if biometric is enabled
  static Future<bool> isBiometricEnabled() async {
    return await StorageService.isBiometricEnabled();
  }
  
  // Enable biometric authentication
  static Future<bool> enableBiometric() async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        throw Exception('Biometric authentication not available');
      }
      
      // Test biometric authentication
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Activer l\'authentification biométrique',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      
      if (authenticated) {
        await StorageService.setBiometricEnabled(true);
        return true;
      }
      
      return false;
      
    } catch (e) {
      throw Exception('Failed to enable biometric: $e');
    }
  }
  
  // Disable biometric authentication
  static Future<void> disableBiometric() async {
    await StorageService.setBiometricEnabled(false);
  }
  
  // Authenticate with biometric
  static Future<bool> authenticateWithBiometric({
    String localizedReason = 'Authentification requise',
  }) async {
    try {
      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) {
        return false;
      }
      
      final authenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      
      return authenticated;
      
    } catch (e) {
      return false;
    }
  }
  
  // Check if account is locked
  static bool isAccountLocked() {
    if (_lockoutEndTime == null) {
      return false;
    }
    
    final now = DateTime.now();
    if (now.isAfter(_lockoutEndTime!)) {
      _lockoutEndTime = null;
      _loginAttempts = 0;
      return false;
    }
    
    return true;
  }
  
  // Get remaining lockout time
  static Duration? getRemainingLockoutTime() {
    if (_lockoutEndTime == null) {
      return null;
    }
    
    final now = DateTime.now();
    if (now.isAfter(_lockoutEndTime!)) {
      return null;
    }
    
    return _lockoutEndTime!.difference(now);
  }
  
  // Record login attempt
  static void recordLoginAttempt({bool success = false}) {
    if (success) {
      _loginAttempts = 0;
      _lockoutEndTime = null;
    } else {
      _loginAttempts++;
      
      if (_loginAttempts >= AppConfig.maxLoginAttempts) {
        _lockoutEndTime = DateTime.now().add(AppConfig.lockoutDuration);
      }
    }
  }
  
  // Get remaining login attempts
  static int getRemainingLoginAttempts() {
    if (isAccountLocked()) {
      return 0;
    }
    
    return AppConfig.maxLoginAttempts - _loginAttempts;
  }
  
  // Validate email format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
  
  // Validate phone number (Côte d'Ivoire format)
  static bool isValidPhoneNumber(String phone) {
    // Remove spaces and special characters
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Check if it matches Ivorian phone format
    final phoneRegex = RegExp(r'^(\+225|00225)?[0-9]{10}$');
    return phoneRegex.hasMatch(cleanPhone);
  }
  
  // Format phone number to standard format
  static String formatPhoneNumber(String phone) {
    // Remove spaces and special characters
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // If starts with country code, return as is
    if (cleanPhone.startsWith('+225') || cleanPhone.startsWith('00225')) {
      return cleanPhone;
    }
    
    // If 10 digits, add country code
    if (cleanPhone.length == 10) {
      return '+225$cleanPhone';
    }
    
    return cleanPhone;
  }
  
  // Validate password strength
  static Map<String, dynamic> validatePassword(String password) {
    final errors = <String>[];
    int strength = 0;
    
    // Length check
    if (password.length < 8) {
      errors.add('Le mot de passe doit contenir au moins 8 caractères');
    } else {
      strength += 1;
    }
    
    // Uppercase check
    if (!password.contains(RegExp(r'[A-Z]'))) {
      errors.add('Le mot de passe doit contenir au moins une majuscule');
    } else {
      strength += 1;
    }
    
    // Lowercase check
    if (!password.contains(RegExp(r'[a-z]'))) {
      errors.add('Le mot de passe doit contenir au moins une minuscule');
    } else {
      strength += 1;
    }
    
    // Number check
    if (!password.contains(RegExp(r'[0-9]'))) {
      errors.add('Le mot de passe doit contenir au moins un chiffre');
    } else {
      strength += 1;
    }
    
    // Special character check
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      errors.add('Le mot de passe doit contenir au moins un caractère spécial');
    } else {
      strength += 1;
    }
    
    // Determine strength level
    String strengthLevel;
    Color strengthColor;
    
    if (strength <= 2) {
      strengthLevel = 'Faible';
      strengthColor = const Color(0xFFFF0000); // Red
    } else if (strength <= 3) {
      strengthLevel = 'Moyen';
      strengthColor = const Color(0xFFFFA500); // Orange
    } else {
      strengthLevel = 'Fort';
      strengthColor = const Color(0xFF00FF00); // Green
    }
    
    return {
      'isValid': errors.isEmpty,
      'errors': errors,
      'strength': strength,
      'strengthLevel': strengthLevel,
      'strengthColor': strengthColor,
    };
  }
  
  // Generate secure random password
  static String generateSecurePassword({int length = 12}) {
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    const special = '!@#$%^&*(),.?":{}|<>';
    
    final allChars = lowercase + uppercase + numbers + special;
    final random = math.Random.secure();
    
    String password = '';
    
    // Ensure at least one of each type
    password += lowercase[random.nextInt(lowercase.length)];
    password += uppercase[random.nextInt(uppercase.length)];
    password += numbers[random.nextInt(numbers.length)];
    password += special[random.nextInt(special.length)];
    
    // Fill remaining length
    for (int i = 4; i < length; i++) {
      password += allChars[random.nextInt(allChars.length)];
    }
    
    // Shuffle the password
    final passwordList = password.split('');
    passwordList.shuffle(random);
    
    return passwordList.join('');
  }
  
  // Hash password (for client-side validation only)
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // Generate secure token
  static String generateSecureToken() {
    final random = math.Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64.encode(bytes);
  }
  
  // Generate OTP (for testing purposes)
  static String generateOTP() {
    final random = math.Random.secure();
    final otp = (100000 + random.nextInt(900000)).toString();
    return otp;
  }
  
  // Check if session is valid
  static Future<bool> isSessionValid() async {
    // This would check with the server if the session is still valid
    // For now, just check if we have a token
    return isAuthenticated();
  }
  
  // Refresh session
  static Future<bool> refreshSession() async {
    try {
      // This would call the refresh token endpoint
      // For now, just return true
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Logout user
  static Future<void> logout() async {
    try {
      // Clear tokens
      await StorageService.clearTokens();
      
      // Clear user profile
      await StorageService.clearUserProfile();
      
      // Reset login attempts
      _loginAttempts = 0;
      _lockoutEndTime = null;
      
      // Clear any cached data
      await StorageService.clearCache();
      
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }
  
  // Get user role from storage
  static Future<String?> getUserRole() async {
    final profile = await StorageService.getUserProfile();
    return profile?['role'];
  }
  
  // Check if user has specific role
  static Future<bool> hasRole(String requiredRole) async {
    final userRole = await getUserRole();
    return userRole == requiredRole;
  }
  
  // Check if user is admin
  static Future<bool> isAdmin() async {
    return await hasRole('ADMIN');
  }
  
  // Check if user is client
  static Future<bool> isClient() async {
    return await hasRole('CLIENT');
  }
  
  // Check if user is vendor
  static Future<bool> isVendor() async {
    return await hasRole('VENDOR');
  }
  
  // Check if user is delivery person
  static Future<bool> isDeliveryPerson() async {
    return await hasRole('DELIVERY_PERSON');
  }
  
  // Get user permissions based on role
  static Future<List<String>> getUserPermissions() async {
    final role = await getUserRole();
    
    switch (role) {
      case 'ADMIN':
        return [
          'read_all',
          'write_all',
          'delete_all',
          'manage_users',
          'manage_orders',
          'manage_payments',
          'manage_kyc',
          'manage_notifications',
        ];
      case 'VENDOR':
        return [
          'read_own_orders',
          'write_own_orders',
          'read_own_profile',
          'write_own_profile',
          'read_own_payments',
        ];
      case 'DELIVERY_PERSON':
        return [
          'read_available_orders',
          'write_own_orders',
          'read_own_profile',
          'write_own_profile',
          'update_location',
          'update_order_status',
        ];
      case 'CLIENT':
      default:
        return [
          'read_own_orders',
          'write_own_orders',
          'read_own_profile',
          'write_own_profile',
          'read_own_payments',
          'read_own_kyc',
        ];
    }
  }
  
  // Check if user has specific permission
  static Future<bool> hasPermission(String permission) async {
    final permissions = await getUserPermissions();
    return permissions.contains(permission);
  }
  
  // Get auth headers for API requests
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await StorageService.getAccessToken();
    
    if (token != null) {
      return {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
    }
    
    return {
      'Content-Type': 'application/json',
    };
  }
  
  // Handle authentication error
  static Future<void> handleAuthError(dynamic error) async {
    // Check if it's a 401 Unauthorized error
    if (error?.response?.statusCode == 401) {
      // Try to refresh the session
      final refreshed = await refreshSession();
      
      if (!refreshed) {
        // If refresh fails, logout user
        await logout();
        throw Exception('Session expired. Please login again.');
      }
    }
  }
  
  // Reset password (request)
  static Future<bool> requestPasswordReset(String email) async {
    try {
      if (!isValidEmail(email)) {
        throw Exception('Invalid email address');
      }
      
      // This would call the password reset endpoint
      // For now, just return true
      return true;
      
    } catch (e) {
      throw Exception('Failed to request password reset: $e');
    }
  }
  
  // Reset password (confirm)
  static Future<bool> confirmPasswordReset({
    required String token,
    required String newPassword,
  }) async {
    try {
      final passwordValidation = validatePassword(newPassword);
      if (!passwordValidation['isValid']) {
        throw Exception('Password does not meet requirements');
      }
      
      // This would call the password reset confirmation endpoint
      // For now, just return true
      return true;
      
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }
  
  // Change password
  static Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final passwordValidation = validatePassword(newPassword);
      if (!passwordValidation['isValid']) {
        throw Exception('New password does not meet requirements');
      }
      
      // This would call the change password endpoint
      // For now, just return true
      return true;
      
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }
}
