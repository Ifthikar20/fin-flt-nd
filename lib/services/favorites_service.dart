import '../models/deal.dart';
import 'api_client.dart';

class FavoritesService {
  final ApiClient _api;

  FavoritesService(this._api);

  Future<List<Deal>> getFavorites() async {
    try {
      // Check if user has auth tokens before calling protected endpoint
      final hasAuth = await _api.hasTokens();
      if (!hasAuth) return [];

      final response = await _api.get('/favorites/');
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final list = data['favorites'] as List<dynamic>? ?? [];
        return list
            .map((d) => Deal.fromJson(d as Map<String, dynamic>))
            .toList();
      }
      if (data is List<dynamic>) {
        return data
            .map((d) => Deal.fromJson(d as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      // Gracefully handle auth errors — return empty instead of crashing
      if (e.toString().contains('401') || e.toString().contains('403')) {
        return [];
      }
      rethrow;
    }
  }

  Future<void> saveDeal(Deal deal) async {
    await _api.post('/favorites/', data: {
      'deal_id': deal.id,
      'deal_data': deal.toJson(),
    });
    // Invalidate favorites cache after saving
    _api.invalidateCache('favorites');
  }

  Future<void> removeDeal(String dealId) async {
    await _api.delete('/favorites/$dealId/');
    // Invalidate favorites cache after removing
    _api.invalidateCache('favorites');
  }
}
