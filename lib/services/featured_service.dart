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
}
