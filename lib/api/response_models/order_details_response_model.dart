import 'package:mobile_reporting/api/response_models/order_item_model.dart';

class OrderDetailsResponseModel {
  final int orderId;
  final String orderNumber;
  final String user;
  final String store;
  final String date;
  final String time;
  final int payType;
  final double? discountPercent;
  final double amount;
  final List<OrderItemModel> items;
  final double total;

  OrderDetailsResponseModel({
    required this.orderId,
    required this.orderNumber,
    required this.user,
    required this.store,
    required this.date,
    required this.time,
    required this.payType,
    required this.discountPercent,
    required this.amount,
    required this.items,
    required this.total,
  });

  factory OrderDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    List<OrderItemModel> parsedItems = [];
    if (rawItems is List) {
      parsedItems = rawItems
          .whereType<Map<String, dynamic>>()
          .map(OrderItemModel.fromJson)
          .toList();
    }

    return OrderDetailsResponseModel(
      orderId: (json['orderId'] as num?)?.toInt() ?? 0,
      orderNumber: (json['orderNumber'] ?? '').toString(),
      user: (json['user'] ?? '').toString(),
      store: (json['store'] ?? '').toString(),
      date: (json['date'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
      payType: (json['payType'] as num?)?.toInt() ?? 0,
      discountPercent: (json['discountPercent'] as num?)?.toDouble(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      items: parsedItems,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

