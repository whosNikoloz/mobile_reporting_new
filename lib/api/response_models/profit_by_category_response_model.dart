class ProfitByCategoryResponseModel {
  final String categoryName;
  final double amount;
  final double selfCost;
  final double vat;
  final double profit;

  ProfitByCategoryResponseModel({
    required this.categoryName,
    required this.amount,
    required this.selfCost,
    required this.vat,
    required this.profit,
  });

  factory ProfitByCategoryResponseModel.fromJson(Map<String, dynamic> json) {
    return ProfitByCategoryResponseModel(
      categoryName: (json['category_name'] ?? '').toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      selfCost: (json['self_cost'] as num?)?.toDouble() ?? 0.0,
      vat: (json['vat'] as num?)?.toDouble() ?? 0.0,
      profit: (json['profit'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

