class MetricDecimal {
  final double value;
  final double deltaPercent;

  MetricDecimal({
    required this.value,
    required this.deltaPercent,
  });

  factory MetricDecimal.fromJson(Map<String, dynamic> json) {
    return MetricDecimal(
      value: (json['value'] as num).toDouble(),
      deltaPercent: (json['delta_percent'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'value': value,
        'delta_percent': deltaPercent,
      };

  bool get hasChange => deltaPercent != 0;
  bool get isPositive => deltaPercent > 0;
}
