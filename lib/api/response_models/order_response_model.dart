class OrderResponseModel {
  final int orderId;
  final String orderNumber;
  final String user;
  final double amount;
  final String orderTime;
  final int? payType;
  final int? status;

  OrderResponseModel({
    required this.orderId,
    required this.orderNumber,
    required this.user,
    required this.amount,
    required this.orderTime,
    required this.payType,
    required this.status,
  });

  factory OrderResponseModel.fromJson(Map<String, dynamic> json) {
    return OrderResponseModel(
      orderId: (json['orderId'] as num?)?.toInt() ??
          (json['order_id'] as num?)?.toInt() ??
          0,
      orderNumber: (json['order_number'] ?? '').toString(),
      user: (json['user'] ?? '').toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      orderTime: (json['order_time'] ?? '').toString(),
      payType: (json['pay_type'] as num?)?.toInt(),
      status: (json['status'] as num?)?.toInt(),
    );
  }
}
