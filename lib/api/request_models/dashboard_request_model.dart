class DashboardRequest {
  final int paramId;
  final DateTime startCurrentPeriod;
  final DateTime endCurrentPeriod;
  final DateTime startPreviousPeriod;
  final DateTime endPreviousPeriod;

  DashboardRequest({
    required this.paramId,
    required this.startCurrentPeriod,
    required this.endCurrentPeriod,
    required this.startPreviousPeriod,
    required this.endPreviousPeriod,
  });

  Map<String, dynamic> toJson() => {
        'param_id': paramId,
        'start_current_period': startCurrentPeriod.toIso8601String(),
        'end_current_period': endCurrentPeriod.toIso8601String(),
        'start_previous_period': startPreviousPeriod.toIso8601String(),
        'end_previous_period': endPreviousPeriod.toIso8601String(),
      };
}
