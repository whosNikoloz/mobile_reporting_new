class ProductSalesSummaryResponseModel {
  final String productCode;
  final String productName;
  final String unit;
  final double quantity;
  final double amount;

  ProductSalesSummaryResponseModel({
    required this.productCode,
    required this.productName,
    required this.unit,
    required this.quantity,
    required this.amount,
  });

  factory ProductSalesSummaryResponseModel.fromJson(Map<String, dynamic> json) {
    return ProductSalesSummaryResponseModel(
      productCode: json['product_code'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
