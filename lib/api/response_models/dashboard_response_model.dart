import 'package:mobile_reporting/api/response_models/dashboard_period_model.dart';

class DashboardResponse {
  final String currency;
  final DashboardPeriod current;
  final DashboardPeriod old;

  DashboardResponse({
    required this.currency,
    required this.current,
    required this.old,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      currency: json['currency'] ?? 'GEL',
      current: DashboardPeriod.fromJson(json['current']),
      old: DashboardPeriod.fromJson(json['old']),
    );
  }

  Map<String, dynamic> toJson() => {
        'currency': currency,
        'current': current.toJson(),
        'old': old.toJson(),
      };
}
