class SaleDocumentsProductsDetailsResponseModel {
  final DateTime tDate;
  final String productCode;
  final String productName;
  final String unit;
  final double quantity;
  final double price;
  final double amount;

  SaleDocumentsProductsDetailsResponseModel({
    required this.tDate,
    required this.productCode,
    required this.productName,
    required this.unit,
    required this.quantity,
    required this.price,
    required this.amount,
  });

  factory SaleDocumentsProductsDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    return SaleDocumentsProductsDetailsResponseModel(
      tDate: json['tdate'] != null ? DateTime.parse(json['tdate'] as String) : DateTime.now(),
      productCode: json['product_code'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
