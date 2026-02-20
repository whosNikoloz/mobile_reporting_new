class ProfitByProductsRequestModel {
  final DateTime startDate;
  final DateTime endDate;
  final int page;
  final int pageSize;

  ProfitByProductsRequestModel({
    required this.startDate,
    required this.endDate,
    this.page = 1,
    this.pageSize = 20,
  });

  Map<String, dynamic> toJson() => {
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'page': page,
        'page_size': pageSize,
      };
}
