class MonthlySalesResponseModel {
  final String month;
  final double previousSales;
  final int previousChecks;
  final double previousAvgCheck;
  final double previousSalesPercent;
  final double currentSales;
  final int currentChecks;
  final double currentAvgCheck;
  final double currentSalesPercent;

  MonthlySalesResponseModel({
    required this.month,
    required this.previousSales,
    required this.previousChecks,
    required this.previousAvgCheck,
    required this.previousSalesPercent,
    required this.currentSales,
    required this.currentChecks,
    required this.currentAvgCheck,
    required this.currentSalesPercent,
  });

  factory MonthlySalesResponseModel.fromJson(Map<String, dynamic> json) {
    return MonthlySalesResponseModel(
      month: json['month'] ?? '',
      previousSales: (json['previous_sales'] ?? 0).toDouble(),
      previousChecks: (json['previous_checks'] ?? 0).toInt(),
      previousAvgCheck: (json['previous_avg_check'] ?? 0).toDouble(),
      previousSalesPercent: (json['previous_sales_percent'] ?? 0).toDouble(),
      currentSales: (json['current_sales'] ?? 0).toDouble(),
      currentChecks: (json['current_checks'] ?? 0).toInt(),
      currentAvgCheck: (json['current_avg_check'] ?? 0).toDouble(),
      currentSalesPercent: (json['current_sales_percent'] ?? 0).toDouble(),
    );
  }
}
