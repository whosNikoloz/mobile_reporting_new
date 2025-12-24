import 'package:json_annotation/json_annotation.dart';

part 'report_list_qty_response_model.g.dart';

@JsonSerializable()
class ReportListQtyResponseModel {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'current_value')
  final double currentValue;

  @JsonKey(name: 'old_value')
  final double oldValue;

  @JsonKey(name: 'current_quantity')
  final double currentQuantity;

  @JsonKey(name: 'old_quantity')
  final double oldQuantity;

  ReportListQtyResponseModel({
    required this.name,
    required this.currentValue,
    required this.id,
    required this.oldValue,
    required this.currentQuantity,
    required this.oldQuantity,
  });

  factory ReportListQtyResponseModel.fromJson(Map<String, dynamic> json) => _$ReportListQtyResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReportListQtyResponseModelToJson(this);
}
