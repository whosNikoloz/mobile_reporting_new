class VendorPaymentsResponseModel {
  final String code;
  final String name;
  final int bollsCount;
  final double amount;

  VendorPaymentsResponseModel({
    required this.code,
    required this.name,
    required this.bollsCount,
    required this.amount,
  });

  factory VendorPaymentsResponseModel.fromJson(Map<String, dynamic> json) {
    return VendorPaymentsResponseModel(
      code: (json['code'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      bollsCount: (json['bolls_count'] as num?)?.toInt() ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

