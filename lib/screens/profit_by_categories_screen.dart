import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_reporting/api/response_models/profit_by_category_response_model.dart';
import 'package:mobile_reporting/application_store.dart';
import 'package:mobile_reporting/enums/screen_type.dart';
import 'package:mobile_reporting/helpers/currency_helper.dart';
import 'package:mobile_reporting/helpers/helpers_module.dart';
import 'package:mobile_reporting/helpers/preferences_helper.dart';
import 'package:mobile_reporting/localization/generated/l10n.dart';
import 'package:mobile_reporting/main.dart';
import 'package:mobile_reporting/screens/sign_in_screen.dart';
import 'package:mobile_reporting/services/reports_service.dart';
import 'package:mobile_reporting/theme/app_theme.dart';
import 'package:mobile_reporting/widgets/picker_widget.dart';
import 'package:mobile_reporting/widgets/profile_popover_widget.dart';
import 'package:mobile_reporting/widgets/rotating_logo_loader.dart';

class ProfitByCategoriesScreen extends StatefulWidget {
  const ProfitByCategoriesScreen({super.key});

  @override
  State<ProfitByCategoriesScreen> createState() =>
      _ProfitByCategoriesScreenState();
}

class _ProfitByCategoriesScreenState extends State<ProfitByCategoriesScreen> {
  final ReportsService _reportsService = ReportsService();
  final ScrollController _scrollController = ScrollController();

  bool _filtersLoaded = false;

  List<ProfitByCategoryResponseModel> _items = [];
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

  String? _companyName;
  String? _email;
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadFilters();
    _loadUserData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFilters() async {
    await application.loadFilters();
    if (mounted) {
      setState(() {
        _startDate = application.startCurrentPeriod ?? _startDate;
        _endDate = application.endCurrentPeriod ?? _endDate;
        _filtersLoaded = true;
      });
    }
  }

  Future<void> _loadUserData() async {
    _companyName = await getIt<PreferencesHelper>().getCompanyName();
    _email = await getIt<PreferencesHelper>().getEmail();
    final savedLang = await getIt<PreferencesHelper>().getLang();
    if (savedLang != null) _selectedLanguage = savedLang;
    if (mounted) setState(() {});
  }

  void _changeLanguage(String langCode) async {
    setState(() => _selectedLanguage = langCode);
    await getIt<PreferencesHelper>().setLang(langCode);
    if (mounted) ReportingApp.of(context).setLocale(Locale(langCode));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  void _resetAndLoad() {
    setState(() {
      _items = [];
      _currentPage = 1;
      _hasMore = true;
    });
    _loadData();
  }

  Future<void> _loadData() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final results = await _reportsService.getProfitByCategories(
        startDate: _startDate,
        endDate: _endDate,
        page: _currentPage,
        pageSize: _pageSize,
      );
      setState(() {
        if (results != null) {
          _items = results;
          _hasMore = results.length == _pageSize;
        }
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _currentPage + 1;
      final results = await _reportsService.getProfitByCategories(
        startDate: _startDate,
        endDate: _endDate,
        page: nextPage,
        pageSize: _pageSize,
      );
      setState(() {
        if (results != null && results.isNotEmpty) {
          _items.addAll(results);
          _currentPage = nextPage;
          _hasMore = results.length == _pageSize;
        } else {
          _hasMore = false;
        }
        _isLoadingMore = false;
      });
    } catch (_) {
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: AppTheme.primaryTextColor),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: Text(
              l10n.profitByCategories,
              style: const TextStyle(
                color: AppTheme.primaryTextColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'Bold',
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton(
                  icon: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(21),
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: SvgPicture.asset(
                          'assets/icons/user.svg',
                          colorFilter: const ColorFilter.mode(
                            AppTheme.primaryBlue,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    showProfilePopover(
                      context: context,
                      name: _companyName ?? 'Name',
                      email: _email ?? 'Email@gmail.com',
                      currentLangCode: _selectedLanguage,
                      onLanguageChanged: _changeLanguage,
                      onLogout: () async {
                        await getIt<PreferencesHelper>().clearCompanyName();
                        await getIt<PreferencesHelper>().clearLang();
                        await getIt<PreferencesHelper>().clearType();
                        await getIt<PreferencesHelper>().clearUserAuthToken();
                        await getIt<PreferencesHelper>().clearUserName();
                        await getIt<PreferencesHelper>().clearEmail();
                        await getIt<PreferencesHelper>().clearAccountLang();
                        await getIt<PreferencesHelper>().clearDatabase();
                        await getIt<PreferencesHelper>().clearUrl();
                        if (!mounted) return;
                        // ignore: use_build_context_synchronously
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SignInScreen()),
                          (route) => false,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: !_filtersLoaded
          ? Center(child: RotatingLogoLoader())
          : Column(
              children: [
                PickerWidget(
                  screenType: ScreenType.reportssScreen,
                  showCompareDateFilter: false,
                  showStoreFilter: false,
                  onlyDayPicker: false,
                  getDate: (dt1, dt2, dt3, dt4, min, max, bill) async {
                    _startDate = dt1;
                    _endDate = dt2;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _resetAndLoad();
                    });
                  },
                ),
                Expanded(
                  child: _isLoading && _items.isEmpty
                      ? Center(child: RotatingLogoLoader())
                      : ListView(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          children: [
                            if (_items.isNotEmpty)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    _buildTableHeader(l10n),
                                    ...List.generate(
                                      _items.length,
                                      (i) => _buildRow(_items[i], i, l10n),
                                    ),
                                    if (_hasMore)
                                      const Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 16),
                                        child:
                                            Center(child: RotatingLogoLoader()),
                                      ),
                                  ],
                                ),
                              )
                            else
                              SizedBox(
                                height: 300,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.bar_chart,
                                          size: 48,
                                          color: Colors.grey.shade300),
                                      const SizedBox(height: 16),
                                      Text(
                                        l10n.noDataAvailable,
                                        style: TextStyle(
                                            color: Colors.grey.shade500),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildTableHeader(S l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              l10n.category,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          _headerLabel(l10n.amount),
          _headerLabel(l10n.selfcost),
          _headerLabel('VAT'),
          _headerLabel(l10n.profit),
        ],
      ),
    );
  }

  Widget _headerLabel(String text) {
    return Expanded(
      flex: 3,
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildRow(ProfitByCategoryResponseModel item, int index, S l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.categoryName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Expanded(
            flex: 3,
            child: Text(
              CurrencyHelper.format(item.amount,
                  showSymbol: false, showDecimals: false),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),

          // Self Cost
          Expanded(
            flex: 3,
            child: Text(
              CurrencyHelper.format(item.selfCost,
                  showSymbol: false, showDecimals: false),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),

          // VAT
          Expanded(
            flex: 3,
            child: Text(
              CurrencyHelper.format(item.vat,
                  showSymbol: false, showDecimals: false),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),

          // Profit
          Expanded(
            flex: 3,
            child: Text(
              CurrencyHelper.format(item.profit,
                  showSymbol: false, showDecimals: false),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
