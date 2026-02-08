class ApiConfig {
  static const String baseUrl = 'https://api.fynda.shop/api/mobile';
  static const String webBaseUrl = 'https://fynda.shop';
  
  // For local development, switch to:
  // static const String baseUrl = 'http://localhost:8000/api/mobile';
  
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration imageUploadTimeout = Duration(seconds: 60);
  
  static const String appVersion = '1.0.0';
  static const String minAppVersion = '1.0.0';
  
  // OAuth
  static const String googleClientId = ''; // Add your Google client ID
  static const String appleServiceId = 'com.fynda.app';
}
