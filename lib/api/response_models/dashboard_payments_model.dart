import 'package:mobile_reporting/models/metric_decimal.dart';

class DashboardPayments {
  final MetricDecimal cash;
  final MetricDecimal card;
  final MetricDecimal consignation;
  final MetricDecimal loyalty;

  DashboardPayments({
    required this.cash,
    required this.card,
    required this.consignation,
    required this.loyalty,
  });

  factory DashboardPayments.fromJson(Map<String, dynamic> json) {
    return DashboardPayments(
      cash: MetricDecimal.fromJson(json['cash']),
      card: MetricDecimal.fromJson(json['card']),
      consignation: MetricDecimal.fromJson(json['consignation']),
      loyalty: MetricDecimal.fromJson(json['loyalty']),
    );
  }

  Map<String, dynamic> toJson() => {
        'cash': cash.toJson(),
        'card': card.toJson(),
        'consignation': consignation.toJson(),
        'loyalty': loyalty.toJson(),
      };
}
