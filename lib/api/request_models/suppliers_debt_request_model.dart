class SuppliersDebtRequestModel {
  final DateTime beforeDate;
  final int page;
  final int pageSize;

  SuppliersDebtRequestModel({
    required this.beforeDate,
    this.page = 1,
    this.pageSize = 20,
  });

  Map<String, dynamic> toJson() => {
        'before_date': beforeDate.toIso8601String(),
        'page': page,
        'page_size': pageSize,
      };
}

