import '../models/storyboard.dart';
import 'api_client.dart';

class StoryboardService {
  final ApiClient _api;

  StoryboardService(this._api);

  Future<List<Storyboard>> getStoryboards() async {
    final response = await _api.get('/storyboard/');
    final list = response.data as List<dynamic>? ?? [];
    return list
        .map((s) => Storyboard.fromJson(s as Map<String, dynamic>))
        .toList();
  }

  Future<Storyboard> createStoryboard({
    required String title,
    required Map<String, dynamic> storyboardData,
    int expiresInDays = 30,
  }) async {
    final response = await _api.post('/storyboard/', data: {
      'title': title,
      'storyboard_data': storyboardData,
      'expires_in_days': expiresInDays,
    });
    return Storyboard.fromJson(response.data);
  }

  Future<Storyboard> getSharedStoryboard(String token) async {
    final response = await _api.get('/storyboard/$token/');
    return Storyboard.fromJson(response.data);
  }

  Future<void> deleteStoryboard(String token) async {
    await _api.delete('/storyboard/$token/');
  }
}
