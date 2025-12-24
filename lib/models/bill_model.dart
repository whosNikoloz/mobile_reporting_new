class BillModel {
  final int id;
  final DateTime tdate;
  final String docNum;
  final double amount;
  final String userName;
  final String storeName;
  final String roomName;
  final String orderType;
  bool isVisible;

  BillModel({
    required this.amount,
    required this.docNum,
    required this.id,
    required this.orderType,
    required this.roomName,
    required this.storeName,
    required this.tdate,
    required this.userName,
    this.isVisible = true,
  });
}
