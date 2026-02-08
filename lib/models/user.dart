class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? avatar;

  User({
    required this.id,
    required this.email,
    this.firstName = '',
    this.lastName = '',
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      avatar: json['avatar'],
    );
  }

  String get displayName {
    if (firstName.isNotEmpty) {
      return '$firstName ${lastName}'.trim();
    }
    return email.split('@').first;
  }

  String get initials {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    }
    if (firstName.isNotEmpty) return firstName[0].toUpperCase();
    return email[0].toUpperCase();
  }
}

class UserPreferences {
  final bool pushEnabled;
  final bool pushDeals;
  final bool pushPriceAlerts;
  final String theme;
  final String currency;
  final String language;
  final String defaultSort;

  UserPreferences({
    this.pushEnabled = true,
    this.pushDeals = true,
    this.pushPriceAlerts = true,
    this.theme = 'system',
    this.currency = 'USD',
    this.language = 'en',
    this.defaultSort = 'relevance',
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      pushEnabled: json['push_enabled'] ?? true,
      pushDeals: json['push_deals'] ?? true,
      pushPriceAlerts: json['push_price_alerts'] ?? true,
      theme: json['theme'] ?? 'system',
      currency: json['currency'] ?? 'USD',
      language: json['language'] ?? 'en',
      defaultSort: json['default_sort'] ?? 'relevance',
    );
  }

  Map<String, dynamic> toJson() => {
        'push_enabled': pushEnabled,
        'push_deals': pushDeals,
        'push_price_alerts': pushPriceAlerts,
        'theme': theme,
        'currency': currency,
        'language': language,
        'default_sort': defaultSort,
      };
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final User user;
  final String deviceId;
  final UserPreferences preferences;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
    required this.deviceId,
    required this.preferences,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      expiresIn: json['expires_in'] ?? 3600,
      user: User.fromJson(json['user'] ?? {}),
      deviceId: json['device_id'] ?? '',
      preferences: UserPreferences.fromJson(json['preferences'] ?? {}),
    );
  }
}
