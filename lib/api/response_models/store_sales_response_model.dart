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
      storeId: (json['storeId'] ?? 0).toInt(),
      name: json['name'] ?? '',
      previousSales: (json['previousSales'] ?? 0).toDouble(),
      previousChecks: (json['previousChecks'] ?? 0).toInt(),
      previousAvgCheck: (json['previousAvgCheck'] ?? 0).toDouble(),
      previousSalesPercent: (json['previousSalesPercent'] ?? 0).toDouble(),
      currentSales: (json['currentSales'] ?? 0).toDouble(),
      currentChecks: (json['currentChecks'] ?? 0).toInt(),
      currentAvgCheck: (json['currentAvgCheck'] ?? 0).toDouble(),
      currentSalesPercent: (json['currentSalesPercent'] ?? 0).toDouble(),
    );
  }
}
