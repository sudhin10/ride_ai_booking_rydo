class TransactionModel {
  final String id;
  final String type;
  final double amount;
  final String method;
  final String status;
  final String description;
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.method,
    required this.status,
    required this.description,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> j) => TransactionModel(
        id: j['_id'] ?? j['id'] ?? '',
        type: j['type'] ?? 'ride_payment',
        amount: (j['amount'] ?? 0).toDouble(),
        method: j['method'] ?? 'card',
        status: j['status'] ?? 'success',
        description: j['description'] ?? '',
        createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
      );

  bool get isCredit => type == 'topup' || type == 'refund';
}
