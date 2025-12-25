import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  const DateRangePicker({
    Key? key,
    this.initialStartDate,
    this.initialEndDate,
    this.initialPeriodType,
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
  CompareToOption _selectedCompareOption = CompareToOption.today;
  DateTime? _compareRangeStart;
  DateTime? _compareRangeEnd;

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
              child: const Text(
                'გაუქმება',
                style: TextStyle(
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
              child: const Text(
                'დადასტურება',
                style: TextStyle(
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

    switch (_selectedPeriodType) {
      case PeriodType.day:
        startDate = DateTime(
            _selectedDate.year, _selectedDate.month, _selectedDate.day, 0, 0);
        endDate = DateTime(
            _selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59);
        break;
      case PeriodType.week:
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
          _buildTab('პერიოდი', !_isCompareMode),
          const SizedBox(width: 32),
          _buildTab('შედარება', _isCompareMode),
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
              child: _buildPeriodTypeButton('დღე', PeriodType.day),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPeriodTypeButton('კვირა', PeriodType.week),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildPeriodTypeButton('თვე', PeriodType.month),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPeriodTypeButton('წელი', PeriodType.year),
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
              child: Text(
                'პერიოდი',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? AppTheme.primaryBlue : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
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

  Widget _buildPeriodTypeButton(String text, PeriodType type,
      {bool fullWidth = false}) {
    final isSelected = _selectedPeriodType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
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

  Widget _buildCustomPeriodDisplay() {
    if (_rangeStart != null && _rangeEnd != null) {
      final formatter = DateFormat('MMM d');
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'პერიოდი',
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '${formatter.format(_rangeStart!)} - ${formatter.format(_rangeEnd!)}',
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.primaryBlue,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
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
        return GestureDetector(
          onTap: () {
            setState(() {
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
                color: year == _selectedDate.year
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
      'იან',
      'თებ',
      'მარ',
      'აპრ',
      'მაი',
      'ივნ',
      'ივლ',
      'აგვ',
      'სექ',
      'ოქტ',
      'ნოე',
      'დეკ'
    ];

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
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = DateTime(_currentYear, index + 1);
            });
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _selectedDate.year == _currentYear &&
                      _selectedDate.month == index + 1
                  ? AppTheme.primaryBlue.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              months[index],
              style: TextStyle(
                fontSize: 15,
                color: _selectedDate.year == _currentYear &&
                        _selectedDate.month == index + 1
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
    final days = ['ორშ', 'სამ', 'ოთხ', 'ხუთ', 'პარ', 'შაბ', 'კვი'];
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
        childAspectRatio: 1.3,
        crossAxisSpacing: 0,
        mainAxisSpacing: 3,
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
        Color? textColor = Colors.black87;
        BorderRadius? borderRadius;

        if (isSelected) {
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
          // First date selected in period mode - show with lighter color
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
          onTap: () {
            setState(() {
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
          _buildCompareToDropdown('დღეს'),
          const SizedBox(height: 12),
          Text(
            'შედარება',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          _buildCompareToDropdown('პერიოდი'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '11.11.24',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '11.12.24',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCalendarNavigation(),
          const SizedBox(height: 12),
          _buildCompareCalendar(),
        ],
      ),
    );
  }

  Widget _buildCompareToDropdown(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 20, color: Colors.orange),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 15),
          ),
          const Spacer(),
          Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildCompareCalendar() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final daysInMonth = lastDay.day;

    int firstWeekday = firstDay.weekday - 1;
    if (firstWeekday < 0) firstWeekday = 6;

    final totalCells = ((daysInMonth + firstWeekday) / 7).ceil() * 7;

    return Column(
      children: [
        _buildWeekDayHeaders(),
        const SizedBox(height: 4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.1,
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

            // Check if in compare range (15-21 in the example)
            final isInCompareRange = dayNumber >= 15 && dayNumber <= 21;

            Color? backgroundColor;
            Color? textColor = Colors.black87;
            BorderRadius? borderRadius;

            if (isToday) {
              backgroundColor = AppTheme.primaryBlue;
              textColor = Colors.white;
              borderRadius = BorderRadius.circular(20);
            } else if (isInCompareRange) {
              backgroundColor = Colors.orange;
              textColor = Colors.white;
              if (dayNumber == 15) {
                borderRadius = const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                );
              } else if (dayNumber == 21) {
                borderRadius = const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                );
              } else {
                borderRadius = BorderRadius.zero;
              }
            }

            return Container(
              margin:
                  isInCompareRange ? EdgeInsets.zero : const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: borderRadius,
                border: isToday && !isInCompareRange
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
          },
        ),
      ],
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
