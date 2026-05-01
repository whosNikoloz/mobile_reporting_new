import '../../enums/business_type.dart';

class OrdersRequestModel {
  final int storeId;
  final DateTime startDate;
  final DateTime endDate;
  final int page;
  final int pageSize;
  final String? searchQuery;
  final BusinessType? businessType;

  OrdersRequestModel({
    required this.storeId,
    required this.startDate,
    required this.endDate,
    this.page = 1,
    this.pageSize = 20,
    this.searchQuery,
    this.businessType,
  });

  Map<String, dynamic> toJson() {
    return {
      'store_id': storeId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'page': page,
      'page_size': pageSize,
      'business_type': businessType?.value,
      if (searchQuery != null && searchQuery!.isNotEmpty)
        'search_query': searchQuery,
    };
  }
}
