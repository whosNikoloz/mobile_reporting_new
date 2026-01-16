import 'package:flutter/material.dart';
import 'package:mobile_reporting/screens/sales_summary_screen.dart';

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

  final Map<String, List<String>> _reports = {
    'Sales': [
      'Sales by Day',
      'Sales by Hour',
      'Sales by Weekday',
      'Sales by Month',
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildTab('Sales'),
                const SizedBox(width: 12),
                _buildTab('Finances'),
                const SizedBox(width: 12),
                _buildTab('Staff'),
                const SizedBox(width: 12),
                _buildTab('Stock'),
              ],
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
                      // Category Title
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      // Report Items
                      ...reports.map((report) => _buildReportItem(report)),

                      const SizedBox(height: 24),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title) {
    final isSelected = _selectedTab == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = title;
        });
        _scrollToSection(title);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[600] : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey[700],
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
          title,
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
