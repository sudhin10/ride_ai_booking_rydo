import '../core/constants/api_endpoints.dart';
import '../models/transaction_model.dart';
import 'api_client.dart';

class TransactionService {
  final _api = ApiClient.instance;

  Future<List<TransactionModel>> list() async {
    final res = await _api.get(ApiEndpoints.transactions);
    return (res['transactions'] as List).map((e) => TransactionModel.fromJson(e)).toList();
  }
}
