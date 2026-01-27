import 'package:mobile_reporting/models/metric_decimal.dart';
import 'package:mobile_reporting/models/metric_int.dart';

class DashboardBills {
  final MetricDecimal avgCheck;
  final MetricInt billsCount;
  final MetricDecimal discount;
  final MetricDecimal refund;

  DashboardBills({
    required this.avgCheck,
    required this.billsCount,
    required this.discount,
    required this.refund,
  });

  factory DashboardBills.fromJson(Map<String, dynamic> json) {
    return DashboardBills(
      avgCheck: MetricDecimal.fromJson(json['avg_check']),
      billsCount: MetricInt.fromJson(json['bills_count']),
      discount: MetricDecimal.fromJson(json['discount']),
      refund: MetricDecimal.fromJson(json['refund']),
    );
  }

  Map<String, dynamic> toJson() => {
        'avg_check': avgCheck.toJson(),
        'bills_count': billsCount.toJson(),
        'discount': discount.toJson(),
        'refund': refund.toJson(),
      };
}
