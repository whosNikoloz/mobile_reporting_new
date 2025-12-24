class ReportValueQtyModel {
  int id;
  String name;
  double currentValue;
  double oldValue;
  double currentQuantity;
  double oldQuantity;

  ReportValueQtyModel({
    required this.currentValue,
    required this.name,
    required this.oldValue,
    required this.id,
    required this.currentQuantity,
    required this.oldQuantity,
  });
}
