import 'package:mobile_reporting/enums/compare_date_type.dart';
import 'package:mobile_reporting/enums/date_type.dart';
import 'package:mobile_reporting/models/store_model.dart';

import 'package:mobile_reporting/helpers/preferences_helper.dart';

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
  String? accountLang;

  DateTime? startCurrentPeriod;
  DateTime? endCurrentPeriod;
  DateTime? startOldPeriod;
  DateTime? endOldPeriod;
  DateType? dateType;
  CompareDateType? compareDateType;

  final PreferencesHelper _prefs = PreferencesHelper();

  Future<void> loadFilters() async {
    // Load Store
    final storeId = await _prefs.getSelectedStoreId();
    selectedStoreId = storeId;

    // Load Date Type
    final dateTypeStr = await _prefs.getReportDateType();
    if (dateTypeStr != null) {
      dateType = DateType.values.firstWhere(
        (e) => e.toString() == dateTypeStr,
        orElse: () => DateType.day,
      );
    } else {
      dateType = DateType.day;
    }

    // Load Report Period
    final (startStr, endStr) = await _prefs.getReportPeriod();
    if (startStr != null && endStr != null) {
      startCurrentPeriod = DateTime.tryParse(startStr);
      endCurrentPeriod = DateTime.tryParse(endStr);
    } else {
      _setDefaultDates();
    }

    // Load Compare Date Type
    final compareTypeStr = await _prefs.getReportCompareDateType();
    if (compareTypeStr != null) {
      compareDateType = CompareDateType.values.firstWhere(
        (e) => e.toString() == compareTypeStr,
        orElse: () => CompareDateType.lastDay,
      );
    } else {
      compareDateType = CompareDateType.lastDay;
    }

    // Load Compare Period
    final (compareStartStr, compareEndStr) =
        await _prefs.getReportComparePeriod();
    if (compareStartStr != null && compareEndStr != null) {
      startOldPeriod = DateTime.tryParse(compareStartStr);
      endOldPeriod = DateTime.tryParse(compareEndStr);
    } else {
      _setDefaultCompareDates();
    }
  }

  Future<void> saveFilters() async {
    await _prefs.setSelectedStoreId(selectedStoreId);
    if (dateType != null) {
      await _prefs.setReportDateType(dateType.toString());
    }
    if (startCurrentPeriod != null && endCurrentPeriod != null) {
      await _prefs.setReportPeriod(startCurrentPeriod!, endCurrentPeriod!);
    }
    if (compareDateType != null) {
      await _prefs.setReportCompareDateType(compareDateType.toString());
    }
    if (startOldPeriod != null && endOldPeriod != null) {
      await _prefs.setReportComparePeriod(startOldPeriod!, endOldPeriod!);
    }
  }

  void _setDefaultDates() {
    final now = DateTime.now();
    startCurrentPeriod = DateTime(now.year, now.month, now.day, 0, 0);
    endCurrentPeriod = DateTime(now.year, now.month, now.day, 23, 59);
  }

  void _setDefaultCompareDates() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    startOldPeriod = DateTime(yesterday.year, yesterday.month, yesterday.day, 0, 0);
    endOldPeriod = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59);
  }
}

ApplicationStore application = ApplicationStore();
