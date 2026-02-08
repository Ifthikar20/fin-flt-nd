import '../models/deal.dart';
import 'api_client.dart';

class FavoritesService {
  final ApiClient _api;

  FavoritesService(this._api);

  Future<List<Deal>> getFavorites() async {
    final response = await _api.get('/favorites/');
    final list = response.data['favorites'] as List<dynamic>? ??
        response.data as List<dynamic>? ??
        [];
    return list
        .map((d) => Deal.fromJson(d as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveDeal(Deal deal) async {
    await _api.post('/favorites/', data: {
      'deal_id': deal.id,
      'deal_data': deal.toJson(),
    });
  }

  Future<void> removeDeal(String dealId) async {
    await _api.delete('/favorites/$dealId/');
  }
}
