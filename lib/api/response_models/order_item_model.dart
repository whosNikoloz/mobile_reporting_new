class OrderItemModel {
  final String name;
  final double quantity;
  final double amount;

  OrderItemModel({
    required this.name,
    required this.quantity,
    required this.amount,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      name: (json['name'] ?? json['item_name'] ?? '').toString(),
      quantity: (json['qty'] as num?)?.toDouble() ?? 0.0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

