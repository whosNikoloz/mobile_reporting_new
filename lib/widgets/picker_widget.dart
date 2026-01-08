import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mobile_reporting/application_store.dart';
import 'package:mobile_reporting/enums/compare_date_type.dart';
import 'package:mobile_reporting/enums/date_type.dart';
import 'package:intl/intl.dart';
import 'package:mobile_reporting/localization/generated/l10n.dart';

import 'package:mobile_reporting/enums/screen_type.dart';
import 'package:mobile_reporting/models/store_model.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:mobile_reporting/theme/app_theme.dart';
import 'package:mobile_reporting/widgets/date_ranger_picker.dart';

class PickerWidget extends StatefulWidget {
  const PickerWidget({
    super.key,
    required this.getDate,
    required this.onlyDayPicker,
    this.showCompareDateFilter = false,
    this.showStoreFilter = false,
    required this.screenType,
  });

  final Future<void> Function(
    DateTime dt1,
    DateTime dt2,
    DateTime dt3,
    DateTime dt4,
    double? minAmount,
    double? maxAmount,
    String? billNum,
  ) getDate;
  final bool onlyDayPicker;
  final bool showStoreFilter;
  final bool showCompareDateFilter;
  final ScreenType screenType;

  @override
  PickerWidgetState createState() => PickerWidgetState();
}

class PickerWidgetState extends State<PickerWidget> {
  bool isLoading = true;
  DateTime currentDate1 = DateTime.now();
  DateTime currentDate2 = DateTime.now();
  DateTime oldDate1 = DateTime.now().subtract(const Duration(days: 1));
  DateTime oldDate2 = DateTime.now().subtract(const Duration(days: 1));
  bool firstLoad = true;
  DateType dt = DateType.day;
  CompareDateType cdt = CompareDateType.lastDay;

  @override
  void initState() {
    super.initState();
    _initializeDates();
  }

  void _initializeDates() {
    if (widget.screenType == ScreenType.dashboardScreen &&
        application.dashboardDateType == null) {
      _setTodayDates();
      dt = DateType.day;
      cdt = CompareDateType.lastDay;
    } else if (widget.screenType == ScreenType.dashboardScreen &&
        application.dashboardDateType != null) {
      _loadSavedDashboardDates();
    } else if (widget.screenType == ScreenType.reportssScreen &&
        application.dateType == null) {
      _setCurrentMonthDates();
      dt = DateType.month;
      cdt = CompareDateType.lastMonth;
      _saveDates();
    } else if (application.dateType != null &&
        widget.screenType == ScreenType.reportssScreen) {
      _loadSavedReportDates();
    }
  }

  void _setTodayDates() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    currentDate1 = DateTime(now.year, now.month, now.day, 0, 0);
    currentDate2 = DateTime(now.year, now.month, now.day, 23, 59);
    oldDate1 = DateTime(yesterday.year, yesterday.month, yesterday.day, 0, 0);
    oldDate2 = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59);
  }

  void _setCurrentMonthDates() {
    final now = DateTime.now();
    currentDate1 = DateTime(now.year, now.month, 1, 0, 0);
    currentDate2 = DateTime(now.year, now.month + 1, 0, 23, 59);
    oldDate1 = DateTime(now.year, now.month - 1, now.day, 0, 0);
    oldDate2 = DateTime(now.year, now.month, 0, 23, 59);
  }

  void _loadSavedDashboardDates() {
    dt = application.dashboardDateType!;
    cdt = application.dashboardCompareDateType!;
    currentDate1 = application.dashboardStartCurrentPeriod!;
    currentDate2 = application.dashboardEndCurrentPeriod!;
    oldDate1 = application.dashboardStartOldPeriod!;
    oldDate2 = application.dashboardEndOldPeriod!;
  }

  void _loadSavedReportDates() {
    dt = application.dateType!;
    cdt = application.compareDateType!;
    currentDate1 = application.startCurrentPeriod!;
    currentDate2 = application.endCurrentPeriod!;
    oldDate1 = application.startOldPeriod!;
    oldDate2 = application.endOldPeriod!;
  }

  void _saveDates() {
    if (widget.screenType == ScreenType.dashboardScreen) {
      application.dashboardDateType = dt;
      application.dashboardCompareDateType = cdt;
      application.dashboardStartCurrentPeriod = currentDate1;
      application.dashboardEndCurrentPeriod = currentDate2;
      application.dashboardStartOldPeriod = oldDate1;
      application.dashboardEndOldPeriod = oldDate2;
    } else {
      application.startCurrentPeriod = currentDate1;
      application.endCurrentPeriod = currentDate2;
      application.startOldPeriod = oldDate1;
      application.endOldPeriod = oldDate2;
      application.dateType = dt;
      application.compareDateType = cdt;
    }
  }

  Future<void> _loadData() async {
    isLoading = true;
    setState(() {});
    await widget.getDate(
        currentDate1, currentDate2, oldDate1, oldDate2, null, null, null);
    _saveDates();
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (firstLoad) {
      widget
          .getDate(
              currentDate1, currentDate2, oldDate1, oldDate2, null, null, null)
          .then((_) {
        isLoading = false;
        setState(() {});
      });
      firstLoad = false;
    }

    final bool showStore =
        widget.showStoreFilter && application.stores.length > 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.grey.shade100),
      child: Column(
        children: [
          // If comparison is enabled, stack vertically with full width
          if (widget.showCompareDateFilter) ...[
            _DateSelector(
              currentDate1: currentDate1,
              currentDate2: currentDate2,
              oldDate1: oldDate1,
              oldDate2: oldDate2,
              dateType: dt,
              isLoading: isLoading,
              showComparison: widget.showCompareDateFilter,
              onDateSelected: _handleDateSelection,
            ),
            if (showStore) ...[
              const SizedBox(height: 12),
              _StoreSelector(onStoreChanged: _loadData),
            ],
          ]
          // If no comparison, keep them in a row as before
          else ...[
            Row(
              children: [
                Expanded(
                  child: _DateSelector(
                    currentDate1: currentDate1,
                    currentDate2: currentDate2,
                    oldDate1: oldDate1,
                    oldDate2: oldDate2,
                    dateType: dt,
                    isLoading: isLoading,
                    showComparison: widget.showCompareDateFilter,
                    onDateSelected: _handleDateSelection,
                  ),
                ),
                if (showStore) const SizedBox(width: 12),
                if (showStore)
                  Expanded(
                    child: _StoreSelector(onStoreChanged: _loadData),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleDateSelection(DateTime start, DateTime end, DateType type,
      {DateTime? compareStart, DateTime? compareEnd}) async {
    final bool periodChanged =
        dt != type || currentDate1 != start || currentDate2 != end;

    currentDate1 = start;
    currentDate2 = end;
    dt = type;

    if (compareStart != null && compareEnd != null) {
      // Use the comparison dates from the picker
      oldDate1 = compareStart;
      oldDate2 = compareEnd;
    } else if (periodChanged) {
      // Calculate default comparison based on period type
      _calculateDefaultComparison();
    }

    await _loadData();
  }

  void _calculateDefaultComparison() {
    switch (dt) {
      case DateType.day:
        // Previous day
        oldDate1 = currentDate1.subtract(const Duration(days: 1));
        oldDate2 = currentDate2.subtract(const Duration(days: 1));
        break;
      case DateType.week:
        // Previous week (7 days back)
        oldDate1 = currentDate1.subtract(const Duration(days: 7));
        oldDate2 = currentDate2.subtract(const Duration(days: 7));
        break;
      case DateType.month:
        // Previous month
        oldDate1 = DateTime(
            currentDate1.year, currentDate1.month - 1, currentDate1.day, 0, 0);
        oldDate2 = DateTime(currentDate2.year, currentDate2.month - 1,
            currentDate2.day, 23, 59);
        break;
      case DateType.year:
        // Previous year
        oldDate1 = DateTime(
            currentDate1.year - 1, currentDate1.month, currentDate1.day, 0, 0);
        oldDate2 = DateTime(currentDate2.year - 1, currentDate2.month,
            currentDate2.day, 23, 59);
        break;
      case DateType.period:
        // Same duration back
        final duration = currentDate2.difference(currentDate1);
        oldDate1 =
            currentDate1.subtract(duration).subtract(const Duration(days: 1));
        oldDate2 = currentDate1.subtract(const Duration(days: 1));
        break;
    }
  }

  Future<void> _handleCompareSelection(
      CompareDateType type, DateTime start, DateTime end) async {
    cdt = type;
    oldDate1 = start;
    oldDate2 = end;
    await _loadData();
  }
}

// Date Selector Widget
class _DateSelector extends StatelessWidget {
  final DateTime currentDate1;
  final DateTime currentDate2;
  final DateTime oldDate1;
  final DateTime oldDate2;
  final DateType dateType;
  final bool isLoading;
  final bool showComparison;
  final Future<void> Function(DateTime, DateTime, DateType,
      {DateTime? compareStart, DateTime? compareEnd}) onDateSelected;

  const _DateSelector({
    required this.currentDate1,
    required this.currentDate2,
    required this.oldDate1,
    required this.oldDate2,
    required this.dateType,
    required this.isLoading,
    required this.showComparison,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDatePicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today,
                size: 18, color: AppTheme.primaryBlue),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                showComparison ? _getCombinedDateText() : _getCurrentDateText(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.2,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                ),
              )
            else
              Icon(Icons.keyboard_arrow_down,
                  size: 18, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  String _getCurrentDateText() {
    if (dateType == DateType.day) {
      return DateFormat('dd.MM.yy').format(currentDate1);
    } else if (dateType == DateType.month) {
      return DateFormat('MMM yyyy').format(currentDate1);
    } else if (dateType == DateType.year) {
      return currentDate1.year.toString();
    } else {
      return '${DateFormat('dd.MM.yy').format(currentDate1)} - ${DateFormat('dd.MM.yy').format(currentDate2)}';
    }
  }

  String _getCombinedDateText() {
    String currentPeriod;
    String comparisonPeriod;

    if (dateType == DateType.day) {
      currentPeriod = DateFormat('dd.MM.yy').format(currentDate1);
      comparisonPeriod = DateFormat('dd.MM.yy').format(oldDate1);
    } else if (dateType == DateType.month) {
      currentPeriod = DateFormat('MMM yyyy').format(currentDate1);
      comparisonPeriod = DateFormat('MMM yyyy').format(oldDate1);
    } else if (dateType == DateType.year) {
      currentPeriod = currentDate1.year.toString();
      comparisonPeriod = oldDate1.year.toString();
    } else {
      // For week/period, show date ranges
      currentPeriod =
          '${DateFormat('dd.MM.yy').format(currentDate1)} - ${DateFormat('dd.MM.yy').format(currentDate2)}';
      comparisonPeriod =
          '${DateFormat('dd.MM.yy').format(oldDate1)} - ${DateFormat('dd.MM.yy').format(oldDate2)}';
    }

    return '$currentPeriod to $comparisonPeriod';
  }

  String _getComparisonText(BuildContext context) {
    // For year comparisons
    if (dateType == DateType.year) {
      return '${currentDate1.year} vs ${oldDate1.year}';
    }

    // For month comparisons
    if (dateType == DateType.month) {
      return '${DateFormat('MMM yyyy').format(currentDate1)} vs ${DateFormat('MMM yyyy').format(oldDate1)}';
    }

    // For day comparisons, show simple dates
    if (dateType == DateType.day) {
      // Check if it's today vs yesterday
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      if (_isSameDay(currentDate1, today) && _isSameDay(oldDate1, yesterday)) {
        return S.of(context).todayVsYesterday;
      }

      return '${DateFormat('dd.MM.yy').format(currentDate1)} vs ${DateFormat('dd.MM.yy').format(oldDate1)}';
    }

    // For week/period comparisons, show date ranges
    return '${DateFormat('dd.MM').format(oldDate1)} - ${DateFormat('dd.MM').format(oldDate2)}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _showDatePicker(BuildContext context) async {
    PeriodType initialPeriodType = PeriodType.day;
    if (dateType == DateType.week) {
      initialPeriodType = PeriodType.week;
    } else if (dateType == DateType.month) {
      initialPeriodType = PeriodType.month;
    } else if (dateType == DateType.year) {
      initialPeriodType = PeriodType.year;
    } else if (dateType == DateType.period) {
      initialPeriodType = PeriodType.period;
    }

    final result = await showDialog<DateRangePickerResult>(
      context: context,
      builder: (context) => DateRangePicker(
        initialStartDate: currentDate1,
        initialEndDate: currentDate2,
        initialPeriodType: initialPeriodType,
        initialCompareStartDate: oldDate1,
        initialCompareEndDate: oldDate2,
      ),
    );

    if (result == null) return;

    DateType newDateType = DateType.day;
    switch (result.periodType) {
      case PeriodType.day:
        newDateType = DateType.day;
        break;
      case PeriodType.week:
        newDateType = DateType.week;
        break;
      case PeriodType.month:
        newDateType = DateType.month;
        break;
      case PeriodType.year:
        newDateType = DateType.year;
        break;
      case PeriodType.period:
        newDateType = DateType.period;
        break;
    }

    await onDateSelected(
      result.startDate,
      result.endDate,
      newDateType,
      compareStart: result.compareStartDate,
      compareEnd: result.compareEndDate,
    );
  }
}

// Store Selector Widget
class _StoreSelector extends StatelessWidget {
  final VoidCallback onStoreChanged;

  const _StoreSelector({required this.onStoreChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showStoreDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.storefront, size: 20, color: AppTheme.primaryBlue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _getStoreName(context),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  letterSpacing: 0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.keyboard_arrow_down,
                size: 20, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  String _getStoreName(BuildContext context) {
    if (application.selectedStoreId != null) {
      return application.stores
          .firstWhere((element) => element.id == application.selectedStoreId)
          .name;
    }
    return S.of(context).allBranches;
  }

  Future<void> _showStoreDialog(BuildContext context) async {
    List<StoreModel> stores = [
      StoreModel(id: null, name: S.of(context).allBranches),
      ...application.stores,
    ];

    final storeChanged = await showDialog<bool>(
      context: context,
      builder: (context) => _StoreSelectorDialog(
        stores: stores,
        selectedStoreId: application.selectedStoreId,
        onStoreSelected: (storeId) {
          application.selectedStoreId = storeId;
        },
      ),
    );

    if (storeChanged == true) {
      onStoreChanged();
    }
  }
}

// Compare Date Filter Widget
class _CompareDateFilter extends StatelessWidget {
  final DateType dateType;
  final CompareDateType compareDateType;
  final DateTime oldDate1;
  final DateTime oldDate2;
  final Future<void> Function(CompareDateType, DateTime, DateTime)
      onCompareOptionSelected;

  const _CompareDateFilter({
    required this.dateType,
    required this.compareDateType,
    required this.oldDate1,
    required this.oldDate2,
    required this.onCompareOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(color: Colors.grey.shade100),
      child: GestureDetector(
        onTap: () => _showCompareOptions(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.compare_arrows,
                  size: 20, color: AppTheme.primaryBlue),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${S.of(context).comparisonLabel}: ${_getCompareDateText(context)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getOldDateText(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        letterSpacing: 0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.keyboard_arrow_down,
                  size: 20, color: Colors.grey.shade600),
            ],
          ),
        ),
      ),
    );
  }

  String _getCompareDateText(BuildContext context) {
    switch (compareDateType) {
      case CompareDateType.lastDay:
        return S.of(context).lastDay;
      case CompareDateType.lastWeekDay:
        return S.of(context).lastWeekDay;
      case CompareDateType.lastMonthDay:
        return S.of(context).lastMonthDay;
      case CompareDateType.lastYearDay:
        return S.of(context).lastYearDay;
      case CompareDateType.chooseDay:
        return S.of(context).chooseDay;
      case CompareDateType.lastWeek:
        return S.of(context).lastWeek;
      case CompareDateType.chooseWeek:
        return S.of(context).chooseWeek;
      case CompareDateType.lastMonth:
        return S.of(context).lastMonth;
      case CompareDateType.lastYearMonth:
        return S.of(context).lastYearMonth;
      case CompareDateType.chooseMonth:
        return S.of(context).chooseMonth;
      case CompareDateType.lastYear:
        return S.of(context).lastYear;
      case CompareDateType.chooseYear:
        return S.of(context).chooseYear;
      case CompareDateType.period:
        return S.of(context).period;
    }
  }

  String _getOldDateText() {
    if (dateType == DateType.day) {
      return DateFormat('dd.MM.yy').format(oldDate1);
    } else if (dateType == DateType.month) {
      return DateFormat('MMM-yyyy').format(oldDate1);
    } else {
      return '${DateFormat('dd.MM.yy').format(oldDate1)} - ${DateFormat('dd.MM.yy').format(oldDate2)}';
    }
  }

  Future<void> _showCompareOptions(BuildContext context) async {
    Map<CompareDateType, String> options = _getOptionsForDateType(context);

    final selectedType = await showModalBottomSheet<CompareDateType>(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => _CompareOptionsSheet(
        options: options,
        selectedType: compareDateType,
      ),
    );

    if (selectedType == null) return;

    DateTime newOldDate1 = oldDate1;
    DateTime newOldDate2 = oldDate2;

    if (dateType == DateType.day) {
      final dates = await _calculateDayCompareDates(context, selectedType);
      if (dates == null) return;
      newOldDate1 = dates.$1;
      newOldDate2 = dates.$2;
    } else if (dateType == DateType.week) {
      final dates = await _calculateWeekCompareDates(context, selectedType);
      if (dates == null) return;
      newOldDate1 = dates.$1;
      newOldDate2 = dates.$2;
    } else if (dateType == DateType.month) {
      final dates = await _calculateMonthCompareDates(context, selectedType);
      if (dates == null) return;
      newOldDate1 = dates.$1;
      newOldDate2 = dates.$2;
    }

    await onCompareOptionSelected(selectedType, newOldDate1, newOldDate2);
  }

  Map<CompareDateType, String> _getOptionsForDateType(BuildContext context) {
    if (dateType == DateType.day) {
      return {
        CompareDateType.lastDay: S.of(context).lastDay,
        CompareDateType.lastWeekDay: S.of(context).lastWeekDay,
        CompareDateType.lastMonthDay: S.of(context).lastMonthDay,
        CompareDateType.lastYearDay: S.of(context).lastYearDay,
        CompareDateType.chooseDay: S.of(context).chooseDay,
      };
    } else if (dateType == DateType.week) {
      return {
        CompareDateType.lastWeek: S.of(context).lastWeek,
        CompareDateType.chooseWeek: S.of(context).chooseWeek,
      };
    } else if (dateType == DateType.month) {
      return {
        CompareDateType.lastMonth: S.of(context).lastMonth,
        CompareDateType.lastYearMonth: S.of(context).lastYearMonth,
        CompareDateType.chooseMonth: S.of(context).chooseMonth,
      };
    }
    return {};
  }

  Future<(DateTime, DateTime)?> _calculateDayCompareDates(
      BuildContext context, CompareDateType type) async {
    final now = DateTime.now();
    DateTime start = DateTime(now.year, now.month, now.day, 0, 0);
    DateTime end = DateTime(now.year, now.month, now.day, 23, 59);

    switch (type) {
      case CompareDateType.lastDay:
        start = start.subtract(const Duration(days: 1));
        end = end.subtract(const Duration(days: 1));
        break;
      case CompareDateType.lastWeekDay:
        start = Jiffy.parseFromDateTime(start).subtract(weeks: 1).dateTime;
        end = Jiffy.parseFromDateTime(end).subtract(weeks: 1).dateTime;
        break;
      case CompareDateType.lastMonthDay:
        start = Jiffy.parseFromDateTime(start).subtract(months: 1).dateTime;
        end = Jiffy.parseFromDateTime(end).subtract(months: 1).dateTime;
        break;
      case CompareDateType.lastYearDay:
        start = Jiffy.parseFromDateTime(start).subtract(years: 1).dateTime;
        end = Jiffy.parseFromDateTime(end).subtract(years: 1).dateTime;
        break;
      case CompareDateType.chooseDay:
        final chosenDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(DateTime.now().year - 5),
          lastDate: DateTime(DateTime.now().year + 5),
        );
        if (chosenDate == null) return null;
        start =
            DateTime(chosenDate.year, chosenDate.month, chosenDate.day, 0, 0);
        end =
            DateTime(chosenDate.year, chosenDate.month, chosenDate.day, 23, 59);
        break;
      default:
        break;
    }

    return (start, end);
  }

  Future<(DateTime, DateTime)?> _calculateWeekCompareDates(
      BuildContext context, CompareDateType type) async {
    final now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
    DateTime start =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day, 0, 0);
    DateTime end =
        DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59);

    switch (type) {
      case CompareDateType.lastWeek:
        start = start.subtract(const Duration(days: 7));
        end = end.subtract(const Duration(days: 7));
        break;
      case CompareDateType.chooseWeek:
        final chosenDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(DateTime.now().year - 5),
          lastDate: DateTime(DateTime.now().year + 5),
        );
        if (chosenDate == null) return null;
        DateTime startOfWeek1 =
            chosenDate.subtract(Duration(days: chosenDate.weekday - 1));
        DateTime endOfWeek1 = startOfWeek1.add(const Duration(days: 6));
        start = DateTime(
            startOfWeek1.year, startOfWeek1.month, startOfWeek1.day, 0, 0);
        end =
            DateTime(endOfWeek1.year, endOfWeek1.month, endOfWeek1.day, 23, 59);
        break;
      default:
        break;
    }

    return (start, end);
  }

  Future<(DateTime, DateTime)?> _calculateMonthCompareDates(
      BuildContext context, CompareDateType type) async {
    final now = DateTime.now();
    DateTime start = DateTime(now.year, now.month, 1, 0, 0);
    DateTime end = DateTime(now.year, now.month + 1, 0, 23, 59);

    switch (type) {
      case CompareDateType.lastMonth:
        start = Jiffy.parseFromDateTime(start).subtract(months: 1).dateTime;
        end = DateTime(start.year, start.month + 1, 0, 23, 59);
        break;
      case CompareDateType.lastYearMonth:
        start = Jiffy.parseFromDateTime(start).subtract(years: 1).dateTime;
        end = DateTime(start.year, start.month + 1, 0, 23, 59);
        break;
      case CompareDateType.chooseMonth:
        final chosenDate = await showMonthYearPicker(
          context: context,
          initialDate: DateTime(DateTime.now().year, DateTime.now().month),
          firstDate: DateTime(DateTime.now().year - 5),
          lastDate: DateTime(DateTime.now().year, DateTime.now().month),
        );
        if (chosenDate == null) return null;
        start = DateTime(chosenDate.year, chosenDate.month, 1, 0, 0);
        end = DateTime(chosenDate.year, chosenDate.month + 1, 0, 23, 59);
        break;
      default:
        break;
    }

    return (start, end);
  }
}

// Compare Options Sheet
class _CompareOptionsSheet extends StatelessWidget {
  final Map<CompareDateType, String> options;
  final CompareDateType selectedType;

  const _CompareOptionsSheet({
    required this.options,
    required this.selectedType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        color: Colors.grey.shade900,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Spacer(),
                Text(
                  S.of(context).selectPeriod,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 18),
                ),
                Expanded(
                  child: IconButton(
                    alignment: Alignment.centerRight,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_outlined,
                        color: AppTheme.primaryBlue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ...options.entries.map((entry) => Container(
                  margin: const EdgeInsets.only(bottom: 7),
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: selectedType == entry.key
                          ? AppTheme.primaryBlue
                          : Colors.grey.shade500,
                    ),
                  ),
                  child: InkWell(
                    onTap: () => Navigator.pop(context, entry.key),
                    child: Center(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w300,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// Store Selector Dialog
class _StoreSelectorDialog extends StatefulWidget {
  final List<StoreModel> stores;
  final int? selectedStoreId;
  final Function(int?) onStoreSelected;

  const _StoreSelectorDialog({
    required this.stores,
    required this.selectedStoreId,
    required this.onStoreSelected,
  });

  @override
  State<_StoreSelectorDialog> createState() => _StoreSelectorDialogState();
}

class _StoreSelectorDialogState extends State<_StoreSelectorDialog> {
  late TextEditingController _searchController;
  List<StoreModel> _filteredStores = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredStores = widget.stores;
    _searchController.addListener(_filterStores);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStores() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      _filteredStores = query.isEmpty
          ? widget.stores
          : widget.stores
              .where((store) => store.name.toLowerCase().contains(query))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      S.of(context).branches,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.close,
                        size: 20, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (widget.stores.length > 6)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: S.of(context).search,
                      hintStyle:
                          TextStyle(color: Colors.grey.shade400, fontSize: 15),
                      prefixIcon: const Icon(Icons.search,
                          color: AppTheme.primaryBlue, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),
            if (widget.stores.length > 6) const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredStores.length,
                itemBuilder: (context, index) {
                  final store = _filteredStores[index];
                  final isSelected = store.id == widget.selectedStoreId;

                  return InkWell(
                    onTap: () {
                      widget.onStoreSelected(store.id);
                      Navigator.of(context).pop(true);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                            : Colors.transparent,
                      ),
                      child: Text(
                        store.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? AppTheme.primaryBlue
                              : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
