class OrderResponseModel {
  final String orderNumber;
  final String user;
  final double amount;
  final double discountPercent;
  final String payType;

  OrderResponseModel({
    required this.orderNumber,
    required this.user,
    required this.amount,
    required this.discountPercent,
    required this.payType,
  });

  factory OrderResponseModel.fromJson(Map<String, dynamic> json) {
    return OrderResponseModel(
      orderNumber: (json['order_number'] ?? '').toString(),
      user: (json['user'] ?? '').toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      discountPercent: (json['discount_percent'] as num?)?.toDouble() ?? 0.0,
      payType: (json['pay_type'] ?? '').toString(),
    );
  }
}
