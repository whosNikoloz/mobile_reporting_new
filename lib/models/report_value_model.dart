class ReportValueModel {
  int id;
  String name;
  double currentValue;
  double oldValue;

  ReportValueModel({
    required this.currentValue,
    required this.name,
    required this.oldValue,
    required this.id,
  });
}
