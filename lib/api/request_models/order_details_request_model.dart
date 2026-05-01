import '../../enums/business_type.dart';

class OrderDetailsRequestModel {
  final int orderId;
  final BusinessType? businessType;

  OrderDetailsRequestModel({
    required this.orderId,
    this.businessType,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'business_type': businessType?.value,
    };
  }
}

