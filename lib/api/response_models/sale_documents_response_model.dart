class SaleDocumentsResponseModel {
  final DateTime tDate;
  final String contragentName;
  final double amount;

  SaleDocumentsResponseModel({
    required this.tDate,
    required this.contragentName,
    required this.amount,
  });

  factory SaleDocumentsResponseModel.fromJson(Map<String, dynamic> json) {
    return SaleDocumentsResponseModel(
      tDate: json['tdate'] != null ? DateTime.parse(json['tdate'] as String) : DateTime.now(),
      contragentName: json['contragent_name'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
