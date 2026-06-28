import '../core/constants/api_endpoints.dart';
import '../models/card_model.dart';
import 'api_client.dart';

class CardService {
  final _api = ApiClient.instance;

  Future<List<CardModel>> list() async {
    final res = await _api.get(ApiEndpoints.cards);
    return (res['cards'] as List).map((e) => CardModel.fromJson(e)).toList();
  }

  Future<CardModel> add({
    required String holderName,
    required String number,
    required int expMonth,
    required int expYear,
  }) async {
    final res = await _api.post(ApiEndpoints.cards, body: {
      'holderName': holderName,
      'number': number,
      'expMonth': expMonth,
      'expYear': expYear,
    });
    return CardModel.fromJson(res['card']);
  }

  Future<void> setDefault(String id) async => _api.patch('${ApiEndpoints.cards}/$id/default');
  Future<void> remove(String id) async => _api.delete('${ApiEndpoints.cards}/$id');
}
