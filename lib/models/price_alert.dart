class PriceAlert {
  final String id;
  final String productQuery;
  final String productName;
  final String? productImage;
  final String? productUrl;
  final double targetPrice;
  final double? originalPrice;
  final double? currentPrice;
  final double? lowestPrice;
  final double? priceDropPercent;
  final String status;
  final String currency;
  final DateTime? lastCheckedAt;
  final DateTime? triggeredAt;
  final DateTime createdAt;

  PriceAlert({
    required this.id,
    required this.productQuery,
    required this.productName,
    this.productImage,
    this.productUrl,
    required this.targetPrice,
    this.originalPrice,
    this.currentPrice,
    this.lowestPrice,
    this.priceDropPercent,
    this.status = 'active',
    this.currency = 'USD',
    this.lastCheckedAt,
    this.triggeredAt,
    required this.createdAt,
  });

  factory PriceAlert.fromJson(Map<String, dynamic> json) {
    return PriceAlert(
      id: json['id']?.toString() ?? '',
      productQuery: json['product_query'] ?? '',
      productName: json['product_name'] ?? '',
      productImage: json['product_image'],
      productUrl: json['product_url'],
      targetPrice: _toDouble(json['target_price']),
      originalPrice: _toDoubleNullable(json['original_price']),
      currentPrice: _toDoubleNullable(json['current_price']),
      lowestPrice: _toDoubleNullable(json['lowest_price']),
      priceDropPercent: _toDoubleNullable(json['price_drop_percent']),
      status: json['status'] ?? 'active',
      currency: json['currency'] ?? 'USD',
      lastCheckedAt: json['last_checked_at'] != null
          ? DateTime.tryParse(json['last_checked_at'])
          : null,
      triggeredAt: json['triggered_at'] != null
          ? DateTime.tryParse(json['triggered_at'])
          : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  bool get isActive => status == 'active';
  bool get isTriggered => triggeredAt != null;

  String get formattedTarget => '\$${targetPrice.toStringAsFixed(2)}';
  String get formattedCurrent =>
      currentPrice != null ? '\$${currentPrice!.toStringAsFixed(2)}' : 'N/A';

  static double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  static double? _toDoubleNullable(dynamic v) {
    if (v == null) return null;
    return _toDouble(v);
  }
}

class Storyboard {
  final String? id;
  final String token;
  final String title;
  final String shareUrl;
  final Map<String, dynamic> storyboardData;
  final DateTime? expiresAt;
  final DateTime? createdAt;

  Storyboard({
    this.id,
    required this.token,
    required this.title,
    this.shareUrl = '',
    this.storyboardData = const {},
    this.expiresAt,
    this.createdAt,
  });

  factory Storyboard.fromJson(Map<String, dynamic> json) {
    return Storyboard(
      id: json['id']?.toString(),
      token: json['token'] ?? '',
      title: json['title'] ?? '',
      shareUrl: json['share_url'] ?? '',
      storyboardData:
          json['storyboard_data'] as Map<String, dynamic>? ?? {},
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}
