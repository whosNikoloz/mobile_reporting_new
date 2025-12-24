import 'package:mobile_reporting/enums/compare_date_type.dart';
import 'package:mobile_reporting/enums/date_type.dart';
import 'package:mobile_reporting/models/store_model.dart';

class ApplicationStore {
  static final ApplicationStore _application = ApplicationStore._internal();

  factory ApplicationStore() {
    return _application;
  }

  ApplicationStore._internal();

  List<StoreModel> stores = [];

  int? selectedStoreId;

  bool? isFastFood;

  String? lang;

  DateTime? startCurrentPeriod;
  DateTime? endCurrentPeriod;
  DateTime? startOldPeriod;
  DateTime? endOldPeriod;
  DateType? dateType;
  CompareDateType? compareDateType;

  DateTime? dashboardStartCurrentPeriod;
  DateTime? dashboardEndCurrentPeriod;
  DateTime? dashboardStartOldPeriod;
  DateTime? dashboardEndOldPeriod;
  DateType? dashboardDateType;
  CompareDateType? dashboardCompareDateType;
}

ApplicationStore application = ApplicationStore();
