import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_reporting/localization/generated/l10n.dart';
import 'package:mobile_reporting/screens/sales_summary_screen.dart';
import 'package:mobile_reporting/screens/store_sales_screen.dart';
import 'package:mobile_reporting/screens/top_products_screen.dart';
import 'package:mobile_reporting/screens/category_sales_screen.dart';
import 'package:mobile_reporting/screens/staff_sales_screen.dart';
import 'package:mobile_reporting/screens/payment_entities_screen.dart';
import 'package:mobile_reporting/screens/profit_by_products_screen.dart';
import 'package:mobile_reporting/screens/profit_by_categories_screen.dart';
import 'package:mobile_reporting/screens/buyers_debt_screen.dart';
import 'package:mobile_reporting/screens/suppliers_debt_screen.dart';
import 'package:mobile_reporting/screens/vendor_payments_screen.dart';
import 'package:mobile_reporting/screens/vendor_purchases_screen.dart';
import 'package:mobile_reporting/screens/vendor_returns_screen.dart';
import 'package:mobile_reporting/screens/customer_sales_screen.dart';
import 'package:mobile_reporting/screens/customer_returns_screen.dart';
import 'package:mobile_reporting/screens/customer_payments_screen.dart';
import 'package:mobile_reporting/screens/inventory_balance_screen.dart';
import 'package:mobile_reporting/screens/purchases_documents_screen.dart';
import 'package:mobile_reporting/screens/product_sales_summary_screen.dart';
import 'package:mobile_reporting/screens/product_sales_details_screen.dart';
import 'package:mobile_reporting/screens/store_transfer_details_screen.dart';
import 'package:mobile_reporting/screens/sale_documents_screen.dart';
import 'package:mobile_reporting/screens/sale_documents_products_summary_screen.dart';
import 'package:mobile_reporting/screens/sale_documents_products_details_screen.dart';
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
    //'Staff': GlobalKey(),
    'Stock': GlobalKey(),
  };

  // Icons for each category
  final Map<String, String> _categoryIcons = {
    'Sales': 'assets/icons/reports/sales.svg',
    'Finances': 'assets/icons/reports/finances.svg',
    //'Staff': 'assets/icons/reports/staff.svg',
    'Stock': 'assets/icons/reports/stock.svg',
  };

  final Map<String, List<String>> _reports = {
    'Sales': [
      'Sales by Stores',
      'Sales by Days',
      'Sales by Hour',
      'Sales by Weekdays',
      'Top Sales by Products',
      'Sales by Categories',
      'Sales by Payment Methods',
      'Sales by Staffs',
      'Product Sales - Summary',
      'Product Sales - Detailed',
      'Sale Documents',
      'Sale Documents Products - Summary',
      'Sale Documents Products - Detailed',
    ],
    'Finances': [
      'Cash Flow',
      'Customer Sales',
      'Customer Returns',
      'PAyments to Customers',
      'Payments List',
      'Vendor Purchases',
      'Vendor Returns',
      'Payments to Vendors',
      'Accounts Receivable',
      'Accounts Payable',
      'Profit by Products',
      'Profit by Categories',
      'Received Payments List',
    ],
    'Stock': [
      'Inventory Balance',
      'Store Transfer Details',
      'Purchases Documents',
      // 'Purchases by Item - Summary',
      // 'Purchases by Item - Detailed',
      // 'Sales by Item - Summary',
      // 'Stock Movement',
      // 'Low stock Report',
      // 'Inventory Value',
    ],
  };

  String _getCategoryTitle(BuildContext context, String category) {
    final l10n = S.of(context);
    switch (category) {
      case 'Sales':
        return l10n.sales;
      case 'Finances':
        return l10n.finances;
      // case 'Staff':
      //   return l10n.staff;
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
      case 'Sales by Weekdays':
        return l10n.salesByWeekday;
      case 'Sales by Stores':
        return l10n.salesByStores;
      case 'Top Sales by Products':
        return l10n.topSalesByProducts;
      case 'Sales by Categories':
        return l10n.salesByCategories;
      case 'Sales by Staffs':
        return l10n.salesByStaffs;
      case 'Sales by Payment Methods':
        return l10n.salesByPaymentMethods;
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
      case 'Cash Flow':
        return l10n.cashFlow;
      case 'Customer Sales':
        return l10n.customerSales;
      case 'Customer Returns':
        return l10n.customerReturns;
      case 'PAyments to Customers':
        return l10n.paymentsToCustomers;
      case 'Payments List':
        return l10n.paymentsList;
      case 'Vendor Purchases':
        return l10n.vendorPurchases;
      case 'Vendor Returns':
        return l10n.vendorReturns;
      case 'Payments to Vendors':
        return l10n.paymentsToVendors;
      case 'Accounts Receivable':
        return l10n.accountsReceivable;
      case 'Accounts Payable':
        return l10n.accountsPayable;
      case 'Profit by Products':
        return l10n.profitByProducts;
      case 'Profit by Categories':
        return l10n.profitByCategories;
      case 'Received Payments List':
        return l10n.receivedPaymentsList;
      case 'Inventory Balance':
        return l10n.inventoryBalance;
      case 'Store Transfer Details':
        return l10n.storeTransferDetails;
      case 'Purchases Documents':
        return l10n.purchasesDocuments;
      case 'Product Sales - Summary':
        return l10n.productSalesSummary;
      case 'Product Sales - Detailed':
        return l10n.productSalesDetailed;
      case 'Sale Documents':
        return l10n.saleDocuments;
      case 'Sale Documents Products - Summary':
        return l10n.saleDocumentsProductsSummary;
      case 'Sale Documents Products - Detailed':
        return l10n.saleDocumentsProductsDetailed;
      case 'Purchases by Item - Summary':
        return l10n.purchasesByItemSummary;
      case 'Purchases by Item - Detailed':
        return l10n.purchasesByItemDetailed;
      case 'Sales by Item - Summary':
        return l10n.salesByItemSummary;
      case 'Sales by Item - Detailed':
        return l10n.salesByItemDetailed;
      case 'Low stock Report':
        return l10n.lowStockReport;
      case 'Inventory Value':
        return l10n.inventoryValue;
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
    _isScrollingToSection = true;
    try {
      // Special case for the first section to ensure we hit the top
      if (section == 'Sales') {
        if (_scrollController.hasClients) {
          await _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      } else {
        final key = _sectionKeys[section];
        if (key?.currentContext != null) {
          await Scrollable.ensureVisible(
            key!.currentContext!,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            alignment: 0.0, // Force alignment to top
          );
        }
      }
    } catch (e) {
      debugPrint('Error scrolling to section: $e');
    } finally {
      // Small delay to let scroll momentum settle before enabling scroll listener again
      await Future.delayed(const Duration(milliseconds: 100));
      _isScrollingToSection = false;
      // Manually trigger one update to correct the tab selection
      _onScroll();
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
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildTab('Sales'),
                  const SizedBox(width: 10),
                  _buildTab('Finances'),
                  //const SizedBox(width: 40),
                  //_buildTab('Staff'),
                  const SizedBox(width: 10),
                  _buildTab('Stock'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  // Add extra padding at bottom to allow scrolling last section to top if needed
                  const SizedBox(height: 100),
                ],
              ),
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
    VoidCallback? onTap;

    if (title == 'Sales by Stores') {
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const StoreSalesScreen(),
          ),
        );
      };
    } else if (title == 'Top Sales by Products') {
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TopProductsScreen(),
          ),
        );
      };
    } else if (title == 'Sales by Categories') {
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CategorySalesScreen(),
          ),
        );
      };
    } else if (title == 'Sales by Staffs') {
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const StaffSalesScreen(),
          ),
        );
      };
    } else if (title == 'Sales by Payment Methods') {
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PaymentEntitiesScreen(),
          ),
        );
      };
    } else if (title == 'Profit by Products') {
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfitByProductsScreen(),
          ),
        );
      };
    } else if (title == 'Profit by Categories') {
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfitByCategoriesScreen(),
          ),
        );
      };
    } else if (title == 'Accounts Receivable') {
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BuyersDebtScreen(),
          ),
        );
      };
    } else if (title == 'Accounts Payable') {
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SuppliersDebtScreen(),
          ),
        );
      };
    } else if (title == 'Payments to Vendors') {
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VendorPaymentsScreen(),
          ),
        );
      };
    } else if (title == 'Sales by Days' ||
        title == 'Sales by Hour' ||
        title == 'Sales by Weekdays') {
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SalesSummaryScreen(
              reportTitle: title,
            ),
          ),
        );
      };
    } else if (title == 'Vendor Purchases') {
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VendorPurchasesScreen(),
          ),
        );
      };
    } else if (title == 'Vendor Returns') {
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VendorReturnsScreen(),
          ),
        );
      };
    } else if (title == 'Customer Sales') {
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CustomerSalesScreen(),
          ),
        );
      };
    } else if (title == 'Customer Returns') {
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CustomerReturnsScreen(),
          ),
        );
      };
    } else if (title == 'PAyments to Customers') {
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CustomerPaymentsScreen(),
          ),
        );
      };
    } else if (title == 'Inventory Balance') {
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const InventoryBalanceScreen(),
          ),
        );
      };
    } else if (title == 'Store Transfer Details') {
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const StoreTransferDetailsScreen(),
          ),
        );
      };
    } else if (title == 'Purchases Documents') {
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PurchasesDocumentsScreen(),
          ),
        );
      };
    } else if (title == 'Product Sales - Summary') {
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProductSalesSummaryScreen(),
          ),
        );
      };
    } else if (title == 'Product Sales - Detailed') {
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProductSalesDetailsScreen(),
          ),
        );
      };
    } else if (title == 'Sale Documents') {
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SaleDocumentsScreen(),
          ),
        );
      };
    } else if (title == 'Sale Documents Products - Summary') {
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SaleDocumentsProductsSummaryScreen(),
          ),
        );
      };
    } else if (title == 'Sale Documents Products - Detailed') {
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SaleDocumentsProductsDetailsScreen(),
          ),
        );
      };
    }

    final bool isEnabled = onTap != null;

    if (!isEnabled) return const SizedBox.shrink();

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
          color: isEnabled ? Colors.blue[600] : Colors.grey[400],
          size: 35,
        ),
        onTap: isEnabled ? onTap : null,
      ),
    );
  }
}
