class ProfitByProductResponseModel {
  final String productName;
  final double amount;
  final double selfCost;
  final double vat;
  final double profit;

  ProfitByProductResponseModel({
    required this.productName,
    required this.amount,
    required this.selfCost,
    required this.vat,
    required this.profit,
  });

  factory ProfitByProductResponseModel.fromJson(Map<String, dynamic> json) {
    return ProfitByProductResponseModel(
      productName: (json['product_name'] ?? '').toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      selfCost: (json['self_cost'] as num?)?.toDouble() ?? 0.0,
      vat: (json['vat'] as num?)?.toDouble() ?? 0.0,
      profit: (json['profit'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
