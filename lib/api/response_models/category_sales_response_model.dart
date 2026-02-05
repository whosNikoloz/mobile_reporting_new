import 'package:json_annotation/json_annotation.dart';

part 'category_sales_response_model.g.dart';

@JsonSerializable()
class CategorySalesResponseModel {
  @JsonKey(name: 'category_name')
  final String categoryName;

  @JsonKey(name: 'previous_sales')
  final double previousSales;

  @JsonKey(name: 'current_sales')
  final double currentSales;

  CategorySalesResponseModel({
    required this.categoryName,
    required this.previousSales,
    required this.currentSales,
  });

  factory CategorySalesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CategorySalesResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategorySalesResponseModelToJson(this);
}
