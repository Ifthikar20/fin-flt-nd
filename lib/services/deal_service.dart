import 'dart:io';
import 'package:dio/dio.dart';
import '../models/deal.dart';
import 'api_client.dart';

class DealService {
  final ApiClient _api;

  DealService(this._api);

  // ─── Text Search ───────────────────────────────

  Future<SearchResult> search({
    required String query,
    double? minPrice,
    double? maxPrice,
    String sort = 'relevance',
    int limit = 20,
    int offset = 0,
    String? gender,
    List<String>? sources,
  }) async {
    final response = await _api.post('/deals/search/', data: {
      'query': query.trim(),
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      'sort': sort,
      'limit': limit,
      'offset': offset,
      if (gender != null) 'gender': gender,
      if (sources != null) 'sources': sources,
    });
    return SearchResult.fromJson(response.data);
  }

  // ─── Trending ──────────────────────────────────

  Future<SearchResult> getTrending({
    int limit = 20,
    String sort = 'relevance',
  }) async {
    final response = await _api.get('/deals/', params: {
      'limit': limit,
      'sort': sort,
    });
    return SearchResult.fromJson(response.data);
  }

  // ─── Image Search (Core Flow) ──────────────────

  Future<SearchResult> imageSearch(File imageFile) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: 'photo.jpg',
      ),
    });

    final response = await _api.uploadFile('/deals/image-search/', formData);
    return SearchResult.fromJson(response.data);
  }
}
