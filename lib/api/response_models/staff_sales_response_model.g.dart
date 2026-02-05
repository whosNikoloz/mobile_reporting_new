// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_sales_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StaffSalesResponseModel _$StaffSalesResponseModelFromJson(
        Map<String, dynamic> json) =>
    StaffSalesResponseModel(
      staffId: (json['staff_id'] as num).toInt(),
      name: json['name'] as String,
      previousSales: (json['previous_sales'] as num).toDouble(),
      previousChecks: (json['previous_checks'] as num).toInt(),
      previousAvgCheck: (json['previous_avg_check'] as num).toDouble(),
      previousSalesPercent: (json['previous_sales_percent'] as num).toDouble(),
      currentSales: (json['current_sales'] as num).toDouble(),
      currentChecks: (json['current_checks'] as num).toInt(),
      currentAvgCheck: (json['current_avg_check'] as num).toDouble(),
      currentSalesPercent: (json['current_sales_percent'] as num).toDouble(),
    );

Map<String, dynamic> _$StaffSalesResponseModelToJson(
        StaffSalesResponseModel instance) =>
    <String, dynamic>{
      'staff_id': instance.staffId,
      'name': instance.name,
      'previous_sales': instance.previousSales,
      'previous_checks': instance.previousChecks,
      'previous_avg_check': instance.previousAvgCheck,
      'previous_sales_percent': instance.previousSalesPercent,
      'current_sales': instance.currentSales,
      'current_checks': instance.currentChecks,
      'current_avg_check': instance.currentAvgCheck,
      'current_sales_percent': instance.currentSalesPercent,
    };
