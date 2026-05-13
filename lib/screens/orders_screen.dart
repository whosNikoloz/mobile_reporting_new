import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_reporting/api/response_models/order_response_model.dart';
import 'package:mobile_reporting/application_store.dart';
import 'package:mobile_reporting/enums/screen_type.dart';
import 'package:mobile_reporting/helpers/currency_helper.dart';
import 'package:mobile_reporting/localization/generated/l10n.dart';
import 'package:mobile_reporting/screens/order_details_screen.dart';
import 'package:mobile_reporting/services/reports_service.dart';
import 'package:mobile_reporting/theme/app_theme.dart';
import 'package:mobile_reporting/widgets/picker_widget.dart';
import 'package:mobile_reporting/widgets/rotating_logo_loader.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final ReportsService _reportsService = ReportsService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<OrderResponseModel> _orders = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  static const int _pageSize = 20;

  DateTime _startDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    0,
    0,
  );
  DateTime _endDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    23,
    59,
  );

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _resetAndLoad();
    });
  }

  void _resetAndLoad() {
    setState(() {
      _orders = [];
      _currentPage = 1;
      _hasMore = true;
    });
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final storeId = application.selectedStoreId ?? 0;
      final results = await _reportsService.getOrders(
        storeId: storeId,
        startDate: _startDate,
        endDate: _endDate,
        page: _currentPage,
        pageSize: _pageSize,
        searchQuery:
            _searchController.text.isEmpty ? null : _searchController.text,
      );

      setState(() {
        if (results != null) {
          _orders = results.items;
          _hasMore = results.hasMore;
        }
        _isLoading = false;
      });
    } catch (err) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);

    try {
      final storeId = application.selectedStoreId ?? 0;
      final nextPage = _currentPage + 1;
      final results = await _reportsService.getOrders(
        storeId: storeId,
        startDate: _startDate,
        endDate: _endDate,
        page: nextPage,
        pageSize: _pageSize,
        searchQuery:
            _searchController.text.isEmpty ? null : _searchController.text,
      );

      setState(() {
        if (results != null && results.items.isNotEmpty) {
          _orders.addAll(results.items);
          _currentPage = nextPage;
          _hasMore = results.hasMore;
        } else {
          _hasMore = false;
        }
        _isLoadingMore = false;
      });
    } catch (err) {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _onRefresh() async {
    _currentPage = 1;
    _hasMore = true;
    await _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.grey.shade100),
            child: Column(
              children: [
                PickerWidget(
                  screenType: ScreenType.ordersScreen,
                  showCompareDateFilter: false,
                  showStoreFilter: true,
                  onlyDayPicker: true,
                  getDate: (DateTime dt1,
                      DateTime dt2,
                      DateTime dt3,
                      DateTime dt4,
                      double? minAmount,
                      double? maxAmount,
                      String? billNum) async {
                    _startDate = dt1;
                    _endDate = dt2;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _resetAndLoad();
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Container(
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
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: S.of(context).search,
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 15,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.fromLTRB(18, 0, 5, 0),
                          child: SvgPicture.asset(
                            'assets/icons/search.svg',
                            width: 18,
                            height: 18,
                            colorFilter: ColorFilter.mode(
                              AppTheme.primaryBlue,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () => _searchController.clear(),
                                child: Icon(Icons.close,
                                    size: 18, color: Colors.grey.shade600),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Orders list
          Expanded(
            child: _isLoading && _orders.isEmpty
                ? Center(child: RotatingLogoLoader())
                : _orders.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noOrdersFound,
                          style: const TextStyle(
                            color: AppTheme.secondaryTextColor,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: _orders.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _orders.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: RotatingLogoLoader(),
                                ),
                              );
                            }
                            return _buildOrderCard(_orders[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Color _statusBarColor(int? status) {
    switch (status) {
      case 1:
        return Colors.green;
      case 2:
        return AppTheme.primaryBlue;
      case 3:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Widget _buildOrderCard(OrderResponseModel order) {
    final l10n = S.of(context);
    final isInactive = order.status == 3;
    final iconColor = isInactive ? Colors.grey : AppTheme.primaryBlue;
    final textColor = isInactive ? Colors.grey : AppTheme.primaryTextColor;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OrderDetailsScreen(
              orderId: order.orderId,
              orderNumber: order.orderNumber,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 68,
              decoration: BoxDecoration(
                color: _statusBarColor(order.status),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/hashtag.svg',
                                width: 14,
                                height: 14,
                                colorFilter: ColorFilter.mode(
                                  iconColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                order.orderNumber,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/user.svg',
                                width: 14,
                                height: 14,
                                colorFilter: ColorFilter.mode(
                                  iconColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  order.user,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: textColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/time.svg',
                                width: 14,
                                height: 14,
                                colorFilter: ColorFilter.mode(
                                  iconColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "${order.orderTime}",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/cash.svg',
                                width: 14,
                                height: 14,
                                colorFilter: ColorFilter.mode(
                                  iconColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                CurrencyHelper.format(order.amount,
                                    showSymbol: false),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const Spacer(),
                              if (order.payType != null)
                                Text(
                                  order.payType == 0 ? l10n.cash : l10n.card,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.secondaryTextColor,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
