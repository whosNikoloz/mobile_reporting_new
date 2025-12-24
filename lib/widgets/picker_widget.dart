import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mobile_reporting/application_store.dart';
import 'package:mobile_reporting/dialogs/show_calculator_dialog.dart';
import 'package:mobile_reporting/enums/compare_date_type.dart';
import 'package:mobile_reporting/enums/date_type.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mobile_reporting/enums/screen_type.dart';
import 'package:mobile_reporting/models/store_model.dart';
import 'package:month_year_picker/month_year_picker.dart';

class PickerWidget extends StatefulWidget {
  const PickerWidget({
    Key? key,
    required this.getDate,
    required this.onlyDayPicker,
    this.showFilterButton = false,
    this.isDayHidden = false,
    this.showCompareDateFilter = false,
    this.showStoreFilter = false,
    this.showOldDate = true,
    this.showDateTypeChoose = true,
    required this.screenType,
  }) : super(key: key);
  final Future<void> Function(
      DateTime dt1,
      DateTime dt2,
      DateTime dt3,
      DateTime dt4,
      double? minAmount,
      double? maxAmount,
      String? billNum) getDate;
  final bool onlyDayPicker;
  final bool isDayHidden;
  final bool showFilterButton;
  final bool showStoreFilter;
  final bool showCompareDateFilter;
  final bool showOldDate;
  final bool showDateTypeChoose;
  final ScreenType screenType;

  @override
  PickerWidgetState createState() => PickerWidgetState();
}

class PickerWidgetState extends State<PickerWidget> {
  double minimumAmount = 0;
  double maximumAmount = 0;
  String billNum = '';
  bool isLoading = true;

  DateTime currentDate1 = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 00, 00);
  DateTime currentDate2 = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59);
  DateTime oldDate1 = DateTime(
      DateTime.now().subtract(const Duration(days: 1)).year,
      DateTime.now().subtract(const Duration(days: 1)).month,
      DateTime.now().subtract(const Duration(days: 1)).day,
      00,
      00);
  DateTime oldDate2 = DateTime(
      DateTime.now().subtract(const Duration(days: 1)).year,
      DateTime.now().subtract(const Duration(days: 1)).month,
      DateTime.now().subtract(const Duration(days: 1)).day,
      23,
      59);
  bool firstLoad = true;
  DateType dt = DateType.day;
  CompareDateType cdt = CompareDateType.lastDay;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (firstLoad) {
      if (widget.screenType == ScreenType.billsScreen ||
          widget.screenType == ScreenType.dashboardScreen &&
              application.dashboardDateType == null) {
        DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
        currentDate1 = DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day, 00, 00);
        currentDate2 = DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day, 23, 59);
        oldDate1 =
            DateTime(yesterday.year, yesterday.month, yesterday.day, 00, 00);
        oldDate2 =
            DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59);
        dt = DateType.day;
        cdt = CompareDateType.lastDay;
      } else if (widget.screenType == ScreenType.billsScreen ||
          widget.screenType == ScreenType.dashboardScreen &&
              application.dashboardDateType != null) {
        dt = application.dashboardDateType!;
        cdt = application.dashboardCompareDateType!;
        currentDate1 = application.dashboardStartCurrentPeriod!;
        currentDate2 = application.dashboardEndCurrentPeriod!;
        oldDate1 = application.dashboardStartOldPeriod!;
        oldDate2 = application.dashboardEndOldPeriod!;
      } else if (widget.screenType == ScreenType.statisticsScreen &&
          application.dateType == null) {
        currentDate1 =
            DateTime(DateTime.now().year, DateTime.now().month, 1, 00, 00);
        currentDate2 =
            DateTime(DateTime.now().year, DateTime.now().month + 1, 0, 23, 59);
        oldDate1 = DateTime(DateTime.now().year, DateTime.now().month - 1,
            DateTime.now().day, 00, 00);
        oldDate2 =
            DateTime(DateTime.now().year, DateTime.now().month, 0, 23, 59);
        dt = DateType.month;
        cdt = CompareDateType.lastMonth;
        application.startCurrentPeriod = currentDate1;
        application.endCurrentPeriod = currentDate2;
        application.startOldPeriod = oldDate1;
        application.endOldPeriod = oldDate2;
        application.dateType = dt;
        application.compareDateType = cdt;
      } else if (application.dateType != null &&
          widget.screenType == ScreenType.statisticsScreen) {
        dt = application.dateType!;
        cdt = application.compareDateType!;
        currentDate1 = application.startCurrentPeriod!;
        currentDate2 = application.endCurrentPeriod!;
        oldDate1 = application.startOldPeriod!;
        oldDate2 = application.endOldPeriod!;
      }
      widget
          .getDate(
              currentDate1, currentDate2, oldDate1, oldDate2, null, null, null)
          .then((value) {
        isLoading = false;
        setState(() {});
      });

      firstLoad = false;
    }
    return Column(
      children: [
        Row(
          children: [
            if ((cdt == CompareDateType.period &&
                    widget.showCompareDateFilter) ==
                false)
              IconButton(
                onPressed: () async {
                  await arrowBackwardPress();
                },
                icon: Icon(
                  Icons.arrow_back_ios_new_outlined,
                  size: 25,
                  color: Colors.grey.shade500,
                ),
              ),
            if (widget.showCompareDateFilter)
              const SizedBox(
                width: 35,
              ),
            const Spacer(),
            if (!widget.onlyDayPicker)
              SizedBox(
                height: 44,
                child: InkWell(
                  splashFactory: NoSplash.splashFactory,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    if (widget.showDateTypeChoose) {
                      await chooseDateType(dateType: dt, compareDateType: cdt);
                    } else {
                      DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: currentDate1,
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 1000)),
                        lastDate: DateTime(DateTime.now().year,
                            DateTime.now().month, DateTime.now().day, 23, 59),
                      );
                      if (date == null) return;
                      currentDate1 =
                          DateTime(date.year, date.month, date.day, 00, 00);
                      currentDate2 =
                          DateTime(date.year, date.month, date.day, 23, 59);
                      oldDate1 = currentDate1.subtract(const Duration(days: 1));
                      oldDate2 = currentDate2.subtract(const Duration(days: 1));
                      isLoading = true;
                      setState(() {});
                      await widget.getDate(currentDate1, currentDate2, oldDate1,
                          oldDate2, null, null, null);
                      isLoading = false;
                      setState(() {});
                    }
                  },
                  child: Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dt == DateType.day
                                ? DateFormat('dd-MMM').format(currentDate1)
                                : dt == DateType.month
                                    ? DateFormat('MMM-yyyy')
                                        .format(currentDate1)
                                    : dt == DateType.week
                                        ? '${DateFormat('dd-MMM-yy').format(currentDate1)} - ${DateFormat('dd-MMM-yy').format(currentDate2)}'
                                        : dt == DateType.period
                                            ? '${DateFormat('dd-MMM-yy').format(currentDate1)} - ${DateFormat('dd-MMM-yy').format(currentDate2)}'
                                            : '',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(
                            height: 1,
                          ),
                          if (!widget.showFilterButton && widget.showOldDate)
                            Text(
                              dt == DateType.day
                                  ? DateFormat('dd-MMM').format(oldDate1)
                                  : dt == DateType.month
                                      ? DateFormat('MMM-yyyy').format(oldDate1)
                                      : dt == DateType.week
                                          ? '${DateFormat('dd-MMM-yy').format(oldDate1)} - ${DateFormat('dd-MMM-yy').format(oldDate2)}'
                                          : dt == DateType.period
                                              ? '${DateFormat('dd-MMM-yy').format(oldDate1)} - ${DateFormat('dd-MMM-yy').format(oldDate2)}'
                                              : '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 0, 68, 124),
                              ),
                            ),
                        ],
                      ),
                      if (!widget.onlyDayPicker)
                        const Icon(
                          Icons.arrow_drop_down_outlined,
                          size: 25,
                          color: Colors.grey,
                        )
                    ],
                  ),
                ),
              ),
            if (widget.showCompareDateFilter)
              Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  onTap: () async {
                    await chooseFilterOption();
                  },
                  child: Icon(
                    Icons.date_range_outlined,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            const Spacer(),
            if (isLoading)
              const SpinKitRing(
                color: Color.fromARGB(255, 0, 68, 124),
                size: 25.0,
                lineWidth: 3,
              ),
            if ((cdt == CompareDateType.period &&
                    widget.showCompareDateFilter) ==
                false)
              IconButton(
                onPressed: () async {
                  await arrowForwardPress();
                },
                icon: Icon(
                  Icons.arrow_forward_ios_outlined,
                  size: 25,
                  color: Colors.grey.shade500,
                ),
              ),
            if (widget.showFilterButton)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 0, 68, 124),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onTap: () async {
                    await showFilterDialog();
                  },
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Icon(
                      MdiIcons.filterOutline,
                      color: Color.fromARGB(255, 0, 68, 124),
                    ),
                  ),
                ),
              ),
            if (widget.showFilterButton)
              const SizedBox(
                width: 10,
              ),
          ],
        ),
        if (widget.showStoreFilter)
          Divider(
            height: 0,
            color: Colors.grey.shade500,
            indent: 7,
            endIndent: 7,
          ),
        if (widget.showStoreFilter)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onTap: () async {
                  bool storeChanged = await selectStore();
                  if (storeChanged) {
                    isLoading = true;
                    setState(() {});
                    await widget.getDate(currentDate1, currentDate2, oldDate1,
                        oldDate2, null, null, null);
                    if (dt != DateType.day) {
                      application.startCurrentPeriod = currentDate1;
                      application.endCurrentPeriod = currentDate2;
                      application.startOldPeriod = oldDate1;
                      application.endOldPeriod = oldDate2;
                      application.dateType = dt;
                      application.compareDateType = cdt;
                    }
                    isLoading = false;
                    setState(() {});
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(
                      width: 2,
                    ),
                    Text(
                      application.selectedStoreId != null
                          ? application.stores
                              .firstWhere((element) =>
                                  element.id == application.selectedStoreId)
                              .name
                          : 'ყველა ფილიალი',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> chooseDateType(
      {required DateType dateType,
      required CompareDateType compareDateType}) async {
    DateType initialDateType = dateType;
    Map<CompareDateType, String> dayOptions = {
      CompareDateType.lastDay: 'წინა დღესთან',
      CompareDateType.lastWeekDay: 'წინა კვირის დღესთან',
      CompareDateType.lastMonthDay: 'წინა თვის დღესთან',
      CompareDateType.lastYearDay: 'წინა წლის დღესთან',
      CompareDateType.chooseDay: 'დღის არჩევა',
    };

    Map<CompareDateType, String> weekOptions = {
      CompareDateType.lastWeek: 'წინა კვირასთან',
      CompareDateType.chooseWeek: 'კვირის არჩევა',
    };

    Map<CompareDateType, String> monthOptions = {
      CompareDateType.lastMonth: 'წინა თვესთან',
      CompareDateType.lastYearMonth: 'წინა წლის თვესთან',
      CompareDateType.chooseMonth: 'თვის არჩევა',
    };

    Map<CompareDateType, String> yearOptions = {
      CompareDateType.lastYear: 'წინა წელთან',
      CompareDateType.chooseYear: 'წლის არჩევა',
    };

    Map<CompareDateType, String> periodOptions = {
      CompareDateType.period: 'პერიოდი',
    };
    Map<CompareDateType, String> allOptions = {};

    allOptions.addAll(dayOptions);
    allOptions.addAll(weekOptions);
    allOptions.addAll(monthOptions);
    allOptions.addAll(yearOptions);
    allOptions.addAll(periodOptions);

    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            color: Colors.grey.shade900,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          child: Wrap(
            direction: Axis.vertical,
            runAlignment: WrapAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width - 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Spacer(),
                    Text(
                      'პერიოდი',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 18,
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        alignment: Alignment.centerRight,
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close_outlined,
                          color: Color.fromARGB(255, 0, 68, 124),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              if (!widget.isDayHidden)
                Container(
                  height: 55,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                  width: MediaQuery.of(context).size.width - 20,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: initialDateType == DateType.day
                          ? const Color.fromARGB(255, 0, 68, 124)
                          : Colors.grey.shade500,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    onTap: () async {
                      currentDate1 = DateTime(DateTime.now().year,
                          DateTime.now().month, DateTime.now().day, 00, 00);
                      currentDate2 = DateTime(DateTime.now().year,
                          DateTime.now().month, DateTime.now().day, 23, 59);
                      oldDate1 = DateTime(
                          DateTime.now().subtract(const Duration(days: 1)).year,
                          DateTime.now()
                              .subtract(const Duration(days: 1))
                              .month,
                          DateTime.now().subtract(const Duration(days: 1)).day,
                          00,
                          00);
                      oldDate2 = DateTime(
                          DateTime.now().subtract(const Duration(days: 1)).year,
                          DateTime.now()
                              .subtract(const Duration(days: 1))
                              .month,
                          DateTime.now().subtract(const Duration(days: 1)).day,
                          23,
                          59);
                      dt = DateType.day;
                      cdt = CompareDateType.lastDay;
                      if (!mounted) return;
                      Navigator.pop(context);
                      isLoading = true;
                      setState(() {});
                      await widget.getDate(currentDate1, currentDate2, oldDate1,
                          oldDate2, null, null, null);
                      if (dt != DateType.day) {
                        application.startCurrentPeriod = currentDate1;
                        application.endCurrentPeriod = currentDate2;
                        application.startOldPeriod = oldDate1;
                        application.endOldPeriod = oldDate2;
                        application.dateType = dt;
                        application.compareDateType = cdt;
                      }
                      isLoading = false;
                      setState(() {});
                    },
                    child: Text(
                      'დღე',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
              if (!widget.isDayHidden)
                const SizedBox(
                  height: 10,
                ),
              Container(
                height: 55,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
                width: MediaQuery.of(context).size.width - 20,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: initialDateType == DateType.week
                        ? const Color.fromARGB(255, 0, 68, 124)
                        : Colors.grey.shade500,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  onTap: () async {
                    currentDate1 = DateTime.now();
                    DateTime firstDayOfWeek = currentDate1
                        .subtract(Duration(days: currentDate1.weekday - 1));
                    DateTime lastDayOfWeek = currentDate1.add(Duration(
                        days: DateTime.daysPerWeek - currentDate1.weekday));
                    currentDate1 = DateTime(firstDayOfWeek.year,
                        firstDayOfWeek.month, firstDayOfWeek.day, 00, 00);
                    currentDate2 = DateTime(lastDayOfWeek.year,
                        lastDayOfWeek.month, lastDayOfWeek.day, 23, 59);
                    oldDate1 = currentDate1.subtract(const Duration(days: 7));
                    oldDate2 = currentDate2.subtract(const Duration(days: 7));
                    dt = DateType.week;
                    cdt = CompareDateType.lastWeek;
                    if (!mounted) return;
                    Navigator.pop(context);
                    isLoading = true;
                    setState(() {});
                    await widget.getDate(currentDate1, currentDate2, oldDate1,
                        oldDate2, null, null, null);
                    if (dt != DateType.day) {
                      application.startCurrentPeriod = currentDate1;
                      application.endCurrentPeriod = currentDate2;
                      application.startOldPeriod = oldDate1;
                      application.endOldPeriod = oldDate2;
                      application.dateType = dt;
                      application.compareDateType = cdt;
                    }
                    isLoading = false;
                    setState(() {});
                  },
                  child: Text(
                    'კვირა',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 55,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
                width: MediaQuery.of(context).size.width - 20,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: initialDateType == DateType.month
                        ? const Color.fromARGB(255, 0, 68, 124)
                        : Colors.grey.shade500,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  onTap: () async {
                    currentDate1 = DateTime.now();
                    currentDate1 = DateTime(
                        currentDate1.year, currentDate1.month, 1, 00, 00);
                    currentDate2 = DateTime(
                        currentDate1.year, currentDate1.month + 1, 0, 23, 59);
                    oldDate1 = Jiffy.parseFromDateTime(currentDate1)
                        .subtract(months: 1)
                        .dateTime;
                    oldDate2 = Jiffy.parseFromDateTime(currentDate2)
                        .subtract(months: 1)
                        .dateTime;
                    dt = DateType.month;
                    cdt = CompareDateType.lastMonth;
                    if (!mounted) return;
                    Navigator.pop(context);
                    isLoading = true;
                    setState(() {});
                    await widget.getDate(currentDate1, currentDate2, oldDate1,
                        oldDate2, null, null, null);
                    if (dt != DateType.day) {
                      application.startCurrentPeriod = currentDate1;
                      application.endCurrentPeriod = currentDate2;
                      application.startOldPeriod = oldDate1;
                      application.endOldPeriod = oldDate2;
                      application.dateType = dt;
                      application.compareDateType = cdt;
                    }
                    isLoading = false;
                    setState(() {});
                  },
                  child: Text(
                    'თვე',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 55,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
                width: MediaQuery.of(context).size.width - 20,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: initialDateType == DateType.period
                        ? const Color.fromARGB(255, 0, 68, 124)
                        : Colors.grey.shade500,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  onTap: () async {
                    DateTimeRange? picked;
                    picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(DateTime.now().year - 5),
                      lastDate: DateTime(DateTime.now().year,
                          DateTime.now().month, DateTime.now().day + 1),
                      initialDateRange: DateTimeRange(
                        end: DateTime(DateTime.now().year, DateTime.now().month,
                            DateTime.now().day),
                        start: DateTime(DateTime.now().year,
                            DateTime.now().month, DateTime.now().day - 1),
                      ),
                      builder: (context, child) {
                        return Column(
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 400.0,
                              ),
                              child: child,
                            )
                          ],
                        );
                      },
                    );
                    if (picked == null) return;

                    currentDate1 = DateTime(picked.start.year,
                        picked.start.month, picked.start.day, 00, 00);
                    currentDate2 = DateTime(picked.end.year, picked.end.month,
                        picked.end.day, 23, 59);

                    oldDate2 = currentDate2;
                    oldDate1 = currentDate1;
                    dt = DateType.period;
                    cdt = CompareDateType.period;
                    if (!mounted) return;
                    Navigator.pop(context);
                    isLoading = true;
                    setState(() {});
                    await widget.getDate(currentDate1, currentDate2, oldDate1,
                        oldDate2, null, null, null);
                    if (dt != DateType.day) {
                      application.startCurrentPeriod = currentDate1;
                      application.endCurrentPeriod = currentDate2;
                      application.startOldPeriod = oldDate1;
                      application.endOldPeriod = oldDate2;
                      application.dateType = dt;
                      application.compareDateType = cdt;
                    }
                    isLoading = false;
                    setState(() {});
                  },
                  child: Text(
                    'პერიოდი',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showFilterDialog() async {
    double tempMinAmount = minimumAmount;
    double tempMaxAmount = maximumAmount;
    String tempBillNum = billNum;
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            color: Colors.grey.shade900,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          child: IntrinsicHeight(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'მინიმალური თანხა',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 17,
                      ),
                    ),
                    Container(
                      height: 35,
                      width: 154,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(255, 0, 68, 124),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onTap: () async {
                          double? temp = await showCalculatorDialog(
                            header: 'მინიმალური თანხა',
                            initialAmount: tempMinAmount.toStringAsFixed(2),
                            context: context,
                            hasDotButton: true,
                          );
                          if (temp == null) return;
                          tempMinAmount = temp;
                          setModalState(() {});
                        },
                        child: Center(
                          child: Text(
                            tempMinAmount.toStringAsFixed(2),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'მაქსიმალური თანხა',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 17,
                      ),
                    ),
                    Container(
                      height: 35,
                      width: 154,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(255, 0, 68, 124),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onTap: () async {
                          double? temp = await showCalculatorDialog(
                            header: 'მაქსიმალური თანხა',
                            initialAmount: tempMaxAmount.toStringAsFixed(2),
                            context: context,
                            hasDotButton: true,
                          );
                          if (temp == null) return;
                          tempMaxAmount = temp;
                          setModalState(() {});
                        },
                        child: Center(
                          child: Text(
                            tempMaxAmount.toStringAsFixed(2),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ჩეკის ნომერი',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 17,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      height: 35,
                      width: 120,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(255, 0, 68, 124),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onTap: () async {
                          double? temp = await showCalculatorDialog(
                            header: 'ჩეკის ნომერი',
                            initialAmount: billNum,
                            context: context,
                            hasDotButton: false,
                          );
                          if (temp == null) return;
                          tempBillNum = temp.toStringAsFixed(0);
                          setModalState(() {});
                        },
                        child: Center(
                          child: Text(
                            tempBillNum,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      padding: const EdgeInsets.only(left: 10),
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        tempBillNum = '';
                        setState(() {});
                      },
                      icon: Icon(
                        Icons.close_outlined,
                        color: Colors.red.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 48,
                      width: (MediaQuery.of(context).size.width - 30) / 2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            color: const Color.fromARGB(255, 0, 68, 124)),
                      ),
                      child: TextButton(
                        child: Text(
                          'წაშლა',
                          style: TextStyle(
                            fontSize: 22.0,
                            color: Colors.red.shade900,
                          ),
                        ),
                        onPressed: () async {
                          if (!mounted) return;
                          Navigator.pop(context);
                          billNum = '';
                          minimumAmount = 0;
                          maximumAmount = 0;
                          isLoading = true;
                          setState(() {});
                          await widget.getDate(currentDate1, currentDate2,
                              oldDate1, oldDate2, null, null, null);
                          if (dt != DateType.day) {
                            application.startCurrentPeriod = currentDate1;
                            application.endCurrentPeriod = currentDate2;
                            application.startOldPeriod = oldDate1;
                            application.endOldPeriod = oldDate2;
                            application.dateType = dt;
                            application.compareDateType = cdt;
                          }
                          isLoading = false;
                          setState(() {});
                        },
                      ),
                    ),
                    Container(
                      height: 48,
                      width: (MediaQuery.of(context).size.width - 30) / 2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            color: const Color.fromARGB(255, 0, 68, 124)),
                      ),
                      child: TextButton(
                        child: Text(
                          'შენახვა',
                          style: TextStyle(
                            fontSize: 22.0,
                            color: Colors.green.shade800,
                          ),
                        ),
                        onPressed: () async {
                          if (!mounted) return;
                          Navigator.pop(context);
                          billNum = tempBillNum;
                          minimumAmount = tempMinAmount;
                          maximumAmount = tempMaxAmount;
                          isLoading = true;
                          setState(() {});
                          await widget.getDate(
                              currentDate1,
                              currentDate2,
                              oldDate1,
                              oldDate2,
                              tempMinAmount == 0 ? null : tempMinAmount,
                              tempMaxAmount == 0 ? null : tempMaxAmount,
                              billNum.isEmpty ? null : billNum);
                          if (dt != DateType.day) {
                            application.startCurrentPeriod = currentDate1;
                            application.endCurrentPeriod = currentDate2;
                            application.startOldPeriod = oldDate1;
                            application.endOldPeriod = oldDate2;
                            application.dateType = dt;
                            application.compareDateType = cdt;
                          }
                          isLoading = false;
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<CompareDateType?> chooseCompareDateType(
      {required Map<CompareDateType, String> options,
      required CompareDateType? initial}) async {
    return await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            color: Colors.grey.shade900,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          child: Wrap(
            direction: Axis.vertical,
            runAlignment: WrapAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width - 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Spacer(),
                    Text(
                      'აირჩიეთ პერიოდი',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 18,
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        alignment: Alignment.centerRight,
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close_outlined,
                          color: Color.fromARGB(255, 0, 68, 124),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width - 20,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 7),
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: initial == options.keys.elementAt(index)
                              ? const Color.fromARGB(255, 0, 68, 124)
                              : Colors.grey.shade500,
                        ),
                      ),
                      child: InkWell(
                        child: Center(
                          child: Text(
                            options.values.elementAt(index),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w300,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        onTap: () => Navigator.pop(
                            context, options.keys.elementAt(index)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> chooseFilterOption() async {
    CompareDateType initialCompareDateType = cdt;
    Map<CompareDateType, String> dayOptions = {
      CompareDateType.lastDay: 'წინა დღესთან',
      CompareDateType.lastWeekDay: 'წინა კვირის დღესთან',
      CompareDateType.lastMonthDay: 'წინა თვის დღესთან',
      CompareDateType.lastYearDay: 'წინა წლის დღესთან',
      CompareDateType.chooseDay: 'დღის არჩევა',
    };

    Map<CompareDateType, String> weekOptions = {
      CompareDateType.lastWeek: 'წინა კვირასთან',
      CompareDateType.chooseWeek: 'კვირის არჩევა',
    };

    Map<CompareDateType, String> monthOptions = {
      CompareDateType.lastMonth: 'წინა თვესთან',
      CompareDateType.lastYearMonth: 'წინა წლის თვესთან',
      CompareDateType.chooseMonth: 'თვის არჩევა',
    };

    Map<CompareDateType, String> yearOptions = {
      CompareDateType.lastYear: 'წინა წელთან',
      CompareDateType.chooseYear: 'წლის არჩევა',
    };

    Map<CompareDateType, String> periodOptions = {
      CompareDateType.period: 'პერიოდი',
    };
    Map<CompareDateType, String> allOptions = {};

    allOptions.addAll(dayOptions);
    allOptions.addAll(weekOptions);
    allOptions.addAll(monthOptions);
    allOptions.addAll(yearOptions);
    allOptions.addAll(periodOptions);
    if (dt == DateType.day) {
      CompareDateType? x = await chooseCompareDateType(
          options: dayOptions, initial: initialCompareDateType);
      if (x == null) return;
      DateTime now = DateTime.now();
      currentDate1 = DateTime(now.year, now.month, now.day, 00, 00);
      currentDate2 = DateTime(now.year, now.month, now.day, 23, 59);
      if (x == CompareDateType.lastDay) {
        oldDate1 = currentDate1.subtract(const Duration(days: 1));
        oldDate2 = currentDate2.subtract(const Duration(days: 1));
      } else if (x == CompareDateType.lastWeekDay) {
        oldDate1 =
            Jiffy.parseFromDateTime(currentDate1).subtract(weeks: 1).dateTime;
        oldDate2 =
            Jiffy.parseFromDateTime(currentDate2).subtract(weeks: 1).dateTime;
      } else if (x == CompareDateType.lastMonthDay) {
        oldDate1 =
            Jiffy.parseFromDateTime(currentDate1).subtract(months: 1).dateTime;
        oldDate2 =
            Jiffy.parseFromDateTime(currentDate2).subtract(months: 1).dateTime;
      } else if (x == CompareDateType.lastYearDay) {
        oldDate1 =
            Jiffy.parseFromDateTime(currentDate1).subtract(years: 1).dateTime;
        oldDate2 =
            Jiffy.parseFromDateTime(currentDate2).subtract(years: 1).dateTime;
      } else if (x == CompareDateType.lastYearDay) {
        oldDate1 =
            Jiffy.parseFromDateTime(currentDate1).subtract(years: 1).dateTime;
        oldDate2 =
            Jiffy.parseFromDateTime(currentDate2).subtract(years: 1).dateTime;
      } else if (x == CompareDateType.chooseDay && mounted) {
        DateTime? chosenDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(DateTime.now().year - 5),
          lastDate: DateTime(DateTime.now().year + 5),
        );
        if (chosenDate == null) {
          return;
        }
        oldDate1 =
            DateTime(chosenDate.year, chosenDate.month, chosenDate.day, 00, 00);
        oldDate2 =
            DateTime(chosenDate.year, chosenDate.month, chosenDate.day, 23, 59);
      }
      cdt = x;
    } else if (dt == DateType.week) {
      CompareDateType? x = await chooseCompareDateType(
          options: weekOptions, initial: initialCompareDateType);
      if (x == null) return;
      DateTime now = DateTime.now();
      DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
      currentDate1 = DateTime(
          startOfWeek.year, startOfWeek.month, startOfWeek.day, 00, 00);
      currentDate2 =
          DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59);
      if (x == CompareDateType.lastWeek) {
        oldDate1 = currentDate1.subtract(const Duration(days: 7));
        oldDate2 = currentDate2.subtract(const Duration(days: 7));
      } else if (x == CompareDateType.chooseWeek && mounted) {
        DateTime? chosenDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(DateTime.now().year - 5),
          lastDate: DateTime(DateTime.now().year + 5),
        );
        if (chosenDate == null) {
          return;
        }
        DateTime startOfWeek1 =
            chosenDate.subtract(Duration(days: chosenDate.weekday - 1));
        DateTime endOfWeek1 = startOfWeek1.add(const Duration(days: 6));
        oldDate1 = DateTime(
            startOfWeek1.year, startOfWeek1.month, startOfWeek1.day, 00, 00);
        oldDate2 =
            DateTime(endOfWeek1.year, endOfWeek1.month, endOfWeek1.day, 23, 59);
      }
      cdt = x;
    } else if (dt == DateType.month) {
      CompareDateType? x = await chooseCompareDateType(
          options: monthOptions, initial: initialCompareDateType);
      if (x == null) return;
      DateTime now = DateTime.now();
      currentDate1 = DateTime(now.year, now.month, 1, 00, 00);
      currentDate2 = DateTime(now.year, now.month + 1, 0, 23, 59);
      if (x == CompareDateType.lastMonth) {
        oldDate1 =
            Jiffy.parseFromDateTime(currentDate1).subtract(months: 1).dateTime;
        oldDate2 = DateTime(oldDate1.year, oldDate1.month + 1, 0, 23, 59);
      } else if (x == CompareDateType.lastYearMonth) {
        oldDate1 =
            Jiffy.parseFromDateTime(currentDate1).subtract(years: 1).dateTime;
        oldDate2 = DateTime(oldDate1.year, oldDate1.month + 1, 0, 23, 59);
      } else if (x == CompareDateType.chooseMonth && mounted) {
        DateTime? chosenDate = await showMonthYearPicker(
          context: context,
          initialDate: DateTime(DateTime.now().year, DateTime.now().month),
          firstDate: DateTime(DateTime.now().year - 5),
          lastDate: DateTime(DateTime.now().year, DateTime.now().month),
        );
        if (chosenDate == null) {
          return;
        }
        oldDate1 = DateTime(chosenDate.year, chosenDate.month, 1, 00, 00);
        oldDate2 = DateTime(chosenDate.year, chosenDate.month + 1, 0, 23, 59);
      }
      cdt = x;
    }
    if (cdt == CompareDateType.period && mounted) {
      DateTimeRange? picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(DateTime.now().year - 5),
        lastDate: DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day + 1),
        initialDateRange: DateTimeRange(
          end: DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day),
          start: DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day - 1),
        ),
      );
      if (picked == null) return;

      oldDate1 = DateTime(
          picked.start.year, picked.start.month, picked.start.day, 00, 00);
      oldDate2 =
          DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59);
    }

    isLoading = true;
    setState(() {});
    await widget.getDate(
        currentDate1, currentDate2, oldDate1, oldDate2, null, null, null);
    if (dt != DateType.day) {
      application.startCurrentPeriod = currentDate1;
      application.endCurrentPeriod = currentDate2;
      application.startOldPeriod = oldDate1;
      application.endOldPeriod = oldDate2;
      application.dateType = dt;
      application.compareDateType = cdt;
    }
    isLoading = false;
    setState(() {});
  }

  Future<void> arrowForwardPress() async {
    switch (cdt) {
      case CompareDateType.lastDay:
        currentDate1 = currentDate1.add(const Duration(days: 1));
        currentDate2 = currentDate2.add(const Duration(days: 1));
        oldDate1 = oldDate1.add(const Duration(days: 1));
        oldDate2 = oldDate2.add(const Duration(days: 1));
        break;
      case CompareDateType.lastWeekDay:
        currentDate1 =
            Jiffy.parseFromDateTime(currentDate1).add(days: 1).dateTime;
        currentDate2 =
            Jiffy.parseFromDateTime(currentDate2).add(days: 1).dateTime;
        oldDate1 = Jiffy.parseFromDateTime(currentDate1).add(weeks: 1).dateTime;
        oldDate2 = Jiffy.parseFromDateTime(currentDate2).add(weeks: 1).dateTime;
        break;
      case CompareDateType.lastMonthDay:
        currentDate1 =
            Jiffy.parseFromDateTime(currentDate1).add(days: 1).dateTime;
        currentDate2 =
            Jiffy.parseFromDateTime(currentDate2).add(days: 1).dateTime;
        oldDate1 =
            Jiffy.parseFromDateTime(currentDate1).add(months: 1).dateTime;
        oldDate2 =
            Jiffy.parseFromDateTime(currentDate2).add(months: 1).dateTime;
        break;
      case CompareDateType.lastYearDay:
        currentDate1 =
            Jiffy.parseFromDateTime(currentDate1).add(days: 1).dateTime;
        currentDate2 =
            Jiffy.parseFromDateTime(currentDate2).add(days: 1).dateTime;
        oldDate1 = Jiffy.parseFromDateTime(currentDate1).add(years: 1).dateTime;
        oldDate2 = Jiffy.parseFromDateTime(currentDate2).add(years: 1).dateTime;
        break;
      case CompareDateType.chooseDay:
        currentDate1 =
            Jiffy.parseFromDateTime(currentDate1).add(days: 1).dateTime;
        currentDate2 =
            Jiffy.parseFromDateTime(currentDate2).add(days: 1).dateTime;
        break;
      case CompareDateType.lastWeek:
        currentDate1 = currentDate1.add(const Duration(days: 7));
        currentDate2 = currentDate2.add(const Duration(days: 7));
        oldDate1 = oldDate1.add(const Duration(days: 7));
        oldDate2 = oldDate2.add(const Duration(days: 7));
        break;
      case CompareDateType.chooseWeek:
        currentDate1 = currentDate1.add(const Duration(days: 7));
        currentDate2 = currentDate2.add(const Duration(days: 7));
        break;
      case CompareDateType.lastMonth:
        currentDate1 =
            Jiffy.parseFromDateTime(currentDate1).add(months: 1).dateTime;
        currentDate2 =
            Jiffy.parseFromDateTime(currentDate2).add(months: 1).dateTime;
        oldDate1 = Jiffy.parseFromDateTime(oldDate1).add(months: 1).dateTime;
        oldDate2 = Jiffy.parseFromDateTime(oldDate2).add(months: 1).dateTime;
        break;
      case CompareDateType.lastYearMonth:
        currentDate1 =
            Jiffy.parseFromDateTime(currentDate1).add(months: 1).dateTime;
        currentDate2 =
            Jiffy.parseFromDateTime(currentDate2).add(months: 1).dateTime;
        oldDate1 = Jiffy.parseFromDateTime(currentDate1).add(years: 1).dateTime;
        oldDate2 = Jiffy.parseFromDateTime(currentDate2).add(years: 1).dateTime;
        break;
      case CompareDateType.chooseMonth:
        currentDate1 =
            Jiffy.parseFromDateTime(currentDate1).add(months: 1).dateTime;
        currentDate2 =
            Jiffy.parseFromDateTime(currentDate2).add(months: 1).dateTime;
        break;
      case CompareDateType.lastYear:
        currentDate1 =
            Jiffy.parseFromDateTime(currentDate1).add(years: 1).dateTime;
        currentDate2 =
            Jiffy.parseFromDateTime(currentDate2).add(years: 1).dateTime;
        oldDate1 = Jiffy.parseFromDateTime(currentDate1).add(years: 1).dateTime;
        oldDate2 = Jiffy.parseFromDateTime(currentDate2).add(years: 1).dateTime;
        break;
      case CompareDateType.chooseYear:
        // TODO: Handle this case.
        break;
      case CompareDateType.period:
        // TODO: Handle this case.
        break;
    }

    isLoading = true;
    setState(() {});
    await widget.getDate(
        currentDate1, currentDate2, oldDate1, oldDate2, null, null, null);
    if (dt != DateType.day) {
      application.startCurrentPeriod = currentDate1;
      application.endCurrentPeriod = currentDate2;
      application.startOldPeriod = oldDate1;
      application.endOldPeriod = oldDate2;
      application.dateType = dt;
      application.compareDateType = cdt;
    }
    isLoading = false;
    setState(() {});
  }

  Future<void> arrowBackwardPress() async {
    switch (cdt) {
      case CompareDateType.lastDay:
        currentDate1 = currentDate1.subtract(const Duration(days: 1));
        currentDate2 = currentDate2.subtract(const Duration(days: 1));
        oldDate1 = oldDate1.subtract(const Duration(days: 1));
        oldDate2 = oldDate2.subtract(const Duration(days: 1));
        break;
      case CompareDateType.lastWeekDay:
        currentDate1 =
            Jiffy.parseFromDateTime(currentDate1).subtract(days: 1).dateTime;
        currentDate2 =
            Jiffy.parseFromDateTime(currentDate2).subtract(days: 1).dateTime;
        oldDate1 =
            Jiffy.parseFromDateTime(currentDate1).subtract(weeks: 1).dateTime;
        oldDate2 =
            Jiffy.parseFromDateTime(currentDate2).subtract(weeks: 1).dateTime;
        break;
      case CompareDateType.lastMonthDay:
        currentDate1 =
            Jiffy.parseFromDateTime(currentDate1).subtract(days: 1).dateTime;
        currentDate2 =
            Jiffy.parseFromDateTime(currentDate2).subtract(days: 1).dateTime;
        oldDate1 =
            Jiffy.parseFromDateTime(currentDate1).subtract(months: 1).dateTime;
        oldDate2 =
            Jiffy.parseFromDateTime(currentDate2).subtract(months: 1).dateTime;
        break;
      case CompareDateType.lastYearDay:
        currentDate1 =
            Jiffy.parseFromDateTime(currentDate1).subtract(days: 1).dateTime;
        currentDate2 =
            Jiffy.parseFromDateTime(currentDate2).subtract(days: 1).dateTime;
        oldDate1 =
            Jiffy.parseFromDateTime(currentDate1).subtract(years: 1).dateTime;
        oldDate2 =
            Jiffy.parseFromDateTime(currentDate2).subtract(years: 1).dateTime;
        break;
      case CompareDateType.chooseDay:
        currentDate1 =
            Jiffy.parseFromDateTime(currentDate1).subtract(days: 1).dateTime;
        currentDate2 =
            Jiffy.parseFromDateTime(currentDate2).subtract(days: 1).dateTime;
        break;
      case CompareDateType.lastWeek:
        currentDate1 = currentDate1.subtract(const Duration(days: 7));
        currentDate2 = currentDate2.subtract(const Duration(days: 7));
        oldDate1 = oldDate1.subtract(const Duration(days: 7));
        oldDate2 = oldDate2.subtract(const Duration(days: 7));
        break;
      case CompareDateType.chooseWeek:
        currentDate1 = currentDate1.subtract(const Duration(days: 7));
        currentDate2 = currentDate2.subtract(const Duration(days: 7));
        break;
      case CompareDateType.lastMonth:
        currentDate1 =
            Jiffy.parseFromDateTime(currentDate1).subtract(months: 1).dateTime;
        currentDate2 =
            Jiffy.parseFromDateTime(currentDate2).subtract(months: 1).dateTime;
        oldDate1 =
            Jiffy.parseFromDateTime(oldDate1).subtract(months: 1).dateTime;
        oldDate2 =
            Jiffy.parseFromDateTime(oldDate2).subtract(months: 1).dateTime;
        break;
      case CompareDateType.lastYearMonth:
        currentDate1 =
            Jiffy.parseFromDateTime(currentDate1).subtract(months: 1).dateTime;
        currentDate2 =
            Jiffy.parseFromDateTime(currentDate2).subtract(months: 1).dateTime;
        oldDate1 =
            Jiffy.parseFromDateTime(currentDate1).subtract(years: 1).dateTime;
        oldDate2 =
            Jiffy.parseFromDateTime(currentDate2).subtract(years: 1).dateTime;
        break;
      case CompareDateType.chooseMonth:
        currentDate1 =
            Jiffy.parseFromDateTime(currentDate1).subtract(months: 1).dateTime;
        currentDate2 =
            Jiffy.parseFromDateTime(currentDate2).subtract(months: 1).dateTime;
        break;
      case CompareDateType.lastYear:
        currentDate1 =
            Jiffy.parseFromDateTime(currentDate1).subtract(years: 1).dateTime;
        currentDate2 =
            Jiffy.parseFromDateTime(currentDate2).subtract(years: 1).dateTime;
        oldDate1 =
            Jiffy.parseFromDateTime(currentDate1).subtract(years: 1).dateTime;
        oldDate2 =
            Jiffy.parseFromDateTime(currentDate2).subtract(years: 1).dateTime;
        break;
      case CompareDateType.chooseYear:
        // TODO: Handle this case.
        break;
      case CompareDateType.period:
        // TODO: Handle this case.
        break;
    }

    isLoading = true;
    setState(() {});
    await widget.getDate(
        currentDate1, currentDate2, oldDate1, oldDate2, null, null, null);
    if (dt != DateType.day) {
      application.startCurrentPeriod = currentDate1;
      application.endCurrentPeriod = currentDate2;
      application.startOldPeriod = oldDate1;
      application.endOldPeriod = oldDate2;
      application.dateType = dt;
      application.compareDateType = cdt;
    }
    isLoading = false;
    setState(() {});
  }

  Future<bool> selectStore() async {
    bool res = false;
    List<StoreModel> stores = [];
    stores.add(StoreModel(id: null, name: 'ყველა ფილიალი'));
    for (var element in application.stores) {
      stores.add(StoreModel(id: element.id, name: element.name));
    }

    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: Colors.grey.shade900,
        ),
        padding:
            const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 15),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Spacer(),
                Text(
                  'ფილიალები',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 18,
                  ),
                ),
                Expanded(
                  child: IconButton(
                    alignment: Alignment.centerRight,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close_outlined,
                      color: Color.fromARGB(255, 0, 68, 124),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: stores.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 7),
                    height: 50,
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: application.selectedStoreId ==
                                stores.elementAt(index).id
                            ? const Color.fromARGB(255, 0, 68, 124)
                            : Colors.grey.shade500,
                      ),
                    ),
                    child: InkWell(
                      child: Center(
                        child: Text(
                          stores.elementAt(index).name,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w300,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      onTap: () {
                        application.selectedStoreId =
                            stores.elementAt(index).id;
                        Navigator.pop(context);
                        res = true;
                      },
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
    return res;
  }
}
