class ApiConfig {
  static const String baseUrl = 'https://api.fynda.shop/api/mobile';
  static const String webBaseUrl = 'https://fynda.shop';
  static const String apiHost = 'api.fynda.shop';
  
  // Local development:
  // static const String baseUrl = 'http://localhost:8000/api/mobile';
  // static const String webBaseUrl = 'http://localhost:8000';
  // static const String apiHost = 'localhost';
  
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration imageUploadTimeout = Duration(seconds: 60);
  
  static const String appVersion = '1.0.0';
  static const String minAppVersion = '1.0.0';
  
  // OAuth
  static const String googleClientId = ''; // Add your Google client ID
  static const String appleServiceId = 'com.fynda.app';

  // ── Security ──────────────────────────────────────
  // Mobile API key — must match FYNDA_MOBILE_API_KEY in backend .env
  static const String mobileApiKey =
      String.fromEnvironment('FYNDA_MOBILE_API_KEY',
          defaultValue: 'A-wkfUfqEj864To5QA2QsRavy4yphfDsfuhiGiY1h2E');

  // SHA-256 fingerprints of your TLS certificate chain (leaf + intermediate).
  // Generate with:
  //   openssl s_client -connect api.fynda.shop:443 | openssl x509 -pubkey -noout \
  //     | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | base64
  //
  // ⚠️  UPDATE these before every certificate renewal (or pin the intermediate CA).
  static const List<String> certificatePins = [
    // TODO: Replace with real SHA-256 base64 hashes of your certificate's SPKI
    // 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',  // leaf
    // 'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=',  // intermediate / backup
  ];
}
