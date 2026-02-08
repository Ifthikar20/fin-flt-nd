class Deal {
  final String id;
  final String title;
  final double? price;
  final double? originalPrice;
  final int? discount;
  final String currency;
  final String? image;
  final String source;
  final String? url;
  final double? rating;
  final bool inStock;
  final bool isSaved;

  Deal({
    required this.id,
    required this.title,
    this.price,
    this.originalPrice,
    this.discount,
    this.currency = 'USD',
    this.image,
    this.source = '',
    this.url,
    this.rating,
    this.inStock = true,
    this.isSaved = false,
  });

  factory Deal.fromJson(Map<String, dynamic> json) {
    return Deal(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      price: _parseDouble(json['price']),
      originalPrice: _parseDouble(json['original_price']),
      discount: json['discount'] as int?,
      currency: json['currency'] ?? 'USD',
      image: json['image'] ?? json['image_url'],
      source: json['source'] ?? '',
      url: json['url'],
      rating: _parseDouble(json['rating']),
      inStock: json['in_stock'] ?? true,
      isSaved: json['is_saved'] ?? false,
    );
  }

  Deal copyWith({bool? isSaved}) {
    return Deal(
      id: id,
      title: title,
      price: price,
      originalPrice: originalPrice,
      discount: discount,
      currency: currency,
      image: image,
      source: source,
      url: url,
      rating: rating,
      inStock: inStock,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'original_price': originalPrice,
      'image_url': image,
      'source': source,
      'url': url,
    };
  }

  String get formattedPrice {
    if (price == null) return 'N/A';
    return '\$${price!.toStringAsFixed(2)}';
  }

  String get formattedOriginalPrice {
    if (originalPrice == null) return '';
    return '\$${originalPrice!.toStringAsFixed(2)}';
  }

  bool get hasDiscount => discount != null && discount! > 0;

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class SearchResult {
  final List<Deal> deals;
  final int total;
  final String query;
  final int searchTimeMs;
  final List<String> sourcesSearched;
  final String? quotaWarning;
  final Map<String, dynamic>? extracted;
  final List<String>? searchQueries;

  SearchResult({
    required this.deals,
    required this.total,
    this.query = '',
    this.searchTimeMs = 0,
    this.sourcesSearched = const [],
    this.quotaWarning,
    this.extracted,
    this.searchQueries,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      deals: (json['deals'] as List<dynamic>?)
              ?.map((d) => Deal.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      query: json['query'] ?? '',
      searchTimeMs: json['search_time_ms'] ?? 0,
      sourcesSearched: (json['sources_searched'] as List<dynamic>?)
              ?.map((s) => s.toString())
              .toList() ??
          [],
      quotaWarning: json['quota_warning'],
      extracted: json['extracted'] as Map<String, dynamic>?,
      searchQueries: (json['search_queries'] as List<dynamic>?)
          ?.map((s) => s.toString())
          .toList(),
    );
  }
}
