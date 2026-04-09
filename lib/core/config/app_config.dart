class AppConfig {
  static const String appName = 'DonM';
  static const String appVersion = '1.0.0';
  static const bool isDebugMode = true;
  
  // API Configuration
  static const String baseUrl = 'https://api.donm.ci';
  static const String apiVersion = 'v1';
  static const Duration timeout = Duration(seconds: 30);
  
  // Google Maps Configuration
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  static const String googleMapsStyle = '';
  
  // Firebase Configuration
  static const String firebaseProjectId = 'donm-ci';
  static const String firebaseMessagingSenderId = '123456789';
  static const String firebaseAppId = '1:123456789:android:abcdef';
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userProfileKey = 'user_profile';
  static const String userPreferencesKey = 'user_preferences';
  static const String deviceTokenKey = 'device_token';
  
  // App Configuration
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> supportedImageFormats = [
    'jpg', 'jpeg', 'png', 'gif', 'bmp'
  ];
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Payment Configuration
  static const String currency = 'XOF';
  static const String currencySymbol = 'FCFA';
  static const int minAmount = 100;
  static const int maxAmount = 1000000;
  
  // Delivery Configuration
  static const double deliveryFeeBase = 500.0;
  static const double deliveryFeePerKm = 25.0;
  static const double maxDeliveryDistance = 50.0;
  
  // Notification Configuration
  static const Duration notificationTimeout = Duration(seconds: 10);
  static const int maxNotificationsPerPage = 50;
  
  // WebSocket Configuration
  static const String wsNotificationsUrl = 'ws://localhost:8000/ws/notifications/';
  static const String wsOrderTrackingUrl = 'ws://localhost:8000/ws/orders/tracking/';
  static const String wsDeliveryLocationUrl = 'ws://localhost:8000/ws/delivery/location/';
  
  // Cache Configuration
  static const Duration cacheTimeout = Duration(minutes: 5);
  static const int maxCacheSize = 100;
  
  // Security
  static const int sessionTimeoutMinutes = 30;
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  
  // UI Configuration
  static const double defaultBorderRadius = 12.0;
  static const double defaultPadding = 16.0;
  static const double defaultSpacing = 8.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Colors
  static const String primaryColorHex = '#FF6B35';
  static const String secondaryColorHex = '#004E89';
  static const String accentColorHex = '#FF9F1C';
  static const String errorColorHex = '#DC2626';
  static const String successColorHex = '#16A34A';
  static const String warningColorHex = '#F59E0B';
  
  // Support
  static const String supportEmail = 'support@donm.ci';
  static const String supportPhone = '+22500000000';
  static const String termsOfServiceUrl = 'https://donm.ci/terms';
  static const String privacyPolicyUrl = 'https://donm.ci/privacy';
}
