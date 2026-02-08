import '../models/price_alert.dart';
import 'api_client.dart';

class AlertService {
  final ApiClient _api;

  AlertService(this._api);

  Future<List<PriceAlert>> getAlerts({String? status}) async {
    final response = await _api.get('/alerts/', params: {
      if (status != null) 'status': status,
    });
    final list = response.data as List<dynamic>? ?? [];
    return list
        .map((a) => PriceAlert.fromJson(a as Map<String, dynamic>))
        .toList();
  }

  Future<PriceAlert> createAlert({
    required String productQuery,
    required String productName,
    required double targetPrice,
    double? originalPrice,
    String? productImage,
    String? productUrl,
  }) async {
    final response = await _api.post('/alerts/', data: {
      'product_query': productQuery,
      'product_name': productName,
      'target_price': targetPrice.toStringAsFixed(2),
      if (originalPrice != null)
        'original_price': originalPrice.toStringAsFixed(2),
      if (productImage != null) 'product_image': productImage,
      if (productUrl != null) 'product_url': productUrl,
      'currency': 'USD',
    });
    return PriceAlert.fromJson(response.data);
  }

  Future<void> deleteAlert(String alertId) async {
    await _api.delete('/alerts/$alertId/');
  }
}
