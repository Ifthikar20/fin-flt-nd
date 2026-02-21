import '../models/featured_content.dart';
import 'api_client.dart';

class FeaturedService {
  final ApiClient _api;

  FeaturedService(this._api);

  /// Fetches featured brands, search prompts, and suggestions from the API.
  Future<FeaturedContent> getFeaturedContent() async {
    final response = await _api.get('/featured/');
    return FeaturedContent.fromJson(response.data);
  }

  /// Like a brand. Returns updated likes_count.
  Future<Map<String, dynamic>> likeBrand(String slug) async {
    final response = await _api.post('/brands/$slug/like/');
    return response.data as Map<String, dynamic>;
  }

  /// Unlike a brand. Returns updated likes_count.
  Future<Map<String, dynamic>> unlikeBrand(String slug) async {
    final response = await _api.delete('/brands/$slug/like/');
    return response.data as Map<String, dynamic>;
  }
}
