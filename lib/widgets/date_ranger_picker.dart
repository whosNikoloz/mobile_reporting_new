import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_reporting/localization/generated/l10n.dart';
import 'package:mobile_reporting/theme/app_theme.dart';

class DateRangePickerResult {
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? compareStartDate;
  final DateTime? compareEndDate;
  final PeriodType periodType;

  DateRangePickerResult({
    required this.startDate,
    required this.endDate,
    this.compareStartDate,
    this.compareEndDate,
    required this.periodType,
  });
}

class DateRangePicker extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final PeriodType? initialPeriodType;
  final DateTime? initialCompareStartDate;
  final DateTime? initialCompareEndDate;

  const DateRangePicker({
    Key? key,
    this.initialStartDate,
    this.initialEndDate,
    this.initialPeriodType,
    this.initialCompareStartDate,
    this.initialCompareEndDate,
  }) : super(key: key);

  @override
  State<DateRangePicker> createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State<DateRangePicker> {
  // Period tab state
  late PeriodType _selectedPeriodType;
  late DateTime _selectedDate;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  late DateTime _currentMonth;
  late int _currentYear;

  // Compare to state
  bool _isCompareMode = false;
  CompareToOption _selectedCompareOption = CompareToOption.yesterday;
  DateTime? _compareRangeStart;
  DateTime? _compareRangeEnd;
  bool _hasCustomComparison = false;

  // Track the last period to detect changes
  DateTime? _lastPeriodStart;
  DateTime? _lastPeriodEnd;

  // Track the comparison offset in days for smart recalculation
  int? _comparisonOffsetDays;

  @override
  void initState() {
    super.initState();
    _selectedPeriodType = widget.initialPeriodType ?? PeriodType.day;
    _selectedDate = widget.initialStartDate ?? DateTime.now();
    _currentMonth = widget.initialStartDate ?? DateTime.now();
    _currentYear = (widget.initialStartDate ?? DateTime.now()).year;

    if (widget.initialStartDate != null && widget.initialEndDate != null) {
      _rangeStart = widget.initialStartDate;
      _rangeEnd = widget.initialEndDate;
    }

    // Initialize comparison dates if provided
    if (widget.initialCompareStartDate != null &&
        widget.initialCompareEndDate != null) {
      _compareRangeStart = widget.initialCompareStartDate;
      _compareRangeEnd = widget.initialCompareEndDate;

      // Try to detect which comparison option was used
      _selectedCompareOption = _detectComparisonOption();

      // If we couldn't detect a standard option, it's custom
      if (_selectedCompareOption == CompareToOption.customRange) {
        _hasCustomComparison = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTabBar(),
            _buildContent(),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                S.of(context).cancel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: _applySelection,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                S.of(context).confirm,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _applySelection() {
    DateTime startDate;
    DateTime endDate;

    // Always use period tab selection as the main period (FROM)
    switch (_selectedPeriodType) {
      case PeriodType.day:
        startDate = DateTime(
            _selectedDate.year, _selectedDate.month, _selectedDate.day, 0, 0);
        endDate = DateTime(
            _selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59);
        break;
      case PeriodType.week:
        if (_rangeStart == null || _rangeEnd == null) return;
        startDate = DateTime(
            _rangeStart!.year, _rangeStart!.month, _rangeStart!.day, 0, 0);
        endDate =
            DateTime(_rangeEnd!.year, _rangeEnd!.month, _rangeEnd!.day, 23, 59);
        break;
      case PeriodType.month:
        startDate = DateTime(_selectedDate.year, _selectedDate.month, 1, 0, 0);
        endDate =
            DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 23, 59);
        break;
      case PeriodType.year:
        startDate = DateTime(_selectedDate.year, 1, 1, 0, 0);
        endDate = DateTime(_selectedDate.year, 12, 31, 23, 59);
        break;
      case PeriodType.period:
        if (_rangeStart == null || _rangeEnd == null) return;
        startDate = DateTime(
            _rangeStart!.year, _rangeStart!.month, _rangeStart!.day, 0, 0);
        endDate =
            DateTime(_rangeEnd!.year, _rangeEnd!.month, _rangeEnd!.day, 23, 59);
        break;
    }

    // Recalculate comparison dates if:
    // 1. They're not set (null)
    // 2. They're the same as current dates
    // 3. User has a custom offset to apply
    // 4. No custom comparison was made (default behavior)
    bool shouldRecalculate = _compareRangeStart == null ||
                             _compareRangeEnd == null ||
                             (_isSameDay(_compareRangeStart!, startDate) && _isSameDay(_compareRangeEnd!, endDate));

    // If user has custom offset, apply it
    if (!shouldRecalculate && _comparisonOffsetDays != null) {
      _compareRangeStart = startDate.subtract(Duration(days: _comparisonOffsetDays!));
      _compareRangeEnd = endDate.subtract(Duration(days: _comparisonOffsetDays!));
    }
    // If no custom comparison was set, always use default
    else if (!shouldRecalculate && !_hasCustomComparison) {
      shouldRecalculate = true;
    }

    if (shouldRecalculate) {
      // Calculate default comparison dates based on period type
      switch (_selectedPeriodType) {
        case PeriodType.day:
          _compareRangeStart = startDate.subtract(const Duration(days: 1));
          _compareRangeEnd = endDate.subtract(const Duration(days: 1));
          break;
        case PeriodType.week:
          _compareRangeStart = startDate.subtract(const Duration(days: 7));
          _compareRangeEnd = endDate.subtract(const Duration(days: 7));
          break;
        case PeriodType.month:
          try {
            _compareRangeStart = DateTime(startDate.year, startDate.month - 1, startDate.day, 0, 0);
            _compareRangeEnd = DateTime(endDate.year, endDate.month - 1, endDate.day, 23, 59);
          } catch (e) {
            final lastDayOfPrevMonth = DateTime(startDate.year, startDate.month, 0);
            _compareRangeStart = DateTime(
                lastDayOfPrevMonth.year,
                lastDayOfPrevMonth.month,
                startDate.day > lastDayOfPrevMonth.day ? lastDayOfPrevMonth.day : startDate.day,
                0, 0);
            _compareRangeEnd = DateTime(
                lastDayOfPrevMonth.year,
                lastDayOfPrevMonth.month,
                lastDayOfPrevMonth.day,
                23, 59);
          }
          break;
        case PeriodType.year:
          _compareRangeStart = DateTime(startDate.year - 1, 1, 1, 0, 0);
          _compareRangeEnd = DateTime(endDate.year - 1, 12, 31, 23, 59);
          break;
        case PeriodType.period:
          final duration = endDate.difference(startDate);
          _compareRangeStart = startDate.subtract(duration).subtract(const Duration(days: 1));
          _compareRangeEnd = startDate.subtract(const Duration(days: 1));
          break;
      }
    }

    print('🗓️ Date Picker Result:');
    print('  Current: $startDate to $endDate');
    print('  Compare: $_compareRangeStart to $_compareRangeEnd');
    print('  Period Type: $_selectedPeriodType');

    Navigator.of(context).pop(
      DateRangePickerResult(
        startDate: startDate,
        endDate: endDate,
        compareStartDate: _compareRangeStart,
        compareEndDate: _compareRangeEnd,
        periodType: _selectedPeriodType,
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTab(S.of(context).period, !_isCompareMode),
          const SizedBox(width: 32),
          _buildTab(S.of(context).comparisonLabel, _isCompareMode),
        ],
      ),
    );
  }

  Widget _buildTab(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isCompareMode = text == 'შედარება';
        });
      },
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppTheme.primaryBlue : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              height: 2,
              width: 60,
              color: AppTheme.primaryBlue,
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isCompareMode) {
      return _buildCompareToContent();
    } else {
      return _buildPeriodContent();
    }
  }

  Widget _buildPeriodContent() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildPeriodTypeSelector(),
          const SizedBox(height: 12),
          _buildCalendarNavigation(),
          const SizedBox(height: 12),
          _buildCalendarView(),
        ],
      ),
    );
  }

  Widget _buildPeriodTypeSelector() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildPeriodTypeButton(S.of(context).day, PeriodType.day),
            ),
            const SizedBox(width: 8),
            Expanded(
              child:
                  _buildPeriodTypeButton(S.of(context).week, PeriodType.week),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child:
                  _buildPeriodTypeButton(S.of(context).month, PeriodType.month),
            ),
            const SizedBox(width: 8),
            Expanded(
              child:
                  _buildPeriodTypeButton(S.of(context).year, PeriodType.year),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildPeriodButtonWithDisplay(),
      ],
    );
  }

  Widget _buildPeriodButtonWithDisplay() {
    final isSelected = _selectedPeriodType == PeriodType.period;
    final formatter = DateFormat('MMM d');
    final hasDateRange = _rangeStart != null && _rangeEnd != null;

    return Row(
      children: [
        Expanded(
          flex: hasDateRange ? 2 : 1,
          child: GestureDetector(
            onTap: () {
              setState(() {
                // Reset custom comparison when changing to period type
                _hasCustomComparison = false;
                _comparisonOffsetDays = null;

                _selectedPeriodType = PeriodType.period;
                _rangeStart = null;
                _rangeEnd = null;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryBlue.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    S.of(context).period,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? AppTheme.primaryBlue : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  if (isSelected && !hasDateRange)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Click calendar dates',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (hasDateRange && isSelected) ...[
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${formatter.format(_rangeStart!)} - ${formatter.format(_rangeEnd!)}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPeriodTypeButton(String text, PeriodType type) {
    final isSelected = _selectedPeriodType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          // Reset custom comparison when changing period type
          _hasCustomComparison = false;
          _comparisonOffsetDays = null;

          _selectedPeriodType = type;
          if (type == PeriodType.week) {
            _setWeekRange(_selectedDate);
          } else if (type == PeriodType.period) {
            _rangeStart = null;
            _rangeEnd = null;
          } else {
            _rangeStart = null;
            _rangeEnd = null;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBlue.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? AppTheme.primaryBlue : Colors.black87,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarNavigation() {
    String title = '';
    switch (_selectedPeriodType) {
      case PeriodType.year:
        title = _currentYear.toString();
        break;
      case PeriodType.month:
        title = _currentYear.toString();
        break;
      default:
        title = DateFormat('MMM yyyy').format(_currentMonth);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _previousPeriod,
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _nextPeriod,
        ),
      ],
    );
  }

  void _previousPeriod() {
    setState(() {
      if (_selectedPeriodType == PeriodType.year) {
        _currentYear -= 16;
      } else if (_selectedPeriodType == PeriodType.month) {
        _currentYear -= 1;
      } else {
        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
      }
    });
  }

  void _nextPeriod() {
    setState(() {
      if (_selectedPeriodType == PeriodType.year) {
        _currentYear += 16;
      } else if (_selectedPeriodType == PeriodType.month) {
        _currentYear += 1;
      } else {
        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      }
    });
  }

  Widget _buildCalendarView() {
    switch (_selectedPeriodType) {
      case PeriodType.year:
        return _buildYearSelector();
      case PeriodType.month:
        return _buildMonthSelector();
      default:
        return _buildDayCalendar();
    }
  }

  Widget _buildYearSelector() {
    final now = DateTime.now();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 1,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final year = _currentYear + index - 5;
        final isFuture = year > now.year;

        return GestureDetector(
          onTap: isFuture ? null : () {
            setState(() {
              // Reset custom comparison when selecting new period
              _hasCustomComparison = false;
              _comparisonOffsetDays = null;

              _selectedDate = DateTime(year);
            });
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: year == _selectedDate.year
                  ? AppTheme.primaryBlue.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              year.toString(),
              style: TextStyle(
                fontSize: 15,
                color: isFuture
                    ? Colors.grey.shade300
                    : year == _selectedDate.year
                        ? AppTheme.primaryBlue
                        : Colors.black87,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonthSelector() {
    final months = [
      S.of(context).janShort,
      S.of(context).febShort,
      S.of(context).marShort,
      S.of(context).aprShort,
      S.of(context).mayShort,
      S.of(context).junShort,
      S.of(context).julShort,
      S.of(context).augShort,
      S.of(context).sepShort,
      S.of(context).octShort,
      S.of(context).novShort,
      S.of(context).decShort,
    ];

    final now = DateTime.now();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 1,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final monthIndex = index + 1;
        final isFuture = _currentYear > now.year ||
            (_currentYear == now.year && monthIndex > now.month);

        return GestureDetector(
          onTap: isFuture ? null : () {
            setState(() {
              // Reset custom comparison when selecting new period
              _hasCustomComparison = false;
              _comparisonOffsetDays = null;

              _selectedDate = DateTime(_currentYear, monthIndex);
            });
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _selectedDate.year == _currentYear &&
                      _selectedDate.month == monthIndex
                  ? AppTheme.primaryBlue.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              months[index],
              style: TextStyle(
                fontSize: 15,
                color: isFuture
                    ? Colors.grey.shade300
                    : _selectedDate.year == _currentYear &&
                            _selectedDate.month == monthIndex
                        ? AppTheme.primaryBlue
                        : Colors.black87,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayCalendar() {
    return Column(
      children: [
        _buildWeekDayHeaders(),
        const SizedBox(height: 4),
        _buildDaysGrid(),
      ],
    );
  }

  Widget _buildWeekDayHeaders() {
    final days = [
      S.of(context).mon,
      S.of(context).tue,
      S.of(context).wed,
      S.of(context).thu,
      S.of(context).fri,
      S.of(context).sat,
      S.of(context).sun,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days.map((day) {
          return Expanded(
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDaysGrid() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final daysInMonth = lastDay.day;

    // Adjust for Monday as first day of week
    int firstWeekday = firstDay.weekday - 1;
    if (firstWeekday < 0) firstWeekday = 6;

    final totalCells = ((daysInMonth + firstWeekday) / 7).ceil() * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.5,
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        final dayNumber = index - firstWeekday + 1;

        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return const SizedBox.shrink();
        }

        final date =
            DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
        final today = DateTime.now();
        final isToday = _isSameDay(date, today);
        final isFuture = date.isAfter(DateTime(today.year, today.month, today.day));
        final isSelected = _selectedPeriodType == PeriodType.day &&
            _isSameDay(date, _selectedDate);

        // Week selection logic
        final isInWeekRange = _selectedPeriodType == PeriodType.week &&
            _rangeStart != null &&
            _rangeEnd != null &&
            (date.isAtSameMomentAs(_rangeStart!) ||
                date.isAtSameMomentAs(_rangeEnd!) ||
                (date.isAfter(_rangeStart!) && date.isBefore(_rangeEnd!)));

        final isWeekStart = _selectedPeriodType == PeriodType.week &&
            _rangeStart != null &&
            _isSameDay(date, _rangeStart!);

        final isWeekEnd = _selectedPeriodType == PeriodType.week &&
            _rangeEnd != null &&
            _isSameDay(date, _rangeEnd!);

        // Period (custom range) selection logic
        final isPeriodStart = _selectedPeriodType == PeriodType.period &&
            _rangeStart != null &&
            _isSameDay(date, _rangeStart!);

        final isPeriodEnd = _selectedPeriodType == PeriodType.period &&
            _rangeEnd != null &&
            _isSameDay(date, _rangeEnd!);

        final isInPeriodRange = _selectedPeriodType == PeriodType.period &&
            _rangeStart != null &&
            _rangeEnd != null &&
            !isPeriodStart &&
            !isPeriodEnd &&
            date.isAfter(_rangeStart!) &&
            date.isBefore(_rangeEnd!);

        // Show first date selection with lighter color when only start is selected
        final isPeriodFirstDateOnly =
            _selectedPeriodType == PeriodType.period &&
                _rangeStart != null &&
                _rangeEnd == null &&
                _isSameDay(date, _rangeStart!);

        Color? backgroundColor;
        Color textColor = Colors.black87;
        BorderRadius? borderRadius;

        // Disable future dates
        if (isFuture) {
          textColor = Colors.grey.shade300;
        } else if (isSelected) {
          backgroundColor = AppTheme.primaryBlue;
          textColor = Colors.white;
          borderRadius = BorderRadius.circular(20);
        } else if (isInWeekRange) {
          backgroundColor = AppTheme.primaryBlue;
          textColor = Colors.white;
          if (isWeekStart && isWeekEnd) {
            borderRadius = BorderRadius.circular(20);
          } else if (isWeekStart) {
            borderRadius = const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            );
          } else if (isWeekEnd) {
            borderRadius = const BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            );
          } else {
            borderRadius = BorderRadius.zero;
          }
        } else if (isPeriodFirstDateOnly) {
          // First date selected in period mode - show with lighter blue
          backgroundColor = AppTheme.primaryBlue.withOpacity(0.3);
          textColor = AppTheme.primaryBlue;
          borderRadius = BorderRadius.circular(20);
        } else if (isPeriodStart || isPeriodEnd || isInPeriodRange) {
          backgroundColor = AppTheme.primaryBlue;
          textColor = Colors.white;
          if (isPeriodStart && isPeriodEnd) {
            borderRadius = BorderRadius.circular(20);
          } else if (isPeriodStart) {
            borderRadius = const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            );
          } else if (isPeriodEnd) {
            borderRadius = const BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            );
          } else {
            borderRadius = BorderRadius.zero;
          }
        }

        // Show week numbers for week view
        // Remove margin for days in a range to eliminate white space
        final hasMargin = !isInWeekRange &&
            !isInPeriodRange &&
            !isPeriodStart &&
            !isPeriodEnd &&
            !isPeriodFirstDateOnly &&
            !isWeekStart &&
            !isWeekEnd;

        // Make today rounded when it's not part of any selection
        if (isToday &&
            !isSelected &&
            !isInWeekRange &&
            !isInPeriodRange &&
            borderRadius == null) {
          borderRadius = BorderRadius.circular(20);
        }

        Widget child = Container(
          margin: hasMargin ? const EdgeInsets.all(2) : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
            border: isToday &&
                    !isSelected &&
                    !isInWeekRange &&
                    !isInPeriodRange &&
                    !isPeriodStart &&
                    !isPeriodEnd
                ? Border.all(color: AppTheme.primaryBlue, width: 2)
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            dayNumber.toString(),
            style: TextStyle(
              fontSize: 13,
              color: textColor,
              fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        );

        // Add week number for week view
        if (_selectedPeriodType == PeriodType.week && date.weekday == 1) {
          final weekNumber = _getWeekNumber(date);
          child = Row(
            children: [
              Container(
                width: 20,
                alignment: Alignment.center,
                child: Text(
                  weekNumber.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(child: child),
            ],
          );
        }

        return GestureDetector(
          onTap: isFuture ? null : () {
            setState(() {
              // Reset custom comparison when selecting new period date
              // This ensures default comparison is used unless user explicitly sets custom
              if (!_isCompareMode) {
                _hasCustomComparison = false;
                _comparisonOffsetDays = null;
              }

              if (_selectedPeriodType == PeriodType.day) {
                _selectedDate = date;
              } else if (_selectedPeriodType == PeriodType.week) {
                _setWeekRange(date);
              } else if (_selectedPeriodType == PeriodType.period) {
                if (_rangeStart == null ||
                    (_rangeStart != null && _rangeEnd != null)) {
                  _rangeStart = date;
                  _rangeEnd = null;
                } else if (date.isBefore(_rangeStart!)) {
                  _rangeEnd = _rangeStart;
                  _rangeStart = date;
                } else {
                  _rangeEnd = date;
                }
              }
            });
          },
          child: child,
        );
      },
    );
  }

  Widget _buildCompareToContent() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildPeriodTypeSelector(),
          const SizedBox(height: 12),
          _buildCompareCalendarNavigation(),
          const SizedBox(height: 12),
          _buildCompareCalendarView(),
        ],
      ),
    );
  }

  Widget _buildComparePeriodTypeSelector() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildComparePeriodTypeButton(S.of(context).day, PeriodType.day),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildComparePeriodTypeButton(S.of(context).week, PeriodType.week),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildComparePeriodTypeButton(S.of(context).month, PeriodType.month),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildComparePeriodTypeButton(S.of(context).year, PeriodType.year),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildComparePeriodButtonWithDisplay(),
      ],
    );
  }

  Widget _buildComparePeriodTypeButton(String text, PeriodType type) {
    final isSelected = _selectedPeriodType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriodType = type;
          _hasCustomComparison = true;
          if (type == PeriodType.week) {
            _setCompareWeekRange(_compareRangeStart ?? DateTime.now());
          } else if (type == PeriodType.period) {
            _compareRangeStart = null;
            _compareRangeEnd = null;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.orange.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? Colors.orange : Colors.black87,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildComparePeriodButtonWithDisplay() {
    final isSelected = _selectedPeriodType == PeriodType.period;
    final formatter = DateFormat('MMM d');
    final hasDateRange = _compareRangeStart != null && _compareRangeEnd != null;

    return Row(
      children: [
        Expanded(
          flex: hasDateRange ? 2 : 1,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _hasCustomComparison = true;
                _selectedPeriodType = PeriodType.period;
                _compareRangeStart = null;
                _compareRangeEnd = null;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.orange.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    S.of(context).period,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? Colors.orange : Colors.black87,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  if (isSelected && !hasDateRange)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Click calendar dates',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (hasDateRange && isSelected) ...[
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${formatter.format(_compareRangeStart!)} - ${formatter.format(_compareRangeEnd!)}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompareCalendarNavigation() {
    String title = '';
    switch (_selectedPeriodType) {
      case PeriodType.year:
        title = _currentYear.toString();
        break;
      case PeriodType.month:
        title = _currentYear.toString();
        break;
      default:
        title = DateFormat('MMM yyyy').format(_currentMonth);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _previousPeriod,
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _nextPeriod,
        ),
      ],
    );
  }

  Widget _buildCompareCalendarView() {
    switch (_selectedPeriodType) {
      case PeriodType.year:
        return _buildCompareYearSelector();
      case PeriodType.month:
        return _buildCompareMonthSelector();
      default:
        return _buildCompareNewDayCalendar();
    }
  }

  Widget _buildCompareNewDayCalendar() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final daysInMonth = lastDay.day;

    int firstWeekday = firstDay.weekday - 1;
    if (firstWeekday < 0) firstWeekday = 6;

    final totalCells = ((daysInMonth + firstWeekday) / 7).ceil() * 7;

    // Get the BLUE period from Period tab (read-only display)
    DateTime? bluePeriodStart;
    DateTime? bluePeriodEnd;

    switch (_selectedPeriodType) {
      case PeriodType.day:
        bluePeriodStart = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 0, 0);
        bluePeriodEnd = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59);
        break;
      case PeriodType.week:
      case PeriodType.period:
        if (_rangeStart != null && _rangeEnd != null) {
          bluePeriodStart = _rangeStart;
          bluePeriodEnd = _rangeEnd;
        }
        break;
      case PeriodType.month:
        bluePeriodStart = DateTime(_selectedDate.year, _selectedDate.month, 1, 0, 0);
        bluePeriodEnd = DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 23, 59);
        break;
      case PeriodType.year:
        bluePeriodStart = DateTime(_selectedDate.year, 1, 1, 0, 0);
        bluePeriodEnd = DateTime(_selectedDate.year, 12, 31, 23, 59);
        break;
    }

    return Column(
      children: [
        _buildWeekDayHeaders(),
        const SizedBox(height: 4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.5,
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
          ),
          itemCount: totalCells,
          itemBuilder: (context, index) {
            final dayNumber = index - firstWeekday + 1;

            if (dayNumber < 1 || dayNumber > daysInMonth) {
              return const SizedBox.shrink();
            }

            final date = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
            final today = DateTime.now();
            final isToday = _isSameDay(date, today);

            // Check if date is disabled (future or same/after period start)
            final isFuture = date.isAfter(DateTime(today.year, today.month, today.day));
            final isInOrAfterPeriod = bluePeriodStart != null && !date.isBefore(bluePeriodStart);
            final isDisabled = isFuture || isInOrAfterPeriod;

            // BLUE: Check if date is in the Period tab selection (read-only)
            final isInBlueRange = bluePeriodStart != null &&
                bluePeriodEnd != null &&
                !date.isBefore(bluePeriodStart) &&
                !date.isAfter(bluePeriodEnd);
            final isBlueStart = bluePeriodStart != null && _isSameDay(date, bluePeriodStart);
            final isBlueEnd = bluePeriodEnd != null && _isSameDay(date, bluePeriodEnd);

            // ORANGE: Check if date is in the compare selection
            final isInOrangeRange = _compareRangeStart != null &&
                _compareRangeEnd != null &&
                !date.isBefore(_compareRangeStart!) &&
                !date.isAfter(_compareRangeEnd!);
            final isOrangeStart = _compareRangeStart != null && _isSameDay(date, _compareRangeStart!);
            final isOrangeEnd = _compareRangeEnd != null && _isSameDay(date, _compareRangeEnd!);
            final isOrangeFirstOnly = _compareRangeStart != null &&
                _compareRangeEnd == null &&
                _isSameDay(date, _compareRangeStart!);

            Color? backgroundColor;
            Color textColor = Colors.black87;
            BorderRadius? borderRadius;

            // Disabled dates (future or same/after period)
            if (isDisabled && !isInBlueRange) {
              textColor = Colors.grey.shade300;
            }
            // Priority: Blue first, then Orange
            else if (isInBlueRange) {
              backgroundColor = AppTheme.primaryBlue;
              textColor = Colors.white;
              if (isBlueStart && isBlueEnd) {
                borderRadius = BorderRadius.circular(20);
              } else if (isBlueStart) {
                borderRadius = const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                );
              } else if (isBlueEnd) {
                borderRadius = const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                );
              } else {
                borderRadius = BorderRadius.zero;
              }
            } else if (isOrangeFirstOnly) {
              backgroundColor = Colors.orange.withOpacity(0.3);
              textColor = Colors.orange;
              borderRadius = BorderRadius.circular(20);
            } else if (isInOrangeRange) {
              backgroundColor = Colors.orange;
              textColor = Colors.white;
              if (isOrangeStart && isOrangeEnd) {
                borderRadius = BorderRadius.circular(20);
              } else if (isOrangeStart) {
                borderRadius = const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                );
              } else if (isOrangeEnd) {
                borderRadius = const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                );
              } else {
                borderRadius = BorderRadius.zero;
              }
            }

            final hasMargin = !isInBlueRange && !isInOrangeRange && !isOrangeFirstOnly;

            if (isToday && !isInBlueRange && !isInOrangeRange && !isDisabled && borderRadius == null) {
              borderRadius = BorderRadius.circular(20);
            }

            return GestureDetector(
              onTap: isDisabled ? null : () {
                setState(() {
                  _hasCustomComparison = true;
                  // Set compare range based on period type
                  if (_selectedPeriodType == PeriodType.day) {
                    _compareRangeStart = DateTime(date.year, date.month, date.day, 0, 0);
                    _compareRangeEnd = DateTime(date.year, date.month, date.day, 23, 59);
                  } else if (_selectedPeriodType == PeriodType.week) {
                    _setCompareWeekRange(date);
                  } else if (_selectedPeriodType == PeriodType.month) {
                    _compareRangeStart = DateTime(date.year, date.month, 1, 0, 0);
                    _compareRangeEnd = DateTime(date.year, date.month + 1, 0, 23, 59);
                  } else if (_selectedPeriodType == PeriodType.period) {
                    if (_compareRangeStart == null || (_compareRangeStart != null && _compareRangeEnd != null)) {
                      _compareRangeStart = date;
                      _compareRangeEnd = null;
                    } else if (date.isBefore(_compareRangeStart!)) {
                      _compareRangeEnd = _compareRangeStart;
                      _compareRangeStart = date;
                    } else {
                      _compareRangeEnd = date;
                    }
                  }
                });
              },
              child: Container(
                margin: hasMargin ? const EdgeInsets.all(2) : EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: borderRadius,
                  border: isToday && !isInBlueRange && !isInOrangeRange && !isDisabled
                      ? Border.all(color: AppTheme.primaryBlue, width: 2)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  dayNumber.toString(),
                  style: TextStyle(
                    fontSize: 13,
                    color: textColor,
                    fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _setCompareWeekRange(DateTime date) {
    final weekday = date.weekday;
    final monday = date.subtract(Duration(days: weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    _compareRangeStart = monday;
    _compareRangeEnd = sunday;
  }

  Widget _buildSelectedPeriodDisplay() {
    String periodText = '';
    String dateText = '';

    switch (_selectedPeriodType) {
      case PeriodType.day:
        periodText = S.of(context).day;
        dateText = DateFormat('dd.MM.yyyy').format(_selectedDate);
        break;
      case PeriodType.week:
        periodText = S.of(context).week;
        if (_rangeStart != null && _rangeEnd != null) {
          dateText =
              '${DateFormat('dd.MM').format(_rangeStart!)} - ${DateFormat('dd.MM.yyyy').format(_rangeEnd!)}';
        }
        break;
      case PeriodType.month:
        periodText = S.of(context).month;
        dateText = DateFormat('MMMM yyyy').format(_selectedDate);
        break;
      case PeriodType.year:
        periodText = S.of(context).year;
        dateText = _selectedDate.year.toString();
        break;
      case PeriodType.period:
        periodText = S.of(context).period;
        if (_rangeStart != null && _rangeEnd != null) {
          dateText =
              '${DateFormat('dd.MM').format(_rangeStart!)} - ${DateFormat('dd.MM.yyyy').format(_rangeEnd!)}';
        }
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).selectedPeriod,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 18, color: AppTheme.primaryBlue),
              const SizedBox(width: 8),
              Text(
                periodText,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '•',
                style: TextStyle(color: Colors.grey.shade400),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  dateText,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonOptions() {
    List<CompareOption> options = [];

    switch (_selectedPeriodType) {
      case PeriodType.day:
        options = [
          CompareOption(CompareToOption.yesterday, S.of(context).lastDay),
          CompareOption(CompareToOption.lastWeek, S.of(context).lastWeekOption),
          CompareOption(
              CompareToOption.lastMonth, S.of(context).lastMonthOption),
          CompareOption(CompareToOption.lastYear, S.of(context).lastYearOption),
        ];
        break;
      case PeriodType.week:
        options = [
          CompareOption(CompareToOption.lastWeek, S.of(context).lastWeek),
          CompareOption(
              CompareToOption.lastMonth, S.of(context).lastMonthOption),
          CompareOption(CompareToOption.lastYear, S.of(context).lastYearOption),
        ];
        break;
      case PeriodType.month:
        options = [
          CompareOption(CompareToOption.lastMonth, S.of(context).lastMonth),
          CompareOption(CompareToOption.lastYear, S.of(context).lastYearOption),
        ];
        break;
      case PeriodType.year:
        options = [
          CompareOption(CompareToOption.lastYear, S.of(context).lastYear),
        ];
        break;
      case PeriodType.period:
        options = [
          CompareOption(
              CompareToOption.lastWeek, S.of(context).sameDurationBack),
        ];
        break;
    }

    // Build rows of 2 buttons each
    List<Widget> rows = [];
    for (int i = 0; i < options.length; i += 2) {
      List<Widget> rowButtons = [];

      // First button
      rowButtons.add(Expanded(
        child: _buildCompareOptionButton(options[i]),
      ));

      // Second button if exists
      if (i + 1 < options.length) {
        rowButtons.add(const SizedBox(width: 8));
        rowButtons.add(Expanded(
          child: _buildCompareOptionButton(options[i + 1]),
        ));
      }

      rows.add(Row(children: rowButtons));
      if (i + 2 < options.length) {
        rows.add(const SizedBox(height: 8));
      }
    }

    return Column(children: rows);
  }

  Widget _buildCompareOptionButton(CompareOption option) {
    final isSelected = _selectedCompareOption == option.type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCompareOption = option.type;
          // Reset custom flag and offset when selecting default options
          _hasCustomComparison = false;
          _comparisonOffsetDays = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.orange.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          option.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? Colors.orange : Colors.black87,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  CompareToOption _detectComparisonOption() {
    if (_compareRangeStart == null || _compareRangeEnd == null) {
      return CompareToOption.customRange;
    }

    // Get current period start date
    DateTime currentStart;

    switch (_selectedPeriodType) {
      case PeriodType.day:
        currentStart = DateTime(
            _selectedDate.year, _selectedDate.month, _selectedDate.day, 0, 0);
        break;
      case PeriodType.week:
        if (_rangeStart == null || _rangeEnd == null) {
          return CompareToOption.customRange;
        }
        currentStart = DateTime(
            _rangeStart!.year, _rangeStart!.month, _rangeStart!.day, 0, 0);
        break;
      case PeriodType.month:
        currentStart =
            DateTime(_selectedDate.year, _selectedDate.month, 1, 0, 0);
        break;
      case PeriodType.year:
        currentStart = DateTime(_selectedDate.year, 1, 1, 0, 0);
        break;
      case PeriodType.period:
        if (_rangeStart == null || _rangeEnd == null) {
          return CompareToOption.customRange;
        }
        currentStart = DateTime(
            _rangeStart!.year, _rangeStart!.month, _rangeStart!.day, 0, 0);
        break;
    }

    // Check if it matches "yesterday" (1 day back)
    final yesterday = currentStart.subtract(const Duration(days: 1));
    if (_isSameDay(_compareRangeStart!, yesterday)) {
      return CompareToOption.yesterday;
    }

    // Check if it matches "last week" (7 days back)
    final lastWeek = currentStart.subtract(const Duration(days: 7));
    if (_isSameDay(_compareRangeStart!, lastWeek)) {
      return CompareToOption.lastWeek;
    }

    // Check if it matches "last month" (1 month back)
    try {
      final lastMonth = DateTime(
          currentStart.year, currentStart.month - 1, currentStart.day, 0, 0);
      if (_isSameDay(_compareRangeStart!, lastMonth)) {
        return CompareToOption.lastMonth;
      }
    } catch (e) {
      // Invalid date
    }

    // Check if it matches "last year" (1 year back)
    try {
      final lastYear = DateTime(
          currentStart.year - 1, currentStart.month, currentStart.day, 0, 0);
      if (_isSameDay(_compareRangeStart!, lastYear)) {
        return CompareToOption.lastYear;
      }
    } catch (e) {
      // Invalid date
    }

    // If none match, it's custom
    return CompareToOption.customRange;
  }

  void _calculateCompareDates() {
    // Get the current period from Period tab
    DateTime currentStart;
    DateTime currentEnd;

    switch (_selectedPeriodType) {
      case PeriodType.day:
        currentStart = DateTime(
            _selectedDate.year, _selectedDate.month, _selectedDate.day, 0, 0);
        currentEnd = DateTime(
            _selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59);
        break;
      case PeriodType.week:
        if (_rangeStart == null || _rangeEnd == null) return;
        currentStart = DateTime(
            _rangeStart!.year, _rangeStart!.month, _rangeStart!.day, 0, 0);
        currentEnd =
            DateTime(_rangeEnd!.year, _rangeEnd!.month, _rangeEnd!.day, 23, 59);
        break;
      case PeriodType.month:
        currentStart =
            DateTime(_selectedDate.year, _selectedDate.month, 1, 0, 0);
        currentEnd =
            DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 23, 59);
        break;
      case PeriodType.year:
        currentStart = DateTime(_selectedDate.year, 1, 1, 0, 0);
        currentEnd = DateTime(_selectedDate.year, 12, 31, 23, 59);
        break;
      case PeriodType.period:
        if (_rangeStart == null || _rangeEnd == null) return;
        currentStart = DateTime(
            _rangeStart!.year, _rangeStart!.month, _rangeStart!.day, 0, 0);
        currentEnd =
            DateTime(_rangeEnd!.year, _rangeEnd!.month, _rangeEnd!.day, 23, 59);
        break;
    }

    // Check if the main period has changed
    bool periodChanged = false;
    bool isFirstLoad = _lastPeriodStart == null && _lastPeriodEnd == null;

    if (!isFirstLoad) {
      periodChanged = !_isSameDay(_lastPeriodStart!, currentStart) ||
          !_isSameDay(_lastPeriodEnd!, currentEnd);
    }

    // Update last period
    _lastPeriodStart = currentStart;
    _lastPeriodEnd = currentEnd;

    // If period changed and we have a custom offset, apply it
    if (periodChanged && _comparisonOffsetDays != null) {
      _compareRangeStart = currentStart.subtract(Duration(days: _comparisonOffsetDays!));
      _compareRangeEnd = currentEnd.subtract(Duration(days: _comparisonOffsetDays!));
      return;
    }

    // If period changed or first load without custom offset, use default based on period type
    if (periodChanged || isFirstLoad) {
      if (!_hasCustomComparison) {
        _comparisonOffsetDays = null;
        _setDefaultComparisonOption();
      }
    }

    // If user has custom comparison and it's not first load, keep it (don't recalculate)
    if (_hasCustomComparison && !isFirstLoad && !periodChanged) {
      return;
    }

    // Calculate comparison dates based on selected option
    if (_selectedCompareOption == CompareToOption.customRange && !isFirstLoad) {
      // Don't auto-calculate for custom range unless it's first load
      return;
    }

    switch (_selectedCompareOption) {
      case CompareToOption.yesterday:
        _compareRangeStart = currentStart.subtract(const Duration(days: 1));
        _compareRangeEnd = currentEnd.subtract(const Duration(days: 1));
        break;
      case CompareToOption.lastWeek:
        if (_selectedPeriodType == PeriodType.period) {
          // For custom period, go back by the same duration
          final duration = currentEnd.difference(currentStart);
          _compareRangeStart =
              currentStart.subtract(duration).subtract(const Duration(days: 1));
          _compareRangeEnd = currentStart.subtract(const Duration(days: 1));
        } else {
          _compareRangeStart = currentStart.subtract(const Duration(days: 7));
          _compareRangeEnd = currentEnd.subtract(const Duration(days: 7));
        }
        break;
      case CompareToOption.lastMonth:
        try {
          _compareRangeStart = DateTime(
              currentStart.year,
              currentStart.month - 1,
              currentStart.day,
              currentStart.hour,
              currentStart.minute);
          _compareRangeEnd = DateTime(currentEnd.year, currentEnd.month - 1,
              currentEnd.day, currentEnd.hour, currentEnd.minute);
        } catch (e) {
          final lastDayOfPrevMonth =
              DateTime(currentStart.year, currentStart.month, 0);
          _compareRangeStart = DateTime(
              lastDayOfPrevMonth.year,
              lastDayOfPrevMonth.month,
              currentStart.day > lastDayOfPrevMonth.day
                  ? lastDayOfPrevMonth.day
                  : currentStart.day,
              currentStart.hour,
              currentStart.minute);
          _compareRangeEnd = DateTime(
              lastDayOfPrevMonth.year,
              lastDayOfPrevMonth.month,
              currentEnd.day > lastDayOfPrevMonth.day
                  ? lastDayOfPrevMonth.day
                  : currentEnd.day,
              currentEnd.hour,
              currentEnd.minute);
        }
        break;
      case CompareToOption.lastYear:
        try {
          _compareRangeStart = DateTime(
              currentStart.year - 1,
              currentStart.month,
              currentStart.day,
              currentStart.hour,
              currentStart.minute);
          _compareRangeEnd = DateTime(currentEnd.year - 1, currentEnd.month,
              currentEnd.day, currentEnd.hour, currentEnd.minute);
        } catch (e) {
          final lastDayOfMonth =
              DateTime(currentStart.year - 1, currentStart.month + 1, 0);
          _compareRangeStart = DateTime(
              currentStart.year - 1,
              currentStart.month,
              currentStart.day > lastDayOfMonth.day
                  ? lastDayOfMonth.day
                  : currentStart.day,
              currentStart.hour,
              currentStart.minute);
          _compareRangeEnd = DateTime(
              currentEnd.year - 1,
              currentEnd.month,
              currentEnd.day > lastDayOfMonth.day
                  ? lastDayOfMonth.day
                  : currentEnd.day,
              currentEnd.hour,
              currentEnd.minute);
        }
        break;
      default:
        break;
    }
  }

  void _setDefaultComparisonOption() {
    switch (_selectedPeriodType) {
      case PeriodType.day:
        _selectedCompareOption = CompareToOption.yesterday;
        break;
      case PeriodType.week:
        _selectedCompareOption = CompareToOption.lastWeek;
        break;
      case PeriodType.month:
        _selectedCompareOption = CompareToOption.lastMonth;
        break;
      case PeriodType.year:
        _selectedCompareOption = CompareToOption.lastYear;
        break;
      case PeriodType.period:
        _selectedCompareOption = CompareToOption.lastWeek;
        break;
    }
  }

  Widget _buildCompareCalendar() {
    // Use different calendar view based on period type
    switch (_selectedPeriodType) {
      case PeriodType.year:
        return _buildCompareYearSelector();
      case PeriodType.month:
        return _buildCompareMonthSelector();
      default:
        return _buildCompareDayCalendar();
    }
  }

  Widget _buildCompareDayCalendar() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final daysInMonth = lastDay.day;

    int firstWeekday = firstDay.weekday - 1;
    if (firstWeekday < 0) firstWeekday = 6;

    final totalCells = ((daysInMonth + firstWeekday) / 7).ceil() * 7;

    // Get current period from Period tab for BLUE display
    DateTime? currentPeriodStart;
    DateTime? currentPeriodEnd;

    switch (_selectedPeriodType) {
      case PeriodType.day:
        currentPeriodStart = DateTime(
            _selectedDate.year, _selectedDate.month, _selectedDate.day, 0, 0);
        currentPeriodEnd = DateTime(
            _selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59);
        break;
      case PeriodType.week:
        if (_rangeStart != null && _rangeEnd != null) {
          currentPeriodStart = DateTime(
              _rangeStart!.year, _rangeStart!.month, _rangeStart!.day, 0, 0);
          currentPeriodEnd = DateTime(
              _rangeEnd!.year, _rangeEnd!.month, _rangeEnd!.day, 23, 59);
        }
        break;
      case PeriodType.month:
        currentPeriodStart =
            DateTime(_selectedDate.year, _selectedDate.month, 1, 0, 0);
        currentPeriodEnd =
            DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 23, 59);
        break;
      case PeriodType.year:
        currentPeriodStart = DateTime(_selectedDate.year, 1, 1, 0, 0);
        currentPeriodEnd = DateTime(_selectedDate.year, 12, 31, 23, 59);
        break;
      case PeriodType.period:
        if (_rangeStart != null && _rangeEnd != null) {
          currentPeriodStart = DateTime(
              _rangeStart!.year, _rangeStart!.month, _rangeStart!.day, 0, 0);
          currentPeriodEnd = DateTime(
              _rangeEnd!.year, _rangeEnd!.month, _rangeEnd!.day, 23, 59);
        }
        break;
    }

    return Column(
      children: [
        _buildWeekDayHeaders(),
        const SizedBox(height: 4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.5,
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
          ),
          itemCount: totalCells,
          itemBuilder: (context, index) {
            final dayNumber = index - firstWeekday + 1;

            if (dayNumber < 1 || dayNumber > daysInMonth) {
              return const SizedBox.shrink();
            }

            final date =
                DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
            final isToday = _isSameDay(date, DateTime.now());

            // Check BLUE range (current period from Period tab - READ ONLY)
            final isInCurrentRange = currentPeriodStart != null &&
                currentPeriodEnd != null &&
                !date.isBefore(currentPeriodStart) &&
                !date.isAfter(currentPeriodEnd);

            final isCurrentStart = currentPeriodStart != null &&
                _isSameDay(date, currentPeriodStart);

            final isCurrentEnd =
                currentPeriodEnd != null && _isSameDay(date, currentPeriodEnd);

            // Check ORANGE range (comparison period)
            final isInCompareRange = _compareRangeStart != null &&
                _compareRangeEnd != null &&
                !date.isBefore(_compareRangeStart!) &&
                !date.isAfter(_compareRangeEnd!);

            final isCompareStart = _compareRangeStart != null &&
                _isSameDay(date, _compareRangeStart!);

            final isCompareEnd =
                _compareRangeEnd != null && _isSameDay(date, _compareRangeEnd!);

            final isCompareOnlyStart = _compareRangeStart != null &&
                _compareRangeEnd == null &&
                _isSameDay(date, _compareRangeStart!);

            Color? backgroundColor;
            Color? textColor = Colors.black87;
            BorderRadius? borderRadius;

            // Priority: Blue > Orange > Today
            if (isInCurrentRange) {
              // BLUE: Full range
              backgroundColor = AppTheme.primaryBlue;
              textColor = Colors.white;
              if (isCurrentStart && isCurrentEnd) {
                borderRadius = BorderRadius.circular(20);
              } else if (isCurrentStart) {
                borderRadius = const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                );
              } else if (isCurrentEnd) {
                borderRadius = const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                );
              } else {
                borderRadius = BorderRadius.zero;
              }
            } else if (isCompareOnlyStart) {
              // ORANGE: First date selected
              backgroundColor = Colors.orange.withOpacity(0.3);
              textColor = Colors.orange;
              borderRadius = BorderRadius.circular(20);
            } else if (isInCompareRange) {
              // ORANGE: Full range
              backgroundColor = Colors.orange;
              textColor = Colors.white;
              if (isCompareStart && isCompareEnd) {
                borderRadius = BorderRadius.circular(20);
              } else if (isCompareStart) {
                borderRadius = const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                );
              } else if (isCompareEnd) {
                borderRadius = const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                );
              } else {
                borderRadius = BorderRadius.zero;
              }
            } else if (isToday) {
              backgroundColor = AppTheme.primaryBlue;
              textColor = Colors.white;
              borderRadius = BorderRadius.circular(20);
            }

            return GestureDetector(
              onTap: () {
                setState(() {
                  // Automatically switch to custom mode when clicking calendar
                  _selectedCompareOption = CompareToOption.customRange;
                  _hasCustomComparison = true;

                  // Get current period start for offset calculation
                  DateTime currentStart;
                  switch (_selectedPeriodType) {
                    case PeriodType.day:
                      currentStart = DateTime(
                          _selectedDate.year, _selectedDate.month, _selectedDate.day, 0, 0);
                      break;
                    case PeriodType.week:
                      currentStart = DateTime(
                          _rangeStart!.year, _rangeStart!.month, _rangeStart!.day, 0, 0);
                      break;
                    case PeriodType.month:
                      currentStart = DateTime(_selectedDate.year, _selectedDate.month, 1, 0, 0);
                      break;
                    case PeriodType.year:
                      currentStart = DateTime(_selectedDate.year, 1, 1, 0, 0);
                      break;
                    case PeriodType.period:
                      currentStart = DateTime(
                          _rangeStart!.year, _rangeStart!.month, _rangeStart!.day, 0, 0);
                      break;
                  }

                  // Handle selection based on period type
                  switch (_selectedPeriodType) {
                    case PeriodType.day:
                      // For day comparison, select single day
                      _compareRangeStart =
                          DateTime(date.year, date.month, date.day, 0, 0);
                      _compareRangeEnd =
                          DateTime(date.year, date.month, date.day, 23, 59);
                      // Calculate offset in days
                      _comparisonOffsetDays = currentStart.difference(_compareRangeStart!).inDays;
                      break;
                    case PeriodType.week:
                      // For week comparison, select week
                      final weekday = date.weekday;
                      final monday = date.subtract(Duration(days: weekday - 1));
                      final sunday = monday.add(const Duration(days: 6));
                      _compareRangeStart =
                          DateTime(monday.year, monday.month, monday.day, 0, 0);
                      _compareRangeEnd = DateTime(
                          sunday.year, sunday.month, sunday.day, 23, 59);
                      // Calculate offset in days
                      _comparisonOffsetDays = currentStart.difference(_compareRangeStart!).inDays;
                      break;
                    case PeriodType.month:
                      // For month comparison, select month
                      _compareRangeStart =
                          DateTime(date.year, date.month, 1, 0, 0);
                      _compareRangeEnd =
                          DateTime(date.year, date.month + 1, 0, 23, 59);
                      // Calculate offset in days
                      _comparisonOffsetDays = currentStart.difference(_compareRangeStart!).inDays;
                      break;
                    case PeriodType.year:
                      // For year comparison, select year
                      _compareRangeStart = DateTime(date.year, 1, 1, 0, 0);
                      _compareRangeEnd = DateTime(date.year, 12, 31, 23, 59);
                      // Calculate offset in days
                      _comparisonOffsetDays = currentStart.difference(_compareRangeStart!).inDays;
                      break;
                    case PeriodType.period:
                      // For custom period, allow range selection
                      if (_compareRangeStart == null ||
                          (_compareRangeStart != null &&
                              _compareRangeEnd != null)) {
                        // Start new selection
                        _compareRangeStart =
                            DateTime(date.year, date.month, date.day, 0, 0);
                        _compareRangeEnd = null;
                      } else if (date.isBefore(_compareRangeStart!)) {
                        // Swap if selected earlier date
                        _compareRangeEnd = DateTime(
                            _compareRangeStart!.year,
                            _compareRangeStart!.month,
                            _compareRangeStart!.day,
                            23,
                            59);
                        _compareRangeStart =
                            DateTime(date.year, date.month, date.day, 0, 0);
                        // Calculate offset in days
                        _comparisonOffsetDays = currentStart.difference(_compareRangeStart!).inDays;
                      } else {
                        // Set end date
                        _compareRangeEnd =
                            DateTime(date.year, date.month, date.day, 23, 59);
                        // Calculate offset in days
                        _comparisonOffsetDays = currentStart.difference(_compareRangeStart!).inDays;
                      }
                      break;
                  }
                });
              },
              child: Container(
                margin: (isInCompareRange || isInCurrentRange)
                    ? EdgeInsets.zero
                    : const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: borderRadius,
                  border: isToday && !isInCompareRange && !isInCurrentRange
                      ? Border.all(color: AppTheme.primaryBlue, width: 2)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  dayNumber.toString(),
                  style: TextStyle(
                    fontSize: 13,
                    color: textColor,
                    fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCompareMonthSelector() {
    final months = [
      S.of(context).janShort,
      S.of(context).febShort,
      S.of(context).marShort,
      S.of(context).aprShort,
      S.of(context).mayShort,
      S.of(context).junShort,
      S.of(context).julShort,
      S.of(context).augShort,
      S.of(context).sepShort,
      S.of(context).octShort,
      S.of(context).novShort,
      S.of(context).decShort,
    ];

    // Get selected month from Period tab (BLUE)
    final selectedMonth = _selectedDate.month;
    final selectedYear = _selectedDate.year;
    final now = DateTime.now();

    // Get comparison month (ORANGE)
    DateTime? compareMonth;
    if (_compareRangeStart != null) {
      compareMonth = _compareRangeStart;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 1,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final monthIndex = index + 1;
        final isSelectedPeriod =
            _currentYear == selectedYear && monthIndex == selectedMonth;
        final isCompareMonth = compareMonth != null &&
            _currentYear == compareMonth.year &&
            monthIndex == compareMonth.month;

        // Disable future months and months >= selected period
        final isFuture = _currentYear > now.year ||
            (_currentYear == now.year && monthIndex > now.month);
        final isAfterOrSamePeriod = _currentYear > selectedYear ||
            (_currentYear == selectedYear && monthIndex >= selectedMonth);
        final isDisabled = isFuture || isAfterOrSamePeriod;

        return GestureDetector(
          onTap: isDisabled ? null : () {
            setState(() {
              _selectedCompareOption = CompareToOption.customRange;
              _hasCustomComparison = true;
              _compareRangeStart = DateTime(_currentYear, monthIndex, 1, 0, 0);
              _compareRangeEnd =
                  DateTime(_currentYear, monthIndex + 1, 0, 23, 59);

              // Calculate offset for smart recalculation
              final currentStart = DateTime(_selectedDate.year, _selectedDate.month, 1, 0, 0);
              _comparisonOffsetDays = currentStart.difference(_compareRangeStart!).inDays;
            });
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelectedPeriod
                  ? AppTheme.primaryBlue.withOpacity(0.1)
                  : isCompareMonth
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              months[index],
              style: TextStyle(
                fontSize: 15,
                color: isDisabled && !isSelectedPeriod
                    ? Colors.grey.shade300
                    : isSelectedPeriod
                        ? AppTheme.primaryBlue
                        : isCompareMonth
                            ? Colors.orange
                            : Colors.black87,
                fontWeight: isSelectedPeriod || isCompareMonth
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompareYearSelector() {
    // Get selected year from Period tab (BLUE)
    final selectedYear = _selectedDate.year;
    final now = DateTime.now();

    // Get comparison year (ORANGE)
    int? compareYear;
    if (_compareRangeStart != null) {
      compareYear = _compareRangeStart!.year;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 1,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final year = _currentYear + index - 5;
        final isSelectedPeriod = year == selectedYear;
        final isCompareYear = year == compareYear;

        // Disable future years and years >= selected period
        final isFuture = year > now.year;
        final isAfterOrSamePeriod = year >= selectedYear;
        final isDisabled = isFuture || isAfterOrSamePeriod;

        return GestureDetector(
          onTap: isDisabled ? null : () {
            setState(() {
              _selectedCompareOption = CompareToOption.customRange;
              _hasCustomComparison = true;
              _compareRangeStart = DateTime(year, 1, 1, 0, 0);
              _compareRangeEnd = DateTime(year, 12, 31, 23, 59);

              // Calculate offset for smart recalculation
              final currentStart = DateTime(_selectedDate.year, 1, 1, 0, 0);
              _comparisonOffsetDays = currentStart.difference(_compareRangeStart!).inDays;
            });
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelectedPeriod
                  ? AppTheme.primaryBlue.withOpacity(0.1)
                  : isCompareYear
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              year.toString(),
              style: TextStyle(
                fontSize: 15,
                color: isDisabled && !isSelectedPeriod
                    ? Colors.grey.shade300
                    : isSelectedPeriod
                        ? AppTheme.primaryBlue
                        : isCompareYear
                            ? Colors.orange
                            : Colors.black87,
                fontWeight: isSelectedPeriod || isCompareYear
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _setWeekRange(DateTime date) {
    final weekday = date.weekday;
    final monday = date.subtract(Duration(days: weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    _rangeStart = monday;
    _rangeEnd = sunday;
  }

  int _getWeekNumber(DateTime date) {
    // Calculate which week of the month this Monday represents
    // Week 1 = first Monday of the month, Week 2 = second Monday, etc.
    int weekOfMonth = 0;
    DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);

    // Find the first Monday of the month
    int daysUntilFirstMonday = (8 - firstDayOfMonth.weekday) % 7;
    DateTime firstMonday =
        firstDayOfMonth.add(Duration(days: daysUntilFirstMonday));

    // Count how many weeks (Mondays) have passed
    if (date.isBefore(firstMonday)) {
      weekOfMonth = 0; // Before first Monday
    } else {
      weekOfMonth = ((date.day - firstMonday.day) / 7).floor() + 1;
    }

    return weekOfMonth;
  }
}

enum PeriodType {
  day,
  week,
  month,
  year,
  period,
}

enum CompareToOption {
  today,
  yesterday,
  thisWeek,
  lastWeek,
  thisMonth,
  lastMonth,
  thisYear,
  lastYear,
  customRange,
}

class CompareOption {
  final CompareToOption type;
  final String label;

  CompareOption(this.type, this.label);
}
