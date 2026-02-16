class OrderDetailsRequestModel {
  final int orderId;

  OrderDetailsRequestModel({
    required this.orderId,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
    };
  }
}

