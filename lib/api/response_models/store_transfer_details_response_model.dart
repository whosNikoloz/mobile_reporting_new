class StoreTransferDetailsResponseModel {
  final DateTime tDate;
  final String fromStore;
  final String toStore;
  final String productCode;
  final String productName;
  final String unit;
  final double quantity;

  StoreTransferDetailsResponseModel({
    required this.tDate,
    required this.fromStore,
    required this.toStore,
    required this.productCode,
    required this.productName,
    required this.unit,
    required this.quantity,
  });

  factory StoreTransferDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    return StoreTransferDetailsResponseModel(
      tDate: json['tdate'] != null ? DateTime.parse(json['tdate'] as String) : DateTime.now(),
      fromStore: json['from_store'] as String? ?? '',
      toStore: json['to_store'] as String? ?? '',
      productCode: json['product_code'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
