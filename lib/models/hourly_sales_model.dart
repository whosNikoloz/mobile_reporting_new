class HourlySalesModel {
  final String timeRange;
  final double value;

  HourlySalesModel({
    required this.timeRange,
    required this.value,
  });

  factory HourlySalesModel.fromJson(Map<String, dynamic> json) {
    return HourlySalesModel(
      timeRange: json['time_range'] as String? ?? json['timeRange'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time_range': timeRange,
      'value': value,
    };
  }
}
