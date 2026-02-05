class StoreSalesResponseModel {
  final int storeId;
  final String name;
  final double previousSales;
  final int previousChecks;
  final double previousAvgCheck;
  final double previousSalesPercent;
  final double currentSales;
  final int currentChecks;
  final double currentAvgCheck;
  final double currentSalesPercent;

  StoreSalesResponseModel({
    required this.storeId,
    required this.name,
    required this.previousSales,
    required this.previousChecks,
    required this.previousAvgCheck,
    required this.previousSalesPercent,
    required this.currentSales,
    required this.currentChecks,
    required this.currentAvgCheck,
    required this.currentSalesPercent,
  });

  factory StoreSalesResponseModel.fromJson(Map<String, dynamic> json) {
    return StoreSalesResponseModel(
      storeId: (json['store_id'] ?? 0) as int,
      name: json['name'] ?? '',
      previousSales: (json['previous_sales'] ?? 0).toDouble(),
      previousChecks: (json['previous_checks'] ?? 0) as int,
      previousAvgCheck: (json['previous_avg_check'] ?? 0).toDouble(),
      previousSalesPercent: (json['previous_sales_percent'] ?? 0).toDouble(),
      currentSales: (json['current_sales'] ?? 0).toDouble(),
      currentChecks: (json['current_checks'] ?? 0) as int,
      currentAvgCheck: (json['current_avg_check'] ?? 0).toDouble(),
      currentSalesPercent: (json['current_sales_percent'] ?? 0).toDouble(),
    );
  }
}
