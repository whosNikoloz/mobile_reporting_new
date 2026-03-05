class ProductRestResponseModel {
  final String productName;
  final String unit;
  final double rest;

  ProductRestResponseModel({
    required this.productName,
    required this.unit,
    required this.rest,
  });

  factory ProductRestResponseModel.fromJson(Map<String, dynamic> json) {
    return ProductRestResponseModel(
      productName: json['product_name'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      rest: (json['rest'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
