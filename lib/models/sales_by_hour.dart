class SalesByHour {
  final String hour;
  final double amount;
  final int billsCount;

  SalesByHour({
    required this.hour,
    required this.amount,
    required this.billsCount,
  });

  factory SalesByHour.fromJson(Map<String, dynamic> json) {
    return SalesByHour(
      hour: json['hour'],
      amount: (json['amount'] as num).toDouble(),
      billsCount: json['bills_count'],
    );
  }

  Map<String, dynamic> toJson() => {
        'hour': hour,
        'amount': amount,
        'bills_count': billsCount,
      };
}
