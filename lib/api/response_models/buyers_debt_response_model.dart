class BuyersDebtResponseModel {
  final String code;
  final String name;
  final double rest;

  BuyersDebtResponseModel({
    required this.code,
    required this.name,
    required this.rest,
  });

  factory BuyersDebtResponseModel.fromJson(Map<String, dynamic> json) {
    return BuyersDebtResponseModel(
      code: (json['code'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      rest: (json['rest'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

