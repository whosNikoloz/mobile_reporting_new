import 'package:json_annotation/json_annotation.dart';

part 'top_product_sales_response_model.g.dart';

@JsonSerializable()
class TopProductSalesResponseModel {
  @JsonKey(name: "product_name")
  String productName;

  @JsonKey(name: "previous_qnt")
  int previousQnt;

  @JsonKey(name: "previous_sales")
  double previousSales;

  @JsonKey(name: "current_qnt")
  int currentQnt;

  @JsonKey(name: "current_sales")
  double currentSales;

  TopProductSalesResponseModel({
    this.productName = "",
    this.previousQnt = 0,
    this.previousSales = 0.0,
    this.currentQnt = 0,
    this.currentSales = 0.0,
  });

  factory TopProductSalesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TopProductSalesResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$TopProductSalesResponseModelToJson(this);
}
