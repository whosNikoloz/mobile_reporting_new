import 'package:mobile_reporting/api/response_models/dashboard_period_model.dart';

class DashboardResponse {
  final DashboardPeriod current;
  final DashboardPeriod previous;

  DashboardResponse({
    required this.current,
    required this.previous,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      current: DashboardPeriod.fromJson(json['current']),
      previous: DashboardPeriod.fromJson(json['previous']),
    );
  }

  Map<String, dynamic> toJson() => {
        'current': current.toJson(),
        'previous': previous.toJson(),
      };
}
