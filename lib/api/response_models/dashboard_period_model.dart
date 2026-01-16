import 'package:mobile_reporting/api/response_models/dashboard_general_model.dart';
import 'package:mobile_reporting/api/response_models/dashboard_payments_model.dart';

class DashboardPeriod {
  final DashboardGeneral general;
  final DashboardPayments payments;

  DashboardPeriod({
    required this.general,
    required this.payments,
  });

  factory DashboardPeriod.fromJson(Map<String, dynamic> json) {
    return DashboardPeriod(
      general: DashboardGeneral.fromJson(json['general']),
      payments: DashboardPayments.fromJson(json['payments']),
    );
  }

  Map<String, dynamic> toJson() => {
        'general': general.toJson(),
        'payments': payments.toJson(),
      };
}
