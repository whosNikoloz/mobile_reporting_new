class SuppliersDebtResponseModel {
  final String code;
  final String name;
  final double rest;

  SuppliersDebtResponseModel({
    required this.code,
    required this.name,
    required this.rest,
  });

  factory SuppliersDebtResponseModel.fromJson(Map<String, dynamic> json) {
    return SuppliersDebtResponseModel(
      code: (json['code'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      rest: (json['rest'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

