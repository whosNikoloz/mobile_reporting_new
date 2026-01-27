import 'package:mobile_reporting/models/metric_decimal.dart';

class DashboardSales {
  final MetricDecimal sales;
  final MetricDecimal selfcost;
  final MetricDecimal profit;
  final MetricDecimal profitPercent;

  DashboardSales({
    required this.sales,
    required this.selfcost,
    required this.profit,
    required this.profitPercent,
  });

  factory DashboardSales.fromJson(Map<String, dynamic> json) {
    return DashboardSales(
      sales: MetricDecimal.fromJson(json['sales']),
      selfcost: MetricDecimal.fromJson(json['selfcost']),
      profit: MetricDecimal.fromJson(json['profit']),
      profitPercent: MetricDecimal.fromJson(json['profit_percent']),
    );
  }

  Map<String, dynamic> toJson() => {
        'sales': sales.toJson(),
        'selfcost': selfcost.toJson(),
        'profit': profit.toJson(),
        'profit_percent': profitPercent.toJson(),
      };
}
