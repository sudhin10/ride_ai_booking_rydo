class CardModel {
  final String id;
  final String holderName;
  final String brand;
  final String last4;
  final int expMonth;
  final int expYear;
  final bool isDefault;

  const CardModel({
    required this.id,
    required this.holderName,
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    this.isDefault = false,
  });

  factory CardModel.fromJson(Map<String, dynamic> j) => CardModel(
        id: j['_id'] ?? j['id'] ?? '',
        holderName: j['holderName'] ?? '',
        brand: j['brand'] ?? 'other',
        last4: j['last4'] ?? '----',
        expMonth: j['expMonth'] ?? 1,
        expYear: j['expYear'] ?? 2030,
        isDefault: j['isDefault'] ?? false,
      );

  String get masked => '•••• •••• •••• $last4';
  String get expiry => '${expMonth.toString().padLeft(2, '0')}/${expYear.toString().substring(2)}';
}
