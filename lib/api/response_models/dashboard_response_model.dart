import 'package:mobile_reporting/api/response_models/dashboard_period_model.dart';

class DashboardResponse {
  final String currency;
  final DashboardPeriod current;
  final DashboardPeriod previous;

  DashboardResponse({
    required this.currency,
    required this.current,
    required this.previous,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      currency: json['currency'] ?? 'GEL',
      current: DashboardPeriod.fromJson(json['current']),
      previous: DashboardPeriod.fromJson(json['previous']),
    );
  }

  Map<String, dynamic> toJson() => {
        'currency': currency,
        'current': current.toJson(),
        'previous': previous.toJson(),
      };
}
