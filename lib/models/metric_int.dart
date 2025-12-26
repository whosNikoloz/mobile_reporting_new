class MetricInt {
  final int value;
  final double deltaPercent;

  MetricInt({
    required this.value,
    required this.deltaPercent,
  });

  factory MetricInt.fromJson(Map<String, dynamic> json) {
    return MetricInt(
      value: json['value'],
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
