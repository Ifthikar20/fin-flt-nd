/// Model for featured content served by the mobile API.
class FeaturedContent {
  final List<FeaturedBrand> brands;
  final List<String> searchPrompts;
  final List<String> quickSuggestions;

  FeaturedContent({
    required this.brands,
    required this.searchPrompts,
    required this.quickSuggestions,
  });

  factory FeaturedContent.fromJson(Map<String, dynamic> json) {
    return FeaturedContent(
      brands: (json['featured_brands'] as List<dynamic>?)
              ?.map((b) => FeaturedBrand.fromJson(b as Map<String, dynamic>))
              .toList() ??
          [],
      searchPrompts: (json['search_prompts'] as List<dynamic>?)
              ?.map((s) => s.toString())
              .toList() ??
          [],
      quickSuggestions: (json['quick_suggestions'] as List<dynamic>?)
              ?.map((s) => s.toString())
              .toList() ??
          [],
    );
  }
}

class FeaturedBrand {
  final String name;
  final String initial;
  final String category;

  FeaturedBrand({
    required this.name,
    required this.initial,
    required this.category,
  });

  factory FeaturedBrand.fromJson(Map<String, dynamic> json) {
    return FeaturedBrand(
      name: json['name'] ?? '',
      initial: json['initial'] ?? '',
      category: json['category'] ?? '',
    );
  }
}
