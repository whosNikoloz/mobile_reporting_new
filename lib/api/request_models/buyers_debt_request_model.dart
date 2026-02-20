class BuyersDebtRequestModel {
  final DateTime beforeDate;
  final String pathFrom;
  final String pathTo;
  final int page;
  final int pageSize;

  BuyersDebtRequestModel({
    required this.beforeDate,
    this.pathFrom = '0#2#5',
    this.pathTo = '0#2#5%',
    this.page = 1,
    this.pageSize = 20,
  });

  Map<String, dynamic> toJson() => {
        'before_date': beforeDate.toIso8601String(),
        'path_from': pathFrom,
        'path_to': pathTo,
        'page': page,
        'page_size': pageSize,
      };
}

