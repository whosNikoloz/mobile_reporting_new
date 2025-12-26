import 'package:mobile_reporting/models/metric_decimal.dart';
import 'package:mobile_reporting/models/metric_int.dart';

class DashboardGeneral {
  final MetricDecimal sales;
  final MetricDecimal selfcost;
  final MetricDecimal profit;
  final MetricDecimal profitPercent;
  final MetricDecimal avgCheck;
  final MetricInt billsCount;
  final MetricDecimal discount;
  final MetricDecimal refund;

  DashboardGeneral({
    required this.sales,
    required this.selfcost,
    required this.profit,
    required this.profitPercent,
    required this.avgCheck,
    required this.billsCount,
    required this.discount,
    required this.refund,
  });

  factory DashboardGeneral.fromJson(Map<String, dynamic> json) {
    return DashboardGeneral(
      sales: MetricDecimal.fromJson(json['sales']),
      selfcost: MetricDecimal.fromJson(json['selfcost']),
      profit: MetricDecimal.fromJson(json['profit']),
      profitPercent: MetricDecimal.fromJson(json['profit_percent']),
      avgCheck: MetricDecimal.fromJson(json['avg_check']),
      billsCount: MetricInt.fromJson(json['bills_count']),
      discount: MetricDecimal.fromJson(json['discount']),
      refund: MetricDecimal.fromJson(json['refund']),
    );
  }

  Map<String, dynamic> toJson() => {
        'sales': sales.toJson(),
        'selfcost': selfcost.toJson(),
        'profit': profit.toJson(),
        'profit_percent': profitPercent.toJson(),
        'avg_check': avgCheck.toJson(),
        'bills_count': billsCount.toJson(),
        'discount': discount.toJson(),
        'refund': refund.toJson(),
      };
}
