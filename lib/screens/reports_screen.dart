import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_reporting/localization/generated/l10n.dart';
import 'package:mobile_reporting/screens/sales_summary_screen.dart';
import 'package:mobile_reporting/theme/app_theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedTab = 'Sales';
  final ScrollController _scrollController = ScrollController();
  bool _isScrollingToSection = false;
  DateTime _lastScrollUpdate = DateTime.now();

  // GlobalKeys for each section to scroll to
  final Map<String, GlobalKey> _sectionKeys = {
    'Sales': GlobalKey(),
    'Finances': GlobalKey(),
    'Staff': GlobalKey(),
    'Stock': GlobalKey(),
  };

  // Icons for each category
  final Map<String, String> _categoryIcons = {
    'Sales': 'assets/icons/reports/sales.svg',
    'Finances': 'assets/icons/reports/finances.svg',
    'Staff': 'assets/icons/reports/staff.svg',
    'Stock': 'assets/icons/reports/stock.svg',
  };

  final Map<String, List<String>> _reports = {
    'Sales': [
      'Sales by Days',
      'Sales by Hour',
      'Sales by Weekday',
    ],
    'Finances': [
      'Revenue Report',
      'Expense Report',
      'Profit & Loss',
    ],
    'Staff': [
      'Staff Performance',
      'Attendance Report',
      'Commission Report',
      'Shift Report',
      'Hours Worked',
      'Productivity Report',
    ],
    'Stock': [
      'Inventory Report',
      'Stock Movement',
    ],
  };

  String _getCategoryTitle(BuildContext context, String category) {
    final l10n = S.of(context);
    switch (category) {
      case 'Sales':
        return l10n.sales;
      case 'Finances':
        return l10n.finances;
      case 'Staff':
        return l10n.staff;
      case 'Stock':
        return l10n.stock;
      default:
        return category;
    }
  }

  String _getReportTitle(BuildContext context, String report) {
    final l10n = S.of(context);
    switch (report) {
      case 'Sales by Days':
        return l10n.salesByDay;
      case 'Sales by Hour':
        return l10n.salesByHours;
      case 'Sales by Weekday':
        return l10n.salesByWeekday;
      case 'Revenue Report':
        return l10n.revenueReport;
      case 'Expense Report':
        return l10n.expenseReport;
      case 'Profit & Loss':
        return l10n.profitAndLoss;
      case 'Staff Performance':
        return l10n.staffPerformance;
      case 'Attendance Report':
        return l10n.attendanceReport;
      case 'Commission Report':
        return l10n.commissionReport;
      case 'Shift Report':
        return l10n.shiftReport;
      case 'Hours Worked':
        return l10n.hoursWorked;
      case 'Productivity Report':
        return l10n.productivityReport;
      case 'Inventory Report':
        return l10n.inventoryReport;
      case 'Stock Movement':
        return l10n.stockMovement;
      default:
        return report;
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Skip if we're animating to a section
    if (_isScrollingToSection) return;

    // Throttle updates to every 100ms
    final now = DateTime.now();
    if (now.difference(_lastScrollUpdate).inMilliseconds < 100) return;
    _lastScrollUpdate = now;

    // Find which section is currently most visible
    String? visibleSection;
    double minDistance = double.infinity;

    for (final entry in _sectionKeys.entries) {
      final key = entry.value;
      if (key.currentContext != null) {
        final RenderBox? renderBox =
            key.currentContext!.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final position = renderBox.localToGlobal(Offset.zero);
          // Check distance from top of the visible area (accounting for tabs)
          final distance = (position.dy - 150).abs();
          if (position.dy <= 200 && distance < minDistance) {
            minDistance = distance;
            visibleSection = entry.key;
          }
        }
      }
    }

    // Update selected tab if we found a visible section
    if (visibleSection != null && visibleSection != _selectedTab) {
      setState(() {
        _selectedTab = visibleSection!;
      });
    }
  }

  Future<void> _scrollToSection(String section) async {
    final key = _sectionKeys[section];
    if (key?.currentContext != null) {
      _isScrollingToSection = true;
      await Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      _isScrollingToSection = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildTab('Sales'),
                  const SizedBox(width: 10),
                  _buildTab('Finances'),
                  const SizedBox(width: 10),
                  _buildTab('Staff'),
                  const SizedBox(width: 10),
                  _buildTab('Stock'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Content
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                ..._reports.keys.map((category) {
                  final reports = _reports[category]!;
                  return Column(
                    key: _sectionKeys[category],
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            _categoryIcons[category]!,
                            width: 20,
                            height: 20,
                            colorFilter: const ColorFilter.mode(
                                AppTheme.primaryBlue, BlendMode.srcIn),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getCategoryTitle(context, category),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Report Items
                      ...reports.map((report) => _buildReportItem(report)),

                      const SizedBox(height: 24),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title) {
    final isSelected = _selectedTab == title;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = title;
          });
          _scrollToSection(title);
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[600] : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                _categoryIcons[title]!,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                    isSelected ? Colors.white : Colors.grey[700]!,
                    BlendMode.srcIn),
              ),
              const SizedBox(width: 6),
              Text(
                _getCategoryTitle(context, title),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportItem(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          _getReportTitle(context, title),
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.blue[600],
          size: 24,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SalesSummaryScreen(reportTitle: title),
            ),
          );
        },
      ),
    );
  }
}
