class DashboardRequest {
  final int paramId;
  final int paramId2;
  final DateTime startCurrentPeriod;
  final DateTime endCurrentPeriod;
  final DateTime startOldPeriod;
  final DateTime endOldPeriod;

  DashboardRequest({
    required this.paramId,
    required this.paramId2,
    required this.startCurrentPeriod,
    required this.endCurrentPeriod,
    required this.startOldPeriod,
    required this.endOldPeriod,
  });

  Map<String, dynamic> toJson() => {
        'param_id': paramId,
        'param_id2': paramId2,
        'start_current_period': startCurrentPeriod.toIso8601String(),
        'end_current_period': endCurrentPeriod.toIso8601String(),
        'start_old_period': startOldPeriod.toIso8601String(),
        'end_old_period': endOldPeriod.toIso8601String(),
      };
}
