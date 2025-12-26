import 'package:mobile_reporting/api/response_models/dashboard_general_model.dart';
import 'package:mobile_reporting/api/response_models/dashboard_payments_model.dart';
import 'package:mobile_reporting/models/sales_by_hour.dart';

class DashboardPeriod {
  final DashboardGeneral general;
  final DashboardPayments payments;
  final List<SalesByHour> salesByHours;

  DashboardPeriod({
    required this.general,
    required this.payments,
    required this.salesByHours,
  });

  factory DashboardPeriod.fromJson(Map<String, dynamic> json) {
    return DashboardPeriod(
      general: DashboardGeneral.fromJson(json['general']),
      payments: DashboardPayments.fromJson(json['payments']),
      salesByHours: (json['sales_by_hours'] as List)
          .map((e) => SalesByHour.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'general': general.toJson(),
        'payments': payments.toJson(),
        'sales_by_hours': salesByHours.map((e) => e.toJson()).toList(),
      };
}
