import 'package:mobile_reporting/models/report_value_qty_model.dart';

class ReportGroupAndValueModel {
  String tag;
  String type;
  String name;
  List<ReportValueQtyModel> values;

  ReportGroupAndValueModel({
    required this.tag,
    required this.values,
    required this.name,
    required this.type,
  });
}
