import 'package:mobile_reporting/models/report_value_qty_model.dart';

class ReportGroupAndValueQtyModel {
  String tag;
  String type;
  String name;
  List<ReportValueQtyModel> values;

  ReportGroupAndValueQtyModel({
    required this.tag,
    required this.values,
    required this.name,
    required this.type,
  });
}
