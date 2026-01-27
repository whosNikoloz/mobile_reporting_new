import 'package:mobile_reporting/api/response_models/dashboard_sales_model.dart';
import 'package:mobile_reporting/api/response_models/dashboard_bills_model.dart';
import 'package:mobile_reporting/api/response_models/dashboard_payments_model.dart';

class DashboardPeriod {
  final DashboardSales sales;
  final DashboardBills bills;
  final DashboardPayments payments;

  DashboardPeriod({
    required this.sales,
    required this.bills,
    required this.payments,
  });

  factory DashboardPeriod.fromJson(Map<String, dynamic> json) {
    return DashboardPeriod(
      sales: DashboardSales.fromJson(json['sales']),
      bills: DashboardBills.fromJson(json['bills']),
      payments: DashboardPayments.fromJson(json['payments']),
    );
  }

  Map<String, dynamic> toJson() => {
        'sales': sales.toJson(),
        'bills': bills.toJson(),
        'payments': payments.toJson(),
      };
}
